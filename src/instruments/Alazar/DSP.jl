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

function configure(a::InstrumentAlazar, m::FFTRecordMode)
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
