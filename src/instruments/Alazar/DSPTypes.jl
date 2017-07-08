export DSPWindow
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

"""
Abstract parametric type representing a windowing function for DSP.
The parameter determines the method of window generation:

- `:alazar`: Use the AlazarDSP to synthesize the window
- No parameter: Use default software method

In the future, other methods may be added.
"""
@compat abstract type DSPWindow{T} end

"Flat window (ones). Implemented in AlazarDSP."
@compat abstract type WindowNone{T} <: DSPWindow{T} end

"Hanning window. Implemented in AlazarDSP."
@compat abstract type WindowHanning{T} <: DSPWindow{T} end

"Hamming window. Implemented in AlazarDSP."
@compat abstract type WindowHamming{T} <: DSPWindow{T} end

"Blackman window. Implemented in AlazarDSP."
@compat abstract type WindowBlackman{T} <: DSPWindow{T} end

"Blackman-Harris window. Implemented in AlazarDSP."
@compat abstract type WindowBlackmanHarris{T} <: DSPWindow{T} end

"Bartlett window. Implemented in AlazarDSP."
@compat abstract type WindowBartlett{T} <: DSPWindow{T} end

"Flat window (zeroes!)."
@compat abstract type WindowZeroes{T} <: DSPWindow{T} end

"Type alias for `WindowNone`."
@compat const WindowOnes{T} = WindowNone{T}

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
