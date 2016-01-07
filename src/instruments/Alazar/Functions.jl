export abort
export before_async_read
export busy
export dsp_generatewindowfunction
export dsp_getinfo
export dsp_getmodulehandles
export dsp_modules
export dsp_num_modules
export fft_setup
export fft_setwindowfunction
export forcetrigger
export forcetriggerenable
export inputcontrol
export post_async_buffer
export set_parameter
export set_parameter_ul
export set_triggeroperation
export startcapture
export triggered
export wait_buffer
export windowfunction

# eventually we will not export these:
export bufferarray
export buffersizing
export recordsizing
export windowing

function abort(a::InstrumentAlazar, m::AlazarMode)
    @eh2 AlazarAbortAsyncRead(a.handle)
    nothing
end

function abort(a::InstrumentAlazar, m::FFTRecordMode)
    @eh2 AlazarDSPAbortCapture(a.handle)
    nothing
end

"""
Aborts an acquisition. Must be called in the case of a DSP acquisition; somehow
less fatal otherwise. Should be automatically taken care of in a well-written
`measure` method, but can be called manually by the paranoid.
"""
abort

adma(::ContinuousStreamMode)   = Alazar.ADMA_CONTINUOUS_MODE |
                                 Alazar.ADMA_FIFO_ONLY_STREAMING |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::TriggeredStreamMode)    = Alazar.ADMA_TRIGGERED_STREAMING |
                                 Alazar.ADMA_FIFO_ONLY_STREAMING |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::NPTRecordMode)          = Alazar.ADMA_NPT |
                                 Alazar.ADMA_FIFO_ONLY_STREAMING |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::TraditionalRecordMode)  = Alazar.ADMA_TRADITIONAL_MODE |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE
                                 # other flags?

adma(::FFTRecordMode)          = Alazar.ADMA_NPT |
                                 Alazar.ADMA_DSP |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE

"Returns the asynchronous DMA flags for a given `AlazarMode`. These are
passed as the final parameter to the C function `AlazarBeforeAsyncRead`."
adma

function before_async_read(a::InstrumentAlazar, m::AlazarMode)

    # retrigger(a)
    pretrig = -pretriggersamples(m) / inspect(a, ChannelCount)
    sam_rec_ch = samples_per_record_measured(a,m) / inspect(a, ChannelCount)

    println("Pretrigger samples: $(pretriggersamples(m))")
    println("Samples per record: $(samples_per_record_measured(a,m))")
    println("Records per buffer: $(records_per_buffer(a,m))")
    sleep(1)
    @eh2 AlazarBeforeAsyncRead(a.handle,
                               a.acquisitionChannel,
                               pretrig,
                               sam_rec_ch,
                               records_per_buffer(a,m),
                               rec_acq_param(m),
                               adma(m))
    nothing
end

function before_async_read(a::InstrumentAlazar, m::FFTRecordMode)

    # retrigger(a)
    fft_setup(a,m)

    pretrig = -pretriggersamples(m)
    println("Pretrigger samples: $(pretriggersamples(m))")
    println("  Bytes per record: $(m.by_rec)")
    println("Records per buffer: $(Int(m.buf_size / m.by_rec))")
    sleep(1)
    @eh2 AlazarBeforeAsyncRead(a.handle,
                               Alazar.CHANNEL_A,
                               pretrig,
                               m.by_rec,
                               m.buf_size / m.by_rec, # will be an int
                               rec_acq_param(m),
                               adma(m))
    nothing
end

"""
Performs setup for asynchronous acquisitions. Should be called after
`buffersizing` has been called.
"""
before_async_read

"""
Returns the number of bits per sample. Queries the digitizer directly via
the C function `AlazarGetChannelInfo`.
"""
function bits_per_sample(a::InstrumentAlazar)
    memorysize_samples = Array{U32}(1)
    memorysize_samples[1] = U32(0)

    bitspersample = Array{U8}(1)
    bitspersample[1] = U8(0)

    @eh2 AlazarGetChannelInfo(a.handle, memorysize_samples, bitspersample)

    return bitspersample[1]
end

