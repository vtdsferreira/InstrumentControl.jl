export dspNumModules, dspModules, dspGetModuleHandles, dspGetInfo
export dspGenerateWindowFunction, dspGetBuffer, dspAbortCapture
export fftSetWindowFunction, fftVerificationMode, fftSetup

immutable DSPModuleType{T}
end
describe(::Type{DSPModuleType{DSP_MODULE_NONE}}) = "No DSP module"
describe(::Type{DSPModuleType{DSP_MODULE_FFT}})  = "FFT module"
describe(::Type{DSPModuleType{DSP_MODULE_PCD}})  = "PCD module"

Base.show{T<:DSPModuleType}(io::IO, a::Type{T}) = print(io, describe(a))

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

function dspNumModules(a::InstrumentAlazar)
    numModules = Array{U32}(1)
    numModules[1] = U32(0)
    r = ccall((:AlazarDSPGetModules,ats), U32,
        (U32,U32,Ptr{DSPModuleHandle},Ptr{U32}), a.handle, 0, C_NULL, numModules)
    if r != noError
        throw(InstrumentException(a,r))
    end
    numModules[1]
end

function dspModules(a::InstrumentAlazar)
    a.dspModules
end

function dspGetModuleHandles(a::InstrumentAlazar)
    numModules = dspNumModules(a)
    if numModules == 0
        error("No DSP modules to get.")
    end

    modules = Array(DSPModuleHandle,numModules)

    r = ccall((:AlazarDSPGetModules,ats), U32,
        (U32,U32,Ptr{DSPModuleHandle},Ptr{U32}),
        a.handle, numModules, modules, C_NULL)
    if r != noError
        throw(InstrumentException(a,r))
    end

    modules
end

# The InstrumentAlazar is only used for throwing exceptions
function dspGetInfo(dspModule::DSPModule)

    dspModuleId = Array(U32,1)
    dspModuleId[1] = 0

    versionMajor = Array(U16,1)
    versionMajor[1] = 0

    versionMinor = Array(U16,1)
    versionMinor[1] = 0

    maxLength = Array(U32,1)
    maxLength[1] = 0

    r = ccall((:AlazarDSPGetInfo,ats), U32,
        (DSPModuleHandle,Ptr{U32},Ptr{U16},Ptr{U16},Ptr{U32},Ptr{U32},Ptr{U32}),
        dspModule.handle, dspModuleId, versionMajor, versionMinor,
        maxLength, C_NULL, C_NULL)
    if r != noError
        throw(InstrumentException(dspModule.ins,r))
    end

    DSPModuleInfo(dspModuleId[1], versionMajor[1], versionMinor[1], maxLength[1])
end

function dspGenerateWindowFunction(windowType,
        windowLength_samples, paddingLength_samples)

    window = Array(Cfloat, windowLength_samples + paddingLength_samples)
    r = ccall((:AlazarDSPGenerateWindowFunction,ats), U32,
        (U32, Ptr{Cfloat}, U32, U32), windowType, window,
        windowLength_samples, paddingLength_samples)
    if r != noError
        error(except(r))
    end

    window
end

function fftSetWindowFunction(dspModule::DSPModule, samplesPerRecord, reArray, imArray)
    r = ccall((:AlazarFFTSetWindowFunction,ats), U32,
        (DSPModuleHandle,U32,Ptr{Cfloat},Ptr{Cfloat}),
        dspModule.handle, samplesPerRecord, reArray, imArray)
    if r != noError
        throw(InstrumentException(dspModule.ins,r))
    end
end

# Undocumented in API. Let's hide this one for now...
# function fftVerificationMode(dspModule::DSPModule, enable,
#         reArray, imArray, recordLength_samples)
#     r = ccall((:AlazarFFTVerificationMode,ats), U32,
#         (DSPModuleHandle,Bool,Ptr{S16},Ptr{S16},size_t),
#         dspModule.handle, enable, reArray, imArray, recordLength_samples)
#     if (r != noError)
#         throw(InstrumentException(dspModule.ins,r))
#     end
# end

function fftSetup(dspModule::DSPModule, recordLength_samples, fftLength_samples,
        outputFormat, footer)

    bytesPerOutputRecord = Array(U32,1)
    bytesPerOutputRecord[1] = 0

    r = ccall((:AlazarFFTSetup,ats), U32,
        (DSPModuleHandle, U16, U32, U32, U32, U32, U32, Ptr{U32}),
        dspModule.handle, CHANNEL_A, recordLength_samples, fftLength_samples,
        outputFormat, footer, U32(0), bytesPerOutputRecord)
    if r != noError
        throw(InstrumentException(dspModule.ins,r))
    end

    bytesPerOutputRecord[1]
end

@eh dspGetBuffer(a::InstrumentAlazar, buffer, timeout_ms) =
    ccall((:AlazarDSPGetBuffer,ats), U32, (U32, Ptr{Void}, U32),
    a.handle, buffer, timeout_ms)

@eh dspAbortCapture(a::InstrumentAlazar) =
    ccall((:AlazarDSPAbortCapture,ats), U32, (U32,), a.handle)
