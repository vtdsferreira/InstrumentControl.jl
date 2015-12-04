module PainterQB

import Base: show, showerror
export AWG5014CModule, E5071CModule, E8257DModule, AlazarModule

# Instruments
include("Instrument.jl")

# Stimuli, responses, source, measure...
include("SourceMeasure.jl")

include("hardware/E5071C.jl")
include("hardware/E8257D.jl")
include("hardware/AWG5014C.jl")
include("hardware/Alazar/InstrumentAlazar.jl")

# Not required but you can uncomment this to look for conflicting function
# definitions that should be declared global and exported in InstrumentDefs.jl:
#
importall .E5071CModule
importall .E8257DModule
importall .AWG5014CModule
importall .AlazarModule

# Utility
include("Random.jl")
include("Time.jl")

# Utility functions
include("Sweep.jl")
# include("Trace3.jl")

end

using PainterQB
using PainterQB.AWG5014CModule
using PainterQB.AlazarModule
using PainterQB.E5071CModule
using PainterQB.E8257DModule
