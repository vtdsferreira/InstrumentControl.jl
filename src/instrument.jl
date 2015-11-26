export Instrument

"""
### Instrument
`abstract Instrument <: Any`

Abstract supertype of all concrete Instrument types, e.g.
`AWG5014C <: Instrument`.
"""
abstract Instrument

# Base.show(io::IO, ins::Instrument) = print(io, "$(ins.model)")
# Define common types and shared functions
include("InstrumentDefs.jl")

# Define anything needed for a VISA instrument
include("InstrumentVISA.jl")
