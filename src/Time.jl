### time.jl a fake output instrument for inputs over time
# sourcing 0 or negative time resets clock.
# sourcing positive value returns

export DelayStimulus, TimerResponse

type DelayStimulus <: Stimulus
	t0::Float64
end

type TimerResponse <: Response
	t0::Float64
end

TimerResponse() = TimerResponse(time())
DelayStimulus() = DelayStimulus(time())

function source(ch::DelayStimulus, val::Real)
	if val < eps()
		ch.t0 = time()
	else
		while val + ch.t0 > time()
			sleep(0.01)
		end
	end
end

measure(ch::TimerResponse) = time() - ch.t0
