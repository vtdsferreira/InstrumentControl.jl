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
    abstract type DSPWindow{T}
Abstract type representing a windowing function for DSP. The parameter determines the
method of window generation:

- `:alazar`: Use the AlazarDSP to synthesize the window
- No parameter: Use default software method

In the future, other methods may be added.
"""
abstract type DSPWindow{T} end

"""
    abstract type WindowNone{T} <: DSPWindow{T}
Flat window (ones). Implemented in AlazarDSP.
"""
abstract type WindowNone{T} <: DSPWindow{T} end

"""
    abstract type WindowHanning{T} <: DSPWindow{T}
Hanning window. Implemented in AlazarDSP.
"""
abstract type WindowHanning{T} <: DSPWindow{T} end

"""
    abstract type WindowHamming{T} <: DSPWindow{T}
Hamming window. Implemented in AlazarDSP.
"""
abstract type WindowHamming{T} <: DSPWindow{T} end

"""
    abstract type WindowBlackman{T} <: DSPWindow{T}
Blackman window. Implemented in AlazarDSP.
"""
abstract type WindowBlackman{T} <: DSPWindow{T} end

"""
    abstract type WindowBlackmanHarris{T} <: DSPWindow{T}
Blackman-Harris window. Implemented in AlazarDSP.
"""
abstract type WindowBlackmanHarris{T} <: DSPWindow{T} end

"""
    abstract type WindowBartlett{T} <: DSPWindow{T}
Bartlett window. Implemented in AlazarDSP.
"""
abstract type WindowBartlett{T} <: DSPWindow{T} end

"""
    abstract type WindowZeroes{T} <: DSPWindow{T}
Flat window (zeroes!).
"""
abstract type WindowZeroes{T} <: DSPWindow{T} end

"""
    const WindowOnes{T} = WindowNone{T}
Type alias for `WindowNone`.
"""
const WindowOnes{T} = WindowNone{T}

"""
    mutable struct DSPModule
        ins::InstrumentAlazar
        handle::dsp_module_handle
    end
Represents a DSP module of an AlazarTech digitizer.
"""
mutable struct DSPModule
    ins::InstrumentAlazar
    handle::dsp_module_handle
end

"""
    struct DSPModuleInfo
        dsp_module_id::U32
        version_major::U16
        version_minor::U16
        max_record_length::U32
    end
Encapsulates DSP module information: type, version, and max record length.
"""
struct DSPModuleInfo
    dsp_module_id::U32
    version_major::U16
    version_minor::U16
    max_record_length::U32
end

Base.show(io::IO, x::DSPModuleInfo) = print(io,
    string("$(DSPModuleType{x.dsp_module_id}) ",
           "v$(Int(x.version_major)).$(Int(x.version_minor)); ",
           "max record length: $(x.max_record_length)"))

struct DSPModuleType{T} end
describe(::Type{DSPModuleType{Alazar.DSP_MODULE_NONE}}) = "No DSP module"
describe(::Type{DSPModuleType{Alazar.DSP_MODULE_FFT}})  = "FFT module"
describe(::Type{DSPModuleType{Alazar.DSP_MODULE_PCD}})  = "PCD module"
Base.show(io::IO, a::Type{T}) where {T <: DSPModuleType} = print(io, describe(a))
