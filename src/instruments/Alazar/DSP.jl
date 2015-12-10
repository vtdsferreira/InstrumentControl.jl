# DSP functions

## Exports #####################################################################

export DSPModule
export FFTRecordMode
export MinFFTSamples
export MaxFFTSamples

export dsp_num_modules
export dsp_modules
export dsp_getmodulehandles
export dsp_getinfo
export dsp_generatewindowfunction
export fft_setwindowfunction
export fft_verificationmode
export fft_setup
export outputformat

## Type definitions ############################################################

type DSPModule
    ins::InstrumentAlazar
    handle::dsp_module_handle
end

immutable DSPModuleInfo
    dsp_module_id::U32
    version_major::U16
    version_minor::U16
    max_record_length::U32
end
Base.show(io::IO, x::DSPModuleInfo) = print(io,
    string("$(DSPModuleType{x.dsp_module_id}) ",
           "v$(Int(x.version_major)).$(Int(x.version_minor)); ",
           "max record length: $(x.max_record_length)"))


immutable DSPModuleType{T} end
describe(::Type{DSPModuleType{Alazar.DSP_MODULE_NONE}}) = "No DSP module"
describe(::Type{DSPModuleType{Alazar.DSP_MODULE_FFT}})  = "FFT module"
describe(::Type{DSPModuleType{Alazar.DSP_MODULE_PCD}})  = "PCD module"
Base.show{T<:DSPModuleType}(io::IO, a::Type{T}) = print(io, describe(a))

type FFTRecordMode <: RecordMode
    sam_per_rec::Int
    sam_per_fft::Int
    total_recs::Int
    output_eltype::DataType

    by_rec::U32

    FFTRecordMode(a,b,c,d) = new(a,b,c,d,0)
end

abstract MinFFTSamples <: AlazarProperty
abstract MaxFFTSamples <: AlazarProperty

## Methods extended for DSP features ###########################################

function abort(a::InstrumentAlazar, m::FFTRecordMode)
   @eh2 AlazarDSPAbortCapture(a.handle)
end

adma(::FFTRecordMode) = Alazar.ADMA_NPT |
                        Alazar.ADMA_DSP |
                        Alazar.ADMA_EXTERNAL_STARTCAPTURE

function before_async_read(a::InstrumentAlazar, m::FFTRecordMode)

    pretrig = -pretriggersamples(m)
    by_rec  = m.by_rec
    println("Pretrigger samples: $(pretriggersamples(m))")
    println("  Bytes per record: $(by_rec)")
    println("Records per buffer: $(inspect_per(a, m, Record, Buffer))")
    println("Records per acquis: $(inf_records)")
    sleep(1)
    r = @eh2 AlazarBeforeAsyncRead(a.handle,
                                   Alazar.CHANNEL_A,
                                   pretrig,
                                   by_rec,
                                   inspect_per(a, m, Record, Buffer),
                                   inf_records,
                                   adma(m))
    r
end

function bufferarray(a::InstrumentAlazar, m::FFTRecordMode)
    buf_size = inspect(a, BufferSize)
    buf_count = inspect(a, BufferCount)
    return Alazar.DMABufferArray{m.output_eltype}(buf_size, buf_count)
end

