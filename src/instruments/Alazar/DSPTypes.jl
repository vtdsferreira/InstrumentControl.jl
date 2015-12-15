export DSPWindow
export AlazarWindow
export WindowNone
export WindowOnes
export WindowZeroes
export WindowHanning
export WindowHamming
export WindowBlackman
export WindowBlackmanHarris
export WindowBartlett

export DSPModule
export DSPModuleInfo

abstract Re
abstract Im

abstract DSPWindow
abstract AlazarWindow         <: DSPWindow
abstract WindowNone           <: AlazarWindow
abstract WindowHanning        <: AlazarWindow
abstract WindowHamming        <: AlazarWindow
abstract WindowBlackman       <: AlazarWindow
abstract WindowBlackmanHarris <: AlazarWindow
abstract WindowBartlett       <: AlazarWindow
typealias WindowOnes WindowNone

abstract WindowZeroes         <: DSPWindow

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
