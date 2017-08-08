__precompile__(true)
module InstrumentControl
using Compat
importall ICCommon
import JSON, ZMQ

export Instrument, InstrumentProperty, Stimulus, Response
export source, measure

# Parse configuration file
include("config.jl")

# Define common types and shared functions
include("Definitions.jl")

# Define anything needed for a VISA instrument
include("VISA.jl")

# Parsing JSON files for easy instrument onboarding
include("Metaprogramming.jl")

# Sweep and queueing functionality
include("Sweep.jl")

# Generate instrument properties based on template JSON files
# insjson parses the template files
# @generate_properties takes parsed information and makes InstrumentProperty types
# we generate the instrument property types in InstrumentControl so they are not
# module specific, and can be shared among different instrument modules
const dir = joinpath(dirname(dirname(@__FILE__)), "deps", "instruments") #directory of template files
const meta = Dict{String, Any}() #dictionary to hold parsed information of template files
for x in readdir(dir) #loop through all filenames in dir
    name = split(x, ".")[1] #get filename without extension: for use as key in meta
    meta[name] = insjson(joinpath(dir, x))
    @generate_properties meta[name]
end

# Various instrument modules
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

# INITIALIZATION CODE FOLLOWS

# First make pointers (references) for objects that will be made in functions,
# thereby extending their scope beyond the function # through these pointers

# ZeroMQ is used for communication between the Julia enviroment being used for measurement
# and the ICDatabase. See ZeroMQ documentation for further details

const global ctx = Ref{ZMQ.Context}()
const global plotsock = Ref{ZMQ.Socket}()
const global dbsock = Ref{ZMQ.Socket}() #socket used to communicate to ICDatabase
const global qsock = Ref{ZMQ.Socket}() #dedicated socket used update job in ICDatabase
const global resourcemanager = Ref{UInt32}() #VISA instruments resource manager
const global sweepjobqueue = Ref{SweepJobQueue}() #default jobs queue

const global plotsockopened = Ref{Bool}(false)
const global dbsockopened = Ref{Bool}(false)
const global qsockopened = Ref{Bool}(false)

"""
    dbsocket()
Opens dbsock, the socket used to connect to the ICDatabase
"""
function dbsocket()
    if !dbsockopened[]
        dbsock[] = ZMQ.Socket(ctx[], ZMQ.REQ)
        ZMQ.connect(dbsock[], confd["dbserver"])
        dbsockopened[] = true
        # Now that the database server is connected, check that username is valid.
        validate_username(confd["username"])
    end
    return dbsock[]
end

"""
    qsocket()
Opens qsock, the socket used to connect to the ICDatabase
"""
function qsocket()
    if !qsockopened[]
        qsock[] = ZMQ.Socket(ctx[], ZMQ.REQ)
        ZMQ.connect(qsock[],  confd["dbserver"])
        qsockopened[] = true
    end
    return qsock[]
end


# Live plotting
function plotsocket()
    if !plotsockopened[]
        plotsock[] = ZMQ.Socket(ctx[], ZMQ.PUB)
        ZMQ.bind(plotsock[], "tcp://127.0.0.1:50002")
        plotsockopened[] = true
    end
    return plotsock[]
end

# Run at compile time. Initializes the ZMQ context for communication with ICDatabase,
# initializes a default SweepJobQueue object used for jobs queuing, and initializes
# a VISA instruments resource manager
function __init__()
    # ZeroMQ context
    ctx[] = ZMQ.Context()

    # VISA resource manager
    resourcemanager[] = VISA.viOpenDefaultRM()

    # Finally, set up and initialize a sweep queue.
    sweepjobqueue[] = SweepJobQueue()
end

end
