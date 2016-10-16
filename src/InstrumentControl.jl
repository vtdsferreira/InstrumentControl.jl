module InstrumentControl

# Define common types and shared functions
include("definitions.jl")

# Define anything needed for a VISA instrument
include("VISA.jl")

# Stimuli, responses, source, measure...
include(joinpath("sourcemeasure","sourcemeasure.jl"))

# Parsing JSON files for easy instrument onboarding
include("metaprogramming.jl")

# Various instruments
include(joinpath("instruments","VNAs","VNA.jl"))
include(joinpath("instruments","VNAs","E5071C.jl"))
# include(joinpath("instruments","VNAs","ZNB20.jl"))

include(joinpath("instruments","SMB100A.jl"))
include(joinpath("instruments","E8257D.jl"))
include(joinpath("instruments","AWG5014C.jl"))
include(joinpath("instruments","GS200.jl"))

include(joinpath("instruments","Alazar","Alazar.jl"))
# Not required but you can uncomment this to look for conflicting function
# definitions that should be declared global and exported in InstrumentDefs.jl:

importall .AlazarModule
importall .AWG5014C
importall .E5071C
importall .E8257D
importall .GS200
importall .SMB100A
# importall .ZNB20Module

# Utility functions
include("reflection.jl")
include("sweep.jl")
# include("LiveUpdate.jl")   # <--- causes Documenter to fail?
# include("Trace3.jl")

end

using InstrumentControl
using InstrumentControl.AWG5014C
using InstrumentControl.AlazarModule
using InstrumentControl.VNA
using InstrumentControl.E5071C
using InstrumentControl.E8257D
using InstrumentControl.GS200
using InstrumentControl.SMB100A
# using InstrumentControl.ZNB20Module

const PARALLEL_PATH = joinpath(Pkg.dir("InstrumentControl"), "src", "parallelutils.jl")

reload_parallel() = eval(Main,:(@everywhere include($PARALLEL_PATH)))
reload_parallel()
