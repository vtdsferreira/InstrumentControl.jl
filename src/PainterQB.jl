module PainterQB
#
export Channel, Input, Output, BufferedInput, BufferedOutput, VirtualOutput
export PID, Calculated, Label

export AWG5014CModule, E5071CModule, E8257DModule

### Channel abstract type and subtypes
# required attributes:
# 	current value, label and unit?
# required functions:

abstract Channel

abstract Input <: Channel
abstract Output <: Channel
abstract BufferedInput <: Input
abstract BufferedOutput <: Output
abstract VirtualOutput <: Output
abstract PID <: Channel
abstract Calculated <: Input

type Label
	name::AbstractString
	unit::AbstractString
end

# Instruments and their channels
include("Instrument.jl")


include("hardware/E5071C.jl")
include("hardware/E8257D.jl")
include("hardware/AWG5014C.jl")
include("hardware/Alazar.jl/AlazarAPI.jl")
# importall .E5071CModule
# importall .E8257DModule
# importall .AWG5014CModule
# importall .AlazarModule

# Utility channels

include("Random.jl")
include("Time.jl")

# Utility functions

# include("Sweep.jl")
# include("Trace3.jl")

end

# if true
#     include("builddocs.jl")
# end