"""
Return a handle to an Alazar digitizer given a system ID and board ID.
For single digitizer systems, pass 1 for both to get a handle for the digitizer.
"""
function boardhandle(sysid::Integer,boardid::Integer)
    r = AlazarGetBoardBySystemID(sysid,boardid)
    r == C_NULL && error("Not found: system ID $sysid, board ID $boardid")
    r
end

"Returns the kind of digitizer; corresponds to a constant in AlazarConstants.jl
in the Alazar.jl package."
boardkind(handle::U32) = AlazarGetBoardKind(handle)

function bufferarray(a::InstrumentAlazar, m::AlazarMode)
    bits = bits_per_sample(a)
    btype = begin # which does not introduce a new scope block, fyi
        bits == 8 ? Alazar8Bit :
        (bits == 12 ? Alazar12Bit : Alazar16Bit)
    end
    return Alazar.DMABufferArray{btype}(m.buf_size, m.buf_count)
end

function bufferarray(a::InstrumentAlazar, m::FFTRecordMode)
    return Alazar.DMABufferArray{m.output_eltype}(m.buf_size, m.buf_count)
end

"""
Given and `InstrumentAlazar` and `AlazarMode`, returns a `DMABufferArray`
with the correct number of buffers and buffer sizes. `buffersizing` should have
been called before this function.
"""
bufferarray

function buffersizing(a::InstrumentAlazar, m::RecordMode)

    sr = m.sam_per_rec
    tr = m.total_recs

    chans = inspect(a, ChannelCount)
    min_sam = inspect(a, MinSamplesPerRecord)
    pagesize = Base.Mmap.PAGESIZE
    by_sam = bytes_per_sample(a)

    # rec_align is the alignment needed for the start of each buffer, in bytes
    rec_align = inspect(a, BufferAlignment) * by_sam

    # buf_grain is the granularity of buffer allocation in bytes
    buf_grain = lcm(by_sam*chans, pagesize, rec_align)

    # max_buf_size will contain the largest acceptable buffer (in bytes)
    max_size_buf = inspect(a, MaxBufferBytes)
    max_size_buf = fld(max_size_buf, buf_grain) * buf_grain

    if sr * by_sam > max_size_buf
        # Record too big for one buffer. Choose largest possible record.
        size_buf = max_size_buf

        # Issue a warning and proceed.
        m.sam_per_rec = Int(size_buf/by_sam)
        warn("Samples per record has been truncated to $(m.sam_per_rec) ",
             "because of buffer size limitations.")
    else
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

        size_rec = cld(by_sam*sr, rec_align)*rec_align
        sr = Int(size_rec / by_sam) # will be an integer for sure
        sr != m.sam_per_rec &&
            warn("Samples per record adjusted to $sr to meet alignment ",
                 "requirements.")
        m.sam_per_rec = sr

        if sr * tr * by_sam > max_size_buf
            # Not everything will fit in one buffer.
            # Grow samples / record slightly so that it takes up the nearest
            # buffer granularity. Note that it cannot grow larger than
            # max_size_buf because we checked for that already.
            size_rec = cld(by_sam*sr, buf_grain)*buf_grain
            sr = Int(size_rec / by_sam) # will be an integer for sure
            sr != m.sam_per_rec &&
                warn("Samples per record adjusted to $sr to meet alignment ",
                     "requirements.")
            m.sam_per_rec = sr

            # Now we have to choose the buffer size carefully because
            # we need to have all buffers completely filled.
            # max_recs_buf: maximum number of records that will fit in a buffer
            max_recs_buf = fld(max_size_buf, size_rec)
            recs_buf = indmax([gcd(i, tr) for i in collect(1:max_recs_buf)])

            size_buf = recs_buf * size_rec
        else
            # Only one buffer.
            # We don't need to worry about alignment of nth buffer.
            size_buf = sr * tr * by_sam
        end
    end

    m.buf_size = size_buf
    println("Buffer size: $size_buf")
end

