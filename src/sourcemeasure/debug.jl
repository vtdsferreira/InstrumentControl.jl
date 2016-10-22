export DebugStimulus
export DebugResponse

"""
```
type DebugStimulus <: Stimulus
    io::IO
end
```

Stimulus for debugging. When sourced, it will `println` the value that was
sourced to `io`, which defaults to `STDOUT` if no argument is provided to the
constructor.
"""
type DebugStimulus <: Stimulus
    io::IO
end
DebugStimulus() = DebugStimulus(STDOUT)

"""
```
source(ch::DummyStimulus, x...)
```

`println` the value that was sourced to `ch.io`.
"""
source(ch::DebugStimulus, x...) = println(ch.io, x...)

"""
```
type DebugResponse <: Response
    io::IO
    i::UInt64
    DebugResponse(io) = new(io,0)
end
```

Response for debugging. When measured, it will `println` the value `i` to `io`,
and then increment `i`. `io` defaults to `STDOUT` if no argument is provided.
"""
type DebugResponse <: Response
    io::IO
    i::UInt64
    DebugResponse(io) = new(io,1)
end
DebugResponse() = DebugResponse(STDOUT)

function measure(ch::DebugResponse)
    ret = ch.i
    println(ch.io, "Response: $(ch.i)")
    ch.i += 1
    ret
end
