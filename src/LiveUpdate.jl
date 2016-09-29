import ZMQ
using JSON

export plotserver

function plotobj(dep::Response,
    indep::NTuple{1,Tuple{Stimulus, AbstractArray}})

    PlotSetup(size(indep[1][2]), returntype(measure, (typeof(dep),));
        xlabel = plotlabel(indep[1]),
        ylabel = plotlabel(dep),
        series_type = :scatter
    )
end

# function plotobj(dep::Response,
#     indep::NTuple{2,Tuple{Stimulus, AbstractArray}})
#
#     PlotSetup(size(indep[1]plotlabel(indep[1]),
#                        plotlabel(indep[2]),
#                        convert(Array,indep[1][2]),
#                        convert(Array,indep[2][2]))
# end

function plotobj{N}(dep::Response,
    indep::NTuple{N,Tuple{Stimulus, AbstractArray}})

    nothing
end

function dataobj(inds, v)
    PlotPoint(inds, v)
end

function dataobj(data, inds::NTuple{2,Int}, vals)
    # HeatmapPoint(inds[1], inds[2], data)
end

function plotlabel(dep::Response)
    return "Response"
end

function plotlabel(dep::Tuple{Stimulus, AbstractArray})
    return "Stimulus"
end

# function plotserver(where = "tcp://127.0.0.1:50001")
#     ctx = ZMQ.Context()
#     s = ZMQ.Socket(ctx, ZMQ.PUB)
#     try
#         ZMQ.bind(s, where)
#
#         # Producer task always runs, providing data to the web socket handler.
#         while true
#             loop = true
#
#             # Wait for a new measurement to start.
#             # x will be a tuple of type
#             #   Tuple{Response, NTuple{N,Tuple{Stimulus, AbstractArray}}}
#             x = wait(LIVE_NEW_MEAS)
#             # Based on the response and stimuli deduce a plot type.
#             pt = plotobj(x...)
#
#             # Either produce the details or go back to the start of the loop
#             if isa(pt, Plottable)
#                 ZMQ.send(s, ZMQ.Message(json(pt)))
#             else
#                 loop = false
#             end
#
#             while loop
#                 # Wait until we receive data.
#                 x = wait(LIVE_DATA)
#                 println("ld")
#
#                 if typeof(x) == EndOfPlot
#                     loop = false
#                 else
#                     ZMQ.send(s, ZMQ.Message(json(dataobj(x...))))
#                 end
#             end
#         end
#     finally
#         ZMQ.close(s)
#         ZMQ.close(ctx)
#     end
# end

# function plotserver()
#
#     # This "consumer" function runs the measurement display server.
#     wsh = WebSockets.WebSocketHandler() do req,client
#         # If messages were to be read from the client,
#             # msg = WebSockets.read(client)
#
#         # Task() must take an anonymous zero-parameter function
#         # Iterate forever since the task never dies.
#         for x in Task(() -> wsproducer())
#             WebSockets.write(client, json(x))
#         end
#     end
#
#     # Start the server for the WebSocket handler asynchronously
#     # (don't block the notebook)
#     server = HttpServer.Server(wsh)
#     @async HttpServer.run(server,8081)
# end
