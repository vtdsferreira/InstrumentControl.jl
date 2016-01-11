import HttpServer
import WebSockets
using JSON

"Condition indicating the start of a live update."
const live_new_meas = Condition()

"Condition indicating more data for a live update."
const live_data = Condition()

"""
Condition indicating the end of a live update.
Definition in the source code resembles a meditation on the human condition...
"""
const live_die = Condition()

export ScatterMeasurement
type ScatterMeasurement
    message::ASCIIString
    dataType::ASCIIString
    xlabel::AbstractString
    ylabel::AbstractString
    ScatterMeasurement(a,b) = new("start","scatter",a,b)
end

export ScatterPoint
type ScatterPoint
    message::ASCIIString
    x::Number
    y::Number
    ScatterPoint(a,b) = new("data",a,b)
end

export HeatmapMeasurement
type HeatmapMeasurement
    message::ASCIIString
    dataType::ASCIIString
    xlabel::AbstractString
    ylabel::AbstractString
    xpoints::Array{Float64,1}
    ypoints::Array{Float64,1}
    HeatmapMeasurement(a,b,c,d) = new("start","heatmap",a,b,c,d)
end

export HeatmapPoint
type HeatmapPoint
    message::ASCIIString
    i::Number
    j::Number
    z::Number
    HeatmapPoint(a,b,c) = new("data",a,b,c)
end

export EndOfMeasurement
type EndOfMeasurement
end

function wsProducer(newMeas::Condition, moreData::Condition)

    # Producer task always runs, providing data to the web socket handler.
    while true
        loop = true

        # Wait for a new measurement to start
        produce(wait(newMeas))

        while loop
            # Wait until we receive data.
            data = wait(moreData)
            if (typeof(data) == EndOfMeasurement)
                loop = false
            else
                produce(data)
             end
        end
    end
end

# function measureServer
function measureServer()

    # This "consumer" function runs the measurement display server.
    wsh = WebSockets.WebSocketHandler() do req,client
        # If messages were to be read from the client,
            # msg = WebSockets.read(client)

        # Task() must take an anonymous zero-parameter function
        # Iterate forever since the task never dies.
        for x in Task(() -> wsProducer(live_new_meas, live_data))
            WebSockets.write(client, json(x))
        end
    end

    # Start the server for the WebSocket handler asynchronously
    # (don't block the notebook)
    server = HttpServer.Server(wsh)
    @async HttpServer.run(server,8080)
end
