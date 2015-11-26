export Instrument

abstract Instrument

# Base.show(io::IO, ins::Instrument) = print(io, "$(ins.model)")
# Define common types and shared functions
include("InstrumentDefs.jl")

# Define anything needed for a VISA instrument
include("InstrumentVISA.jl")