function buffersizing(a::InstrumentAlazar, m::StreamMode)

    ts = m.total_samples

    chans = inspect(a, ChannelCount)
    min_sam = inspect(a, MinSamplesPerRecord)
    pagesize = Base.Mmap.PAGESIZE
    by_sam = bytes_per_sample(a)

    # There may be multiple buffers. We choose to make sure that they are
    # sized in multiples of the page size so that multiple buffers can come from
    # a contiguous allocation of memory. Choose biggest buffer <= the digitizer's
    # max size that is commensurate with *both* the page size and
    # (bytes/sample * channels)
    max_size_buf = inspect(a, MaxBufferBytes)    # from the digitizer's perspective.
    buf_grain = lcm(by_sam*chans, pagesize)
    max_size_buf = fld(max_size_buf, buf_grain) * buf_grain # from our requirements

    if ts < min_sam
        # Some digitizers may measure 3 channels or some ugly number so
        # we want the smallest sample count divisible by the number of channels.
        # Only one buffer so we don't worry about the page size.
        ts = cld(min_sam, chans) * chans
        size_buf = ts * by_sam
        m.total_samples = ts
        warn("Total samples adjusted to $ts to meet minimum record ",
             "length requirements.")
    elseif ts * by_sam > max_size_buf
        size_buf = max_size_buf
        # POTENTIAL BUG: < min_sam samples in last buffer???
    else
        size_buf = ts * by_sam
    end

    m.buf_size = size_buf
end

function buffersizing(a::InstrumentAlazar, m::FFTRecordMode)

    # The FFT length (samples) will *not* be resized.
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

    by_raw_sam = bytes_per_sample(a)   # Bytes per raw (not FFT) sample
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

    size_fft_rec = cld(by_fft_sam * sf / 2, rec_fft_align) * rec_fft_align
    sf = Int(size_fft_rec / by_fft_sam) # will be an integer for sure
    sf != m.sam_per_fft / 2 &&
        error("Unexpected error.")

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

    m.buf_size = size_buf
    println("Buffer size: $size_buf")

end

"""
Given an `InstrumentAlazar` and an `AlazarMode`, this will tweak parameters
in the `AlazarMode` object to comply with record alignment and buffer granularity
requirements imposed by either the AlazarTech digitizer itself, or the implementation
of measurement code. Should be called toward the very beginning of a `measure`
method.
"""
buffersizing


buffers_per_acquisition(a::InstrumentAlazar, m::StreamMode) =
    Int(cld(m.total_samples, samples_per_buffer_returned(a,m)))
buffers_per_acquisition(a::InstrumentAlazar, m::RecordMode) =
    Int(cld(m.total_recs, records_per_buffer(a,m)))

"Returns whether or not the `InstrumentAlazar` is busy (Bool)."
busy(a::InstrumentAlazar) = AlazarBusy(a.handle) > 0 ? true : false

"""
Returns the number of bytes per sample. Calls `bitspersample` and does ceiling
division by 8.
"""
bytes_per_sample(a::InstrumentAlazar) = Int(cld(bitspersample(a),8))

dsp(::Type{WindowNone})           = Alazar.DSP_WINDOW_NONE
dsp(::Type{WindowHanning})        = Alazar.DSP_WINDOW_HANNING
dsp(::Type{WindowHamming})        = Alazar.DSP_WINDOW_HAMMING
dsp(::Type{WindowBlackman})       = Alazar.DSP_WINDOW_BLACKMAN
dsp(::Type{WindowBlackmanHarris}) = Alazar.DSP_WINDOW_BLACKMAN_HARRIS
dsp(::Type{WindowBartlett})       = Alazar.DSP_WINDOW_BARTLETT

"""
Given a DSPWindow type, this returns the constant needed to use the AlazarDSP
API to generate a particular window function.
"""
dsp

function dsp_generatewindowfunction{S<:AlazarWindow,T<:Union{Re,Im}}(
        ::Type{S}, ::Type{T}, m::FFTRecordMode)

    window = Array(Cfloat, m.sam_per_fft)
    r = AlazarDSPGenerateWindowFunction(dsp(S), window,
        m.sam_per_rec, m.sam_per_fft - m.sam_per_rec)
    if r != alazar_no_error
        error(except(r))
    end

    setwindow(window, T, m)
    nothing
end

function dsp_generatewindowfunction{T<:Union{Re,Im}}(
        ::Type{WindowZeroes}, ::Type{T}, m::FFTRecordMode)

    window = Array(Cfloat, m.sam_per_fft)
    window[:] = 0.0

    setwindow(window, T, m)
    nothing
end

