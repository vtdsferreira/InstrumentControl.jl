__precompile__(true)
module InstrumentControl
importall ICCommon
import JSON, ZMQ

export Instrument, InstrumentProperty, Stimulus, Response

function __init__()
    # ZeroMQ context
    const global ctx = ZMQ.Context()

    # Live plotting
    const global plotsock = ZMQ.Socket(ctx, ZMQ.PUB)
    ZMQ.bind(plotsock, "tcp://127.0.0.1:50002")

    # Database server connection
    const global dbsock = ZMQ.Socket(ctx, ZMQ.REQ)
    ZMQ.connect(dbsock, confd["dbserver"])

    const global qsock = ZMQ.Socket(ctx, ZMQ.REQ)
    ZMQ.connect(qsock, confd["dbserver"])

    # Now that the database server is connected, check that username is valid.
    validate_username(confd["username"])

    const global PARALLEL_PATH = joinpath(dirname(@__FILE__), "parallelutils.jl")
    eval(Main, :(@everywhere include($PARALLEL_PATH)))

    # VISA resource manager
    const global resourcemanager = VISA.viOpenDefaultRM()

    # Finally, set up and initialize a sweep queue.
    const global sweepjobqueue = SweepJobQueue()
    const global sweepjobtask = @schedule sweepjobqueue()
end

# Parse configuration file
include("config.jl")

# Define common types and shared functions
include("definitions.jl")

# Define anything needed for a VISA instrument
include("visa.jl")

# Parsing JSON files for easy instrument onboarding
include("metaprogramming.jl")

# Generate instrument properties based on the template files
const dir = joinpath(dirname(dirname(@__FILE__)), "deps", "instruments")
const meta = Dict{String, Any}()
for x in readdir(dir)
    name = split(x, ".")[1]
    meta[name] = insjson(joinpath(dir, x))
    @generate_properties meta[name]
end

# Various instruments
include(joinpath(dirname(@__FILE__), "instruments", "VNAs", "VNA.jl"))
include(joinpath(dirname(@__FILE__), "instruments", "VNAs", "E5071C.jl"))
# include(joinpath("instruments","VNAs","ZNB20.jl"))

include(joinpath(dirname(@__FILE__), "instruments", "SMB100A.jl"))
include(joinpath(dirname(@__FILE__), "instruments", "E8257D.jl"))
include(joinpath(dirname(@__FILE__), "instruments", "AWG5014C.jl"))
include(joinpath(dirname(@__FILE__), "instruments", "GS200.jl"))

include(joinpath(dirname(@__FILE__), "instruments", "Alazar", "Alazar.jl"))

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

end
#
using InstrumentControl
using InstrumentControl.AWG5014C
using InstrumentControl.AlazarModule
using InstrumentControl.VNA
using InstrumentControl.E5071C
using InstrumentControl.E8257D
using InstrumentControl.GS200
using InstrumentControl.SMB100A
# # using InstrumentControl.ZNB20
