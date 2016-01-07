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

"Abstract type representing a windowing function for DSP."
abstract DSPWindow

"""
Abstract type representing a windowing function for DSP, built into the
AlazarDSP API.
"""
abstract AlazarWindow         <: DSPWindow

"Flat window (ones)."
abstract WindowNone           <: AlazarWindow

"Hanning window."
abstract WindowHanning        <: AlazarWindow

"Hamming window."
abstract WindowHamming        <: AlazarWindow

"Blackman window."
abstract WindowBlackman       <: AlazarWindow

"Blackman-Harris window."
abstract WindowBlackmanHarris <: AlazarWindow

"Bartlett window."
abstract WindowBartlett       <: AlazarWindow

"Type alias for `WindowNone`."
typealias WindowOnes WindowNone

"Flat window (zeroes!)."
abstract WindowZeroes         <: DSPWindow

"Represents a DSP module of an AlazarTech digitizer."
type DSPModule
    ins::InstrumentAlazar
    handle::dsp_module_handle
end

"Encapsulates DSP module information: type, version, and max record length."
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
