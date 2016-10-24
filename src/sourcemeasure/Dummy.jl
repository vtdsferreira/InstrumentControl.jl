export DummyStimulus, DummyResponse

"""
```
type DummyStimulus <: Stimulus
    io::IO
    axisname::Symbol
    axislabel::String
end
```

Stimulus for debugging. When sourced, it will `println` the value that was
sourced to `io`, which defaults to `STDOUT` if no argument is provided to the
constructor.
"""
type DummyStimulus <: Stimulus
    io::IO
    axisname::Symbol
    axislabel::String
end
DummyStimulus(io=STDOUT; axisname=gensym(:dumdum), axislabel="Dummy stimulus") =
    DummyStimulus(STDOUT, axisname, axislabel)

"""
```
source(ch::DummyStimulus, x...)
```

`println` the value that was sourced to `ch.io`.
"""
source(ch::DummyStimulus, x...) = println(ch.io, x...)


"""
```
type DummyResponse <: Response
    io::IO
    i::UInt64
    DummyResponse(io) = new(io,0)
end
```

Response for debugging. When measured, it will `println` the value `i` to `io`,
and then increment `i`. `io` defaults to `STDOUT` if no argument is provided.
"""
type DummyResponse <: Response
    io::IO
    i::UInt64
    DummyResponse(io) = new(io,1)
end
DummyResponse() = DummyResponse(STDOUT)

function measure(ch::DummyResponse)
    ret = ch.i
    println(ch.io, "Response: $(ch.i)")
    ch.i += 1
    ret
end
