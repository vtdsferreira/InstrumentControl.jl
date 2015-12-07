module PainterQB

import Base: show, showerror
export AWG5014CModule, E5071CModule, E8257DModule, AlazarModule

# Instruments
include("Instrument.jl")

# Stimuli, responses, source, measure...
include("sourcemeasure/SourceMeasure.jl")

include("instruments/E5071C.jl")
include("instruments/E8257D.jl")
include("instruments/AWG5014C.jl")
include("instruments/Alazar/InstrumentAlazar.jl")

# Not required but you can uncomment this to look for conflicting function
# definitions that should be declared global and exported in InstrumentDefs.jl:
#
importall .E5071CModule
importall .E8257DModule
importall .AWG5014CModule
importall .AlazarModule

# Utility functions
include("Sweep.jl")
# include("Trace3.jl")

end

using PainterQB
using PainterQB.AWG5014CModule
using PainterQB.AlazarModule
using PainterQB.E5071CModule
using PainterQB.E8257DModule

const PARALLEL_PATH =
    "C:\\Users\\Discord\\Documents\\Instruments.jl\\src\\ParallelUtils.jl"

reload_parallel() = eval(Main,:(@everywhere include($PARALLEL_PATH)))
reload_parallel()