"""
Given a `DSPWindow`, `Re` or `Im` type, and `FFTRecordMode`, this will prepare
a window function to be set later by calling `windowing`.
"""
dsp_generatewindowfunction

# The InstrumentAlazar is only used for throwing exceptions
"Returns a DSPModuleInfo object that describes a DSPModule."
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

"Returns an Array of `dsp_module_handle`."
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

"Returns an array of `DSPModule`."
function dsp_modules(a::InstrumentAlazar)
    a.dspModules
end

"Returns the number of `DSPModule`."
function dsp_num_modules(a::InstrumentAlazar)
    numModules = Array{U32}(1)
    numModules[1] = U32(0)
    r = AlazarDSPGetModules(a.handle, 0, C_NULL, numModules)
    if r != alazar_no_error
        throw(InstrumentException(a,r))
    end
    numModules[1]
end

"""
Performs `AlazarFFTSetup`, which should be called before `AlazarBeforeAsyncRead`.
In our code, this method is called by `before_async_read` and does not need to
be called.
"""
function fft_setup(a::InstrumentAlazar, m::FFTRecordMode)

    recordLength_samples = m.sam_per_rec
    fftLength_samples = m.sam_per_fft
    outputFormat = outputformat(m.output_eltype)
    footer = Alazar.FFT_FOOTER_NONE

    bytesPerOutputRecord = Array(U32,1)
    bytesPerOutputRecord[1] = 0
    dspmodule = dsp_modules(a)[1]

    r = AlazarFFTSetup(dspmodule.handle, Alazar.CHANNEL_A, recordLength_samples,
        fftLength_samples, outputFormat, footer, U32(0), bytesPerOutputRecord)

    if r != alazar_no_error
        throw(InstrumentException(dspModule.ins,r))
    end

    m.by_rec = bytesPerOutputRecord[1]
    nothing
end

"""
A wrapper for the C function `AlazarFFTSetWindowFunction`, but taking a
`DSPModule` instead of a `dsp_module_handle`. Includes error handling.
"""
function fft_setwindowfunction(dspModule::DSPModule, samplesPerRecord, reArray, imArray)
    r = AlazarFFTSetWindowFunction(dspModule.handle, samplesPerRecord, reArray, imArray)
    if r != alazar_no_error
        throw(InstrumentException(dspModule.ins,r))
    end
    nothing
end

# Undocumented in API. Let's hide this one for now...
# export fft_verificationmode
# function fft_verificationmode(dspModule::DSPModule, enable,
#         reArray, imArray, recordLength_samples)
#     r = ccall((:AlazarFFTVerificationMode,ats), U32,
#         (dsp_module_handle,Bool,Ptr{S16},Ptr{S16},size_t),
#         dspModule.handle, enable, reArray, imArray, recordLength_samples)
#     if (r != alazar_no_error)
#         throw(InstrumentException(dspModule.ins,r))
#     end
# end

"Force a software trigger."
function forcetrigger(a::InstrumentAlazar)
    @eh2 AlazarForceTrigger(a.handle)
    nothing
end

"""
Force a software "trigger enable." This involves the AUX I/O connector (see
Alazar API).
"""
function forcetriggerenable(a::InstrumentAlazar)
    @eh2 AlazarForceTriggerEnable(a.handle)
    nothing
end

"""
Controls coupling, input range, and impedance for applicable digitizer cards.
Does nothing for ATS9360 cards since there is only one choice of arguments.
"""
function inputcontrol(a::InstrumentAlazar, channel, coupling, inputRange, impedance)
    @eh2 AlazarInputControl(a.handle, channel, coupling, inputRange, impedance)
    nothing
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

"""
Post an asynchronous buffer to the digitizer for use in an acquisition.
Buffer address must meet alignment requirements.
"""
function post_async_buffer(a::InstrumentAlazar, buffer, bufferLength)
    @eh2 AlazarPostAsyncBuffer(a.handle, buffer, bufferLength)
    nothing
end

pretriggersamples(m::TraditionalRecordMode) = m.pre_sam_per_rec
pretriggersamples(m::AlazarMode) = 0
"Returns the number of pretrigger samples for an `AlazarMode` (usually 0)."
pretriggersamples

"Given an `AlazarMode`, returns the number of pre-trigger samples."
pretriggersamples

