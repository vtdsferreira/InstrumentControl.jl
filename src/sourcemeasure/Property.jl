export PropertyStimulus

"""
```
PropertyStimulus{T<:InstrumentProperty} <: Stimulus
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

    PropertyStimulus(a,b,c) = new(a,b,c)
    PropertyStimulus(a,b) = new(a,b,())
end
PropertyStimulus{T}(ins::Instrument, t::Type{T}) =
    PropertyStimulus{T}(ins, t)
PropertyStimulus{T}(ins::Instrument, t::Type{T}, tup::Tuple) =
    PropertyStimulus{T}(ins, t, tup)

"""
```
source(ch::PropertyStimulus, val)
```

Sourcing a PropertyStimulus configures an InstrumentProperty.
"""
function source(ch::PropertyStimulus, val)
    ch.ins[ch.typ, ch.tuple...] = val
end
