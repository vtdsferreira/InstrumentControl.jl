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

"Flag indicating whether the AlazarTech shared library has been opened."
lib_opened = false

using Alazar
import Base.show
importall PainterQB

export InstrumentAlazar

export inf_records

"Alazar API representation of an infinite number of records."
const inf_records = U32(0x7FFFFFFF)

"""
Abstract type representing an AlazarTech digitizer.
"""
abstract InstrumentAlazar <: Instrument

Base.show(io::IO, ins::InstrumentAlazar) = begin
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

# Model-specific type definitions and methods
include("models/ATS9360.jl")
include("models/ATS9440.jl")    # ~~not yet implemented~~

end
