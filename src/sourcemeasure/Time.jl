import Base.reset
export DelayStimulus, TimerResponse, TimeAResponse

"A stimulus for delaying until time has passed since a reference time t0."
type DelayStimulus <: Stimulus
	t0::AbstractFloat
end
DelayStimulus() = DelayStimulus(time())

"Reset the DelayStimulus reference time to now."
reset(d::DelayStimulus) = begin
    d.t0 = time()
end

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

"Reset the TimerResponse reference time to now."
reset(d::TimerResponse) = begin
    d.t0 = time()
end

"Returns how many seconds have elapsed since the timer was initialized or reset."
measure{T}(ch::TimerResponse{T}) = T(time()) - ch.t0

"A response for timing other responses."
type TimeAResponse <: Response{typeof(time())}
    r::Response
end

"Returns how many seconds it takes to measure the response field `ch` holds."
measure(ch::TimeAResponse) = begin
    t0 = time()
    measure(ch.r)
    time()-t0
end
