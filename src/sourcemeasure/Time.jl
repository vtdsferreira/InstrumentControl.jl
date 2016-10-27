import Base.reset
export DelayStimulus, TimerResponse

"""
```
type DelayStimulus <: Stimulus
    t0::Float64
    shouldreset::Bool
    axisname::Symbol
    axislabel::String
end
```

Delays until time `t0` (seconds) has passed since a reference time.
"""
type DelayStimulus <: Stimulus
	t0::Float64
    shouldreset::Bool
    axisname::Symbol
    axislabel::String
end
DelayStimulus(shouldreset=true; axisname=gensym(:delay),
    axislabel="Delay since about $(now())") =
    DelayStimulus(time(), shouldreset, axisname, axislabel)

"""
```
reset(d::DelayStimulus)
```

Reset the `DelayStimulus` reference time to now.
"""
function reset(d::DelayStimulus)
    d.t0 = time()
end

"""
```
source(ch::DelayStimulus, val::Real)
```

Wait until `val` seconds have elapsed since `ch` was initialized or reset.
Resets the `DelayStimulus` after the time has elapsed if `ch.shouldreset`.
"""
function source(ch::DelayStimulus, val::Real)
	if val < eps()
		ch.t0 = time()
	else
		while val + ch.t0 > time()
			sleep(0.01)
		end
        ch.shouldreset && reset(ch)
	end
end

"""
```
type TimerResponse <: Response
    t0::Float64
end
```

For measuring how much time has passed since a reference time `t0` (seconds).
"""
type TimerResponse <: Response
	t0::Float64
end
TimerResponse() = TimerResponse(time())

"""
```
reset(d::TimerResponse)
```

Reset the reference time to now.
"""
reset(d::TimerResponse) = (d.t0 = time())

"""
```
measure(ch::TimerResponse)
```

Returns how much time has elapsed since the timer's reference time.
"""
measure(ch::TimerResponse) = time() - ch.t0
