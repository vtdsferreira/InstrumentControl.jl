module PainterQB

# Define common types and shared functions
include("Definitions.jl")

# Define anything needed for a VISA instrument
include("VISA.jl")

# Stimuli, responses, source, measure...
include("sourcemeasure/SourceMeasure.jl")

# Parsing JSON files for easy instrument onboarding
include("Metaprogramming.jl")

# Various instruments
include("instruments/VNAs/VNA.jl")
include("instruments/VNAs/E5071C.jl")
# include("instruments/VNAs/ZNB20.jl")

include("instruments/E8257D.jl")
include("instruments/AWG5014C.jl")
# include("instruments/Alazar/Alazar.jl")

# Not required but you can uncomment this to look for conflicting function
# definitions that should be declared global and exported in InstrumentDefs.jl:

# importall .AlazarModule
importall .AWG5014C
importall .E5071C
importall .E8257D
# importall .ZNB20Module

# Utility functions
include("Reflection.jl")
include("Sweep.jl")
include("LiveUpdate.jl")
# include("Trace3.jl")

end

using PainterQB
using PainterQB.AWG5014C
# using PainterQB.AlazarModule
using PainterQB.VNA
using PainterQB.E5071C
using PainterQB.E8257D
# using PainterQB.ZNB20Module

const PARALLEL_PATH = joinpath(Pkg.dir("PainterQB"), "src", "ParallelUtils.jl")

reload_parallel() = eval(Main,:(@everywhere include($PARALLEL_PATH)))
reload_parallel()
