export PropertyStimulus

"""
Wraps any Number-valued `InstrumentProperty` into a `Stimulus`. Essentially,
sourcing a PropertyStimulus does nothing more than calling `configure` with
the associated property and value. Additional parameters to be passed to
`configure` may be specified at the time the `PropertyStimulus` is constructed.
"""
type PropertyStimulus{T<:InstrumentProperty} <: Stimulus
    ins::Instrument
    typ::Type{T}
    tuple::Tuple

    PropertyStimulus(a,b,c) = new(a,b,c)
    PropertyStimulus(a,b) = new(a,b,())
end

"Sourcing a PropertyStimulus configures an InstrumentProperty."
function source(ch::PropertyStimulus, val::Real)
    configure(ch.ins,ch.typ,val,ch.tuple...)
end
