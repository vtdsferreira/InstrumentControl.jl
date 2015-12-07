export DelayStimulus, TimerResponse, TimeAResponse

"""
`DelayStimulus`

When sourced with a value in seconds, will wait until that many
seconds have elapsed since the DelayStimulus was initialized.
"""
type DelayStimulus <: Stimulus
	t0::AbstractFloat
end
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

"""
`TimerResponse`

When measured, will return how many seconds have elapsed since
the timer was initialized.
"""
type TimerResponse{T<:AbstractFloat} <: Response{T}
	t0::T
end
TimerResponse() = TimerResponse(time())
measure{T}(ch::TimerResponse{T}) = T(time()) - ch.t0

"""
`TimeAResponse`

When measured, will return how many seconds it takes to measure
the response field it holds. So meta.
"""
type TimeAResponse <: Response{typeof(time())}
    r::Response
end

measure(ch::TimeAResponse) = begin
    t0 = time()
    measure(ch.r)
    time()-t0
end