function buffersizing(a::InstrumentAlazar, m::FFTRecordMode)

    # The FFT length (samples) will not be resized.
    # The record length for acquisition may be resized if necessary.
    # Unlike other record modes we may need to shorten the record to
    # accommodate the requested FFT length.

    # First to ensure the right calculations we set ChannelA only
    configure(a, ChannelA)

    sr = m.sam_per_rec
    tr = m.total_recs
    sf = m.sam_per_fft
    max_sam_fft = inspect(a, MaxFFTSamples)
    min_sam_fft = inspect(a, MinFFTSamples)
    !ispow2(sf) && error("FFT length (samples) not a power of 2!")
    sf < min_sam_fft && error("FFT length (samples) too short!")
    sf > max_sam_fft && error("FFT length (samples) too long!")

    min_sam = inspect(a, MinSamplesPerRecord)
    pagesize = Base.Mmap.PAGESIZE

    by_raw_sam = inspect_per(a, Byte, Sample)   # Bytes per raw (not FFT) sample
    by_fft_sam = sizeof(m.output_eltype)        # Bytes per FFT sample
    # by_raw_rec may change depending on how we resize the records
    by_fft_rec = m.by_rec                       # Bytes per FFT record

    # rec_align is the alignment needed for the start of each buffer, in bytes
    rec_fft_align = inspect(a, BufferAlignment) * by_fft_sam
    rec_raw_align = inspect(a, BufferAlignment) * by_raw_sam

    # buf_grain is the granularity of buffer allocation in bytes
    buf_grain = lcm(pagesize, rec_fft_align, rec_raw_align)
                 #, by_fft_sam, by_raw_sam) implicit.

    # max_buf_size will contain the largest acceptable buffer (in bytes)
    max_size_buf = inspect(a, MaxBufferBytes)
    max_size_buf = fld(max_size_buf, buf_grain) * buf_grain

    size_raw_rec = cld(by_raw_sam * sr, rec_raw_align) * rec_raw_align
    sr = Int(size_raw_rec / by_raw_sam) # will be an integer for sure
    sr != m.sam_per_rec &&
        warn("Samples per record has been adjusted to $sr to meet alignment ",
             "requirements.")
    m.sam_per_rec = sr

    if sr > sf
        # More samples per record than samples per FFT.
        sr = sf
        m.sam_per_rec = sr
        warn("Samples per record has been truncated to $(m.sam_per_rec) ",
             "because of the FFT length.")
    end

    # Samples per record cannot be too big for buffer since it is limited
    # by the (comparably short) maximum FFT length.

    if sr < min_sam
        # Too few samples in record. Choose shortest possible record.
        # It seems that this will always be divisible by the number of channels,
        # at least for existing Alazar digitizers.
        sr = min_sam
        m.sam_per_rec = sr

        # Issue a warning and proceed.
        warn("Samples per record adjusted to $sr to meet minimum record ",
             "length requirements.")
    end

    size_fft_rec = cld(by_fft_sam * sf, rec_fft_align) * rec_fft_align
    sf = Int(size_fft_rec / by_fft_sam) # will be an integer for sure
    sf != m.sam_per_fft &&
        error("Samples per FFT does not meet record alignment criteria, somehow.")

    if sf * tr * by_fft_sam > max_size_buf
        # Not everything will fit in one buffer. Changing samples per FFT
        # is unacceptable so we change the total records if necessary.

        # Now we have to choose the buffer size carefully because
        # we need to have all buffers completely filled.
        # max_recs_buf: maximum number of records that will fit in a buffer
        size_buf = max_size_buf

        nbuf = cld(sf * tr * by_fft_sam, max_size_buf)
        tr = Int(nbuf / size_fft_rec) # will be an integer for sure
        tr != m.total_recs &&
            warn("Total FFTs adjusted to $tr so all buffers fill completely.")
        m.total_recs = tr
    else
        # Only one buffer.
        # We don't need to worry about alignment of nth buffer.
        size_buf = sf * tr * by_fft_sam
    end

    configure(a, BufferSize, size_buf)
    println("Buffer size: $size_buf")

end

function prepare(a::InstrumentAlazar, m::FFTRecordMode)
    dspmodule = dsp_modules(a)[1]

    fft_setwindowfunction(dspmodule,
                          m.sam_per_rec,
                          C_NULL,
                          C_NULL)

    m.by_rec  = fft_setup(dspmodule,
                          m.sam_per_rec,  # / ChannelCount, which is always 1
                          m.sam_per_fft,
                          outputformat(m.output_eltype),
                          Alazar.FFT_FOOTER_NONE)

    before_async_read(a,m)
end

function wait_buffer(a::InstrumentAlazar, m::FFTRecordMode, buffer, timeout_ms)
    @eh2 AlazarDSPGetBuffer(a.handle, buffer, timeout_ms)
end

## DSP functions ###############################################################

function dsp_num_modules(a::InstrumentAlazar)
    numModules = Array{U32}(1)
    numModules[1] = U32(0)
    r = AlazarDSPGetModules(a.handle, 0, C_NULL, numModules)
    if r != alazar_no_error
        throw(InstrumentException(a,r))
    end
    numModules[1]
