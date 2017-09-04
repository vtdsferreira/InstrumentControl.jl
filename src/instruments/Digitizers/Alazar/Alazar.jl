# Julia interface to the AlazarTech SDK.
#
# Adapted from the C and Python APIs by Andrew Keller (andrew.keller.09@gmail.com)
#
# Please see the ATS-SDK Guide for detailed specification of any functions
# from the Alazar API.
#
# In our implementation a "sample" refers to a value from a single channel.
# You need to allocate memory for two values if you are measuring both channels.
#
# InstrumentAlazar: Represents a digitizer. Abstract type.

module AlazarModule

"""
    lib_opened
Flag indicating whether the AlazarTech shared library has been opened.
"""
lib_opened = false

using Alazar
import Base: show, getindex, setindex!

importall InstrumentControl
import ICCommon: Stimulus,
    Response,
    source,
    measure,
    axisname,
    axislabel

export InstrumentAlazar
export inf_records

"""
    const inf_records = U32(0x7FFFFFFF)
Alazar API representation of an infinite number of records.
"""
const inf_records = U32(0x7FFFFFFF)

"""
    abstract type InstrumentAlazar <: Instrument
Abstract type representing an AlazarTech digitizer.
"""
abstract type InstrumentAlazar <: Instrument end

function show(io::IO, ins::InstrumentAlazar)
    println(io, "$(typeof(ins)): ",
        "SystemId $(ins.systemId), BoardId $(ins.boardId)")
end

include("Errors.jl")
include("ModeTypes.jl")
include("DSPTypes.jl")
include("Properties.jl")
include("CoreFunctions.jl")
include("Configure.jl")
include("Inspect.jl")
include("ResponseTypes.jl")
include("ResponseFunctions.jl")

# # Model-specific type definitions and methods
# include(joinpath(dirname(@__FILE__), "models", "ATS9360.jl"))
# include(joinpath(dirname(@__FILE__), "models", "ATS9440.jl")) # not yet impl.
include(joinpath(dirname(@__FILE__), "models", "ATS9870.jl"))

end
