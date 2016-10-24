export PropertyStimulus

"""
```
type PropertyStimulus{T<:InstrumentProperty} <: Stimulus
    ins::Instrument
    typ::Type{T}
    tuple::Tuple
    axisname::Symbol
    axislabel::String
end
```

Wraps any Number-valued `InstrumentProperty` into a `Stimulus`. Essentially,
sourcing a PropertyStimulus does nothing more than calling `setindex!` with
the associated property and value. Additional parameters to be passed to
`setindex!` may be specified at the time the `PropertyStimulus` is constructed.
"""
type PropertyStimulus{T<:InstrumentProperty} <: Stimulus
    ins::Instrument
    typ::Type{T}
    tuple::Tuple
    axisname::Symbol
    axislabel::String
end
PropertyStimulus{T}(ins::Instrument, t::Type{T}, tup=();
    axisname=gensym(lowercase(string(typ))),
    axislabel=string(typ)) =
    PropertyStimulus{T}(ins, t, tup, axisname, axislabel)

"""
```
source(ch::PropertyStimulus, val)
```

Sourcing a PropertyStimulus configures an InstrumentProperty.
"""
function source(ch::PropertyStimulus, val)
    ch.ins[ch.typ, ch.tuple...] = val
end
