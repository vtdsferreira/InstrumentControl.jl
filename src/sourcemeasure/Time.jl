import Base.reset
export DelayStimulus, TimerResponse, TimeAResponse

"""
`type DelayStimulus <: Stimulus`

Delays until time `t0` (seconds) has passed since a reference time.
"""
type DelayStimulus <: Stimulus
	t0::AbstractFloat
end
DelayStimulus() = DelayStimulus(time())

"""
`reset(d::DelayStimulus)`

Reset the `DelayStimulus` reference time to now.
"""
reset(d::DelayStimulus) = (d.t0 = time())

"Wait until `val` seconds have elapsed since `ch` was initialized or reset."
function source(ch::DelayStimulus, val::Real)
	if val < eps()
		ch.t0 = time()
	else
		while val + ch.t0 > time()
			sleep(0.01)
		end
	end
end

"A response for measuring how much time has passed since a reference time t0."
type TimerResponse{T<:AbstractFloat} <: Response{T}
	t0::T
end
TimerResponse() = TimerResponse(time())

"""
`reset(d::TimerResponse)`

Reset the `TimerResponse` reference time to now.
"""
reset(d::TimerResponse) = (d.t0 = time())

"""
Returns ho
"""
measure{T}(ch::TimerResponse{T}) = T(time()) - ch.t0