function recordsizing(a::InstrumentAlazar, m::RecordMode)
    @eh2 AlazarSetRecordSize(a.handle,
                             0,
                             m.sam_per_rec / inspect(a,ChannelCount))
end

function recordsizing(a::InstrumentAlazar, m::TraditionalRecordMode)
    @eh2 AlazarSetRecordSize(a.handle,
                             m.pre_sam_pre_rec / inspect(a,ChannelCount),
                             m.post_sam_per_rec / inspect(a,ChannelCount))
end

recordsizing(a::InstrumentAlazar, m::FFTRecordMode) = nothing
recordsizing(a::InstrumentAlazar, m::StreamMode) = nothing
"""
Calls C function `AlazarSetRecordSize` if necessary, given an `InstrumentAlazar`
and `AlazarMode`.
"""
recordsizing

rec_acq_param(m::StreamMode)    = inf_records
rec_acq_param(m::RecordMode)    = m.total_recs
rec_acq_param(m::FFTRecordMode) = inf_records
"""
Returns the value to pass as the recordsPerAcquisition parameter in the C
function `AlazarBeforeAsyncRead`, given an `AlazarMode` object.
"""
rec_acq_param

records_per_acquisition(a::InstrumentAlazar, m::StreamMode) =
    buffers_per_acquisition(a,m)
records_per_acquisition(a::InstrumentAlazar, m::RecordMode) =
    records_per_buffer(a,m) * buffers_per_acquisition(a,m)
"""
Given an `InstrumentAlazar` and `AlazarMode`, return the records per acquisition.
For `StreamMode` this will return the number of buffers per acquisition.
`buffer_sizing` should be called first to ensure the `AlazarMode` object
contains values that meet size and alignment requirements.
"""
records_per_acquisition

records_per_buffer(a::InstrumentAlazar, m::StreamMode) = 1
records_per_buffer(a::InstrumentAlazar, m::RecordMode) =
    Int(fld(m.buf_size, samples_per_record_returned(a,m) * bytes_per_sample(a)))
records_per_buffer(a::InstrumentAlazar, m::FFTRecordMode) =
    Int(m.buf_size / m.by_rec)
"""
Given an `InstrumentAlazar` and `AlazarMode`, return the records per buffer.
For `StreamMode` this will return 1.
`buffer_sizing` should be called first to ensure the `AlazarMode` object
contains values that meet size and alignment requirements.
"""
records_per_buffer

samples_per_buffer_measured(a::InstrumentAlazar, m::AlazarMode) =
    samples_per_record_measured(a,m) * records_per_buffer(a,m)
"""
Given an `InstrumentAlazar` and `AlazarMode`, return the samples per buffer
measured by the digitizer.
`buffer_sizing` should be called first to ensure the `AlazarMode` object
contains values that meet size and alignment requirements.
"""
samples_per_buffer_measured

samples_per_buffer_returned(a::InstrumentAlazar, m::AlazarMode) =
    samples_per_record_returned(a,m) * records_per_buffer(a,m)
"""
Given an `InstrumentAlazar` and `AlazarMode`, return the samples per buffer
returned by the digitizer.
`buffer_sizing` should be called first to ensure the `AlazarMode` object
contains values that meet size and alignment requirements.
"""
samples_per_buffer_returned

samples_per_record_measured(a::InstrumentAlazar, m::StreamMode) =
    Int(m.buf_size / bytes_per_sample(a))
samples_per_record_measured(a::InstrumentAlazar, m::RecordMode) =
    m.sam_per_rec
samples_per_record_measured(a::InstrumentAlazar, m::TraditionalRecordMode) =
    m.pre_sam_per_rec + m.post_sam_per_rec
"""
Given an `InstrumentAlazar` and `AlazarMode`, return the samples per record
measured by the digitizer.
`buffer_sizing` should be called first to ensure the `AlazarMode` object
contains values that meet size and alignment requirements.
"""
samples_per_record_measured

samples_per_record_returned(a::InstrumentAlazar, m::StreamMode) =
    Int(m.buf_size / bytes_per_sample(a))
samples_per_record_returned(a::InstrumentAlazar, m::NPTRecordMode) =
    m.sam_per_rec
