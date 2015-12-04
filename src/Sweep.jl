### Basic sweep code

export sweep#, sweeps, sweep2d

function sweep(ch0::Stimulus, ch1::Response, x_itr, tstep)
	map(x_itr) do x
    	source(ch0, x)
		sleep(tstep)
		measure(ch1)
	end
end

# function sweeps(ch0::Stimulus, ch2::Array{Response,1}, x_itr, tstep)
# 	data = Array(Float64, length(x_itr), length(ch2))
# 	for (i,x) in enumerate(x_itr)
# 		source(ch0,x)
# 		sleep(tstep)
# 		for ch in filter(x -> isa(x,BufferedResponse), ch2)
# 			trigger(ch)
# 		end
# 		for (k,ch) in enumerate(ch2)
# 			data[i,k] = isa(ch,BufferedResponse)? fetch(ch) : measure(ch)
# 		end
# 	end
# 	data
# end
#
# function sweep2d(ch0::Stimulus, ch1::Stimulus, ch2::Array{Response,1}, x_itr, y_itr, tstep)
# 	data = Array(Float64, length(x_itr), length(y_itr), length(ch1))
# 	for (j,y) in enumerate(y_itr)
# 		source(ch1,y)
# 		sleep(tstep)
# 		for (i,x) in enumerate(x_itr)
# 			source(ch0,x)
# 			sleep(tstep)
# 			for ch in filter(x -> isa(x,BufferedResponse), ch2)
# 				trigger(ch)
# 			end
# 			for (k,ch) in enumerate(ch2)
# 				data[i,j,k] = isa(ch,BufferedResponse)? fetch(ch) : measure(ch)
# 			end
# 		end
# 	end
# 	data
# end
