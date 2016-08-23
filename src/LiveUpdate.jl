import HttpServer
import WebSockets
using JSON

export plotserver
# export Plottable
# export ScatterPlot
# export ScatterPoint
# export HeatmapPlot
# export HeatmapPoint
# export EndOfPlot

# Condition indicating the start of a live update.
const LIVE_NEW_MEAS = Condition()

# Condition indicating more data for a live update.
const LIVE_DATA = Condition()

# Condition indicating the end of a live update.
# Definition in the source code resembles a meditation on the human condition...
const LIVE_DIE = Condition()

abstract Plottable

type ScatterPlot <: Plottable
    message::AbstractString
    dataType::AbstractString
    xlabel::AbstractString
    ylabel::AbstractString
    ScatterPlot(a,b) = new("start","scatter",a,b)
end

type ScatterPoint
    message::AbstractString
    x::Number
    y::Number
    ScatterPoint(a,b) = new("data",a,b)
end

type HeatmapPlot <: Plottable
    message::AbstractString
    dataType::AbstractString
    xlabel::AbstractString
    ylabel::AbstractString
    xpoints::Array{Float64,1}
    ypoints::Array{Float64,1}
    HeatmapPlot(a,b,c,d) = new("start","heatmap",a,b,c,d)
end

type HeatmapPoint
    message::AbstractString
    i::Number
    j::Number
    z::Number
    HeatmapPoint(a,b,c) = new("data",a,b,c)
end

type EndOfPlot
end

function plotobj(dep::Response,
    indep::NTuple{1,Tuple{Stimulus, AbstractArray}})

    ScatterPlot(plotlabel(indep[1]),plotlabel(dep))
end

function plotobj(dep::Response,
    indep::NTuple{2,Tuple{Stimulus, AbstractArray}})

    HeatmapPlot(plotlabel(indep[1]),
                       plotlabel(indep[2]),
                       convert(Array,indep[1][2]),
                       convert(Array,indep[2][2]))
end

function plotobj{N}(dep::Response,
    indep::NTuple{N,Tuple{Stimulus, AbstractArray}})

    nothing
end

function dataobj(data, inds::NTuple{1,Int}, vals)
    ScatterPoint(vals[1], data)
end

function dataobj(data, inds::NTuple{2,Int}, vals)
    HeatmapPoint(inds[1], inds[2], data)
end

function plotlabel(dep::Response)
    return "Response"
end

function plotlabel(dep::Tuple{Stimulus, AbstractArray})
    return "Stimulus"
end

function wsproducer()

    # Producer task always runs, providing data to the web socket handler.
    while true
        loop = true

        # Wait for a new measurement to start.
        # x will be a tuple of type
        #   Tuple{Response, NTuple{N,Tuple{Stimulus, AbstractArray}}}
        x = wait(LIVE_NEW_MEAS)

        # Based on the response and stimuli deduce a plot type.
        pt = plotobj(x...)

        # Either produce the details or go back to the start of the loop
        if isa(pt, Plottable)
            produce(pt)
        else
            loop = false
        end

        while loop
            # Wait until we receive data.
            x = wait(LIVE_DATA)

            if (typeof(x) == EndOfPlot)
                loop = false
            else
                produce(dataobj(x...))
            end
        end
    end
end

function plotserver()

    # This "consumer" function runs the measurement display server.
    wsh = WebSockets.WebSocketHandler() do req,client
        # If messages were to be read from the client,
            # msg = WebSockets.read(client)

        # Task() must take an anonymous zero-parameter function
        # Iterate forever since the task never dies.
        for x in Task(() -> wsproducer())
            WebSockets.write(client, json(x))
        end
    end

    # Start the server for the WebSocket handler asynchronously
    # (don't block the notebook)
    server = HttpServer.Server(wsh)
    @async HttpServer.run(server,8081)
end
