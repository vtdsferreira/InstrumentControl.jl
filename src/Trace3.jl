### Trace: sweep and plot in real time. Save data into filesystem.

export produce_datum, trace1d, trace2d, traces, wsProducer, measureServer

import HttpServer
import WebSockets
using JSON

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

function trace1d(chOut::Output, chIn::Input, x_itr, tstep, newMeas::Condition, moreData::Condition)


	# Notify our display server that this is a new measurement, and provide layout info
	notify(newMeas, ScatterMeasurement("x","y"))
	yArray = Array{Float64,1}()

	for (i,x) in enumerate(x_itr)
		source(chOut, x)
		sleep(tstep)
		y = measure(chIn)
		push!(yArray,y)
		# In the future, we need to figure out a better way
		sleep(0.001)
		notify(moreData, ScatterPoint(x,y))
	end

	sleep(0.001)
	notify(moreData, EndOfMeasurement())
	yield()

	(convert(Array,x_itr),yArray)
end

function trace2d(chX::Output, chY::Output, chIn::Input, x_itr, y_itr, tstep, newMeas::Condition, moreData::Condition)

	# Notify our display server that this is a new measurement, and provide layout info
	notify(newMeas, HeatmapMeasurement("x","y",convert(Array,x_itr),convert(Array,y_itr)))
	zArray = Array{Float64,1}()

	for (i,x) in enumerate(x_itr)
		source(chX, x)
		for (j,y) in enumerate(y_itr)
			source(chY, y)
			sleep(tstep)
			z = measure(chIn)
			push!(zArray,z)
			# In the future, we need to figure out a better way
			sleep(0.001)
			notify(moreData, HeatmapPoint(i-1,j-1,z))
		end
	end

	sleep(0.001)
	notify(moreData, EndOfMeasurement())
	yield()

	(convert(Array,x_itr),convert(Array,y_itr),zArray)
end

function wsProducer(newMeas::Condition,moreData::Condition)
  # Producer task always runs, providing data to the web socket handler.
	while true

		loop = true

		# Wait for a new measurement to start
		produce(wait(newMeas))
	#	lock(l)

		while loop
			# Wait until we receive data.
#			unlock(l)
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
# newMeas::Condition 		defines the beginning of a measurement
# moreData::Condition		defines a new data point
function measureServer(newMeas::Condition,moreData::Condition)

	# This "consumer" function runs the measurement display server.
	wsh = WebSockets.WebSocketHandler() do req,client

		# If messages were to be read from the client,
			# msg = WebSockets.read(client)

		# x can take on any type
		# Task() must take an anonymous zero-parameter function
		for x in Task(() -> wsProducer(newMeas,moreData))

			# Whatever x is, output it as JSON to the WebSockets
			WebSockets.write(client, json(x))

			# Iterate forever since the task never dies.
	  end
	end

	# Start the server for the WebSocket handler asynchronously
	# (don't block the notebook)
	server = HttpServer.Server(wsh)
  @async HttpServer.run(server,8080)
end


### OLD CODE ###

function traces(ch0::Output, ch2::Array{Input,1}, x_itr, tstep)
	n = length(ch1)
	data = Array(Float64, length(x_itr), n)
	figure()
	for (i,x) in enumerate(x_itr)
		source(ch0,x)
		sleep(tstep)
		for ch in filter(x -> isa(x,BufferedInput), ch2)
			trigger(ch)
		end
		for (k,ch) in enumerate(ch2)
			subplot(n, 1, k)
			data[i,k] = isa(ch,BufferedInput)? fetch(ch) : measure(ch)
		end
	end
	data
end
