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
abstract DSPWindow{T}

"Flat window (ones). Implemented in AlazarDSP."
abstract WindowNone{T}           <: DSPWindow{T}

"Hanning window. Implemented in AlazarDSP."
abstract WindowHanning{T}        <: DSPWindow{T}

"Hamming window. Implemented in AlazarDSP."
abstract WindowHamming{T}        <: DSPWindow{T}

"Blackman window. Implemented in AlazarDSP."
abstract WindowBlackman{T}       <: DSPWindow{T}

"Blackman-Harris window. Implemented in AlazarDSP."
abstract WindowBlackmanHarris{T} <: DSPWindow{T}

"Bartlett window. Implemented in AlazarDSP."
abstract WindowBartlett{T}       <: DSPWindow{T}

"Flat window (zeroes!)."
abstract WindowZeroes{T}         <: DSPWindow{T}

"Type alias for `WindowNone`."
typealias WindowOnes{T} WindowNone{T}

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