samples_per_record_returned(a::InstrumentAlazar, m::TraditionalRecordMode) =
    m.pre_sam_per_rec + m.post_sam_per_rec
samples_per_record_returned(a::InstrumentAlazar, m::FFTRecordMode) =
    Int(m.sam_per_fft / 2)
"""
Given an `InstrumentAlazar` and `AlazarMode`, return the samples per record
returned by the digitizer.
`buffer_sizing` should be called first to ensure the `AlazarMode` object
contains values that meet size and alignment requirements.
"""
samples_per_record_returned

"Julia wrapper for C function AlazarSetParameter, with error checking."
function set_parameter(a::InstrumentAlazar, channelId, parameterId, value)
    @eh2 AlazarSetParameter(a.handle, channelId, parameterId, value)
    nothing
end

"Julia wrapper for C function AlazarSetParameterUL, with error checking."
function set_parameter_ul(a::InstrumentAlazar, channelId, parameterId, value)
    @eh2 AlazarSetParameterUL(a.handle, channelId, parameterId, value)
    nothing
end

"""
Configure the trigger operation. Usually not called directly.
Args should be, in the following order:

a::InstrumentAlazar

engine:  one of the trigger engine operation IDs in the Alazar API.

source1: one of `TRIG_CHAN_A`, `TRIG_CHAN_B`, or `TRIG_DISABLE`

slope1:  `TRIGGER_SLOPE_POSITIVE` or `TRIGGER_SLOPE_NEGATIVE`

level1:  an 8-bit unsigned integer

source2: one of `TRIG_CHAN_A`, `TRIG_CHAN_B`, or `TRIG_DISABLE`

slope2:  `TRIGGER_SLOPE_POSITIVE` or `TRIGGER_SLOPE_NEGATIVE`

level2:  an 8-bit unsigned integer
"""
function set_triggeroperation(a::InstrumentAlazar, args...)
    if length(args) != 7
        error("Need 7 arguments beside the instrument: engine, source1, ",
            "slope1, level1, source2, slope2, level2.")
    end
    @eh2 AlazarSetTriggerOperation(a.handle, args[1],
        Alazar.TRIG_ENGINE_J, args[2], args[3], triglevel(a,args[4]),
        Alazar.TRIG_ENGINE_K, args[5], args[6], triglevel(a,args[7]))
    (a.engine,
        a.channelJ, a.slopeJ, a.levelJ,
        a.channelK, a.slopeK, a.levelK) = (args...)
    nothing
end

"Set the window for the real part of the FFT. Must be followed by calling `windowing`."
function setwindow(window, ::Type{Re}, m::FFTRecordMode)
    m.re_window = window
    nothing
end

"Set the window for the imag part of the FFT. Must be followed by calling `windowing`."
function setwindow(window, ::Type{Im}, m::FFTRecordMode)
    m.im_window = window
    nothing
end

"Should be called after `before_async_read` has been called and buffers are posted."
function startcapture(a::InstrumentAlazar)
    @eh2 AlazarStartCapture(a.handle)
    nothing
end

"Reports whether or not the digitizer has been triggered."
triggered(a::InstrumentAlazar) = AlazarTriggered(a.handle) > 0 ? true : false

function wait_buffer(a::InstrumentAlazar, m::AlazarMode, buffer, timeout_ms)
    @eh2 AlazarWaitAsyncBufferComplete(a.handle, buffer, timeout_ms)
    nothing
end

function wait_buffer(a::InstrumentAlazar, m::FFTRecordMode, buffer, timeout_ms)
    @eh2 AlazarDSPGetBuffer(a.handle, buffer, timeout_ms)
    nothing
end

"Waits for a buffer to be processed (or a timeout to elapse)."
wait_buffer

windowing(a::InstrumentAlazar, m::AlazarMode) = nothing

function windowing(a::InstrumentAlazar, m::FFTRecordMode)
    dspmodule = dsp_modules(a)[1]

    dsp_generatewindowfunction(a.reWindowType, Re, m)
    dsp_generatewindowfunction(a.imWindowType, Im, m)

    fft_setwindowfunction(dspmodule,
                          m.sam_per_fft,
                          m.re_window,
                          m.im_window)
end

"Set up DSP windowing if necessary, given an `InstrumentAlazar` and `AlazarMode`."
windowing