end

function dsp_modules(a::InstrumentAlazar)
    a.dspModules
end

function dsp_getmodulehandles(a::InstrumentAlazar)
    numModules = dsp_num_modules(a)
    if numModules == 0
        error("No DSP modules to get.")
    end

    modules = Array(dsp_module_handle,numModules)

    r = AlazarDSPGetModules(a.handle, numModules, modules, C_NULL)
    if r != alazar_no_error
        throw(InstrumentException(a,r))
    end

    modules
end

# The InstrumentAlazar is only used for throwing exceptions
function dsp_getinfo(dspModule::DSPModule)

    dspModuleId = Array(U32,1)
    dspModuleId[1] = 0

    versionMajor = Array(U16,1)
    versionMajor[1] = 0

    versionMinor = Array(U16,1)
    versionMinor[1] = 0

    maxLength = Array(U32,1)
    maxLength[1] = 0

    r = AlazarDSPGetInfo(dspModule.handle, dspModuleId, versionMajor,
        versionMinor, maxLength, C_NULL, C_NULL)
    if r != alazar_no_error
        throw(InstrumentException(dspModule.ins,r))
    end

    DSPModuleInfo(dspModuleId[1], versionMajor[1], versionMinor[1], maxLength[1])
end

function dsp_generatewindowfunction(windowType,
        windowLength_samples, paddingLength_samples)

    window = Array(Cfloat, windowLength_samples + paddingLength_samples)
    r = AlazarDSPGenerateWindowFunction(windowType, window,
        windowLength_samples, paddingLength_samples)
    if r != alazar_no_error
        error(except(r))
    end

    window
end

function fft_setwindowfunction(dspModule::DSPModule, samplesPerRecord, reArray, imArray)
    r = AlazarFFTSetWindowFunction(dspModule.handle, samplesPerRecord, reArray, imArray)
    if r != alazar_no_error
        throw(InstrumentException(dspModule.ins,r))
    end
    nothing
end

function fft_setup(dspModule::DSPModule, recordLength_samples, fftLength_samples,
        outputFormat, footer)

    bytesPerOutputRecord = Array(U32,1)
    bytesPerOutputRecord[1] = 0

    r = AlazarFFTSetup(dspModule.handle, Alazar.CHANNEL_A, recordLength_samples,
        fftLength_samples, outputFormat, footer, U32(0), bytesPerOutputRecord)
    if r != alazar_no_error
        throw(InstrumentException(dspModule.ins,r))
    end

    bytesPerOutputRecord[1]
end

outputformat(::Type{Alazar.U32})       = Alazar.FFT_OUTPUT_FORMAT_U32
outputformat(::Type{Alazar.U16Log})    = Alazar.FFT_OUTPUT_FORMAT_U16_LOG
outputformat(::Type{Alazar.U16Amp2})   = Alazar.FFT_OUTPUT_FORMAT_U16_AMP2
outputformat(::Type{Alazar.U8Log})     = Alazar.FFT_OUTPUT_FORMAT_U8_LOG
outputformat(::Type{Alazar.U8Amp2})    = Alazar.FFT_OUTPUT_FORMAT_U8_AMP2
outputformat(::Type{Alazar.S32Real})   = Alazar.FFT_OUTPUT_FORMAT_REAL_S32
outputformat(::Type{Alazar.S32Imag})   = Alazar.FFT_OUTPUT_FORMAT_IMAG_S32
outputformat(::Type{Alazar.FloatAmp2}) = Alazar.FFT_OUTPUT_FORMAT_FLOAT_AMP2
outputformat(::Type{Alazar.FloatLog})  = Alazar.FFT_OUTPUT_FORMAT_FLOAT_LOG

# Undocumented in API. Let's hide this one for now...
# function fftVerificationMode(dspModule::DSPModule, enable,
#         reArray, imArray, recordLength_samples)
#     r = ccall((:AlazarFFTVerificationMode,ats), U32,
#         (dsp_module_handle,Bool,Ptr{S16},Ptr{S16},size_t),
#         dspModule.handle, enable, reArray, imArray, recordLength_samples)
#     if (r != alazar_no_error)
#         throw(InstrumentException(dspModule.ins,r))
#     end
# end
