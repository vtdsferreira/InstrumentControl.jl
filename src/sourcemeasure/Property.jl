export PropertyStimulus

"""
Wraps any Number-valued `InstrumentProperty` into a `Stimulus`. Essentially,
sourcing a PropertyStimulus does nothing more than calling `configure` with
the associated property and value. Additional parameters to be passed to
`configure` may be specified at the time the `PropertyStimulus` is constructed.
"""
type PropertyStimulus{T<:InstrumentProperty{Number}} <: Stimulus
    ins::Instrument
    typ::Type{T}
    val::AbstractFloat
    tuple::Tuple{Vararg{Int}}

    PropertyStimulus(a,b,c,d) = new(a,b,c,d)
    PropertyStimulus(a,b,c) = new(a,b,c,())
    PropertyStimulus(a,b) = new(a,b,0.,())
end

PropertyStimulus{T<:InstrumentProperty{Number}}(a,b::Type{T},c,d) =
    PropertyStimulus{T}(a,b,c,d)

PropertyStimulus{T<:InstrumentProperty{Number}}(a,b::Type{T},c) =
    PropertyStimulus{T}(a,b,c)

PropertyStimulus{T<:InstrumentProperty{Number}}(a,b::Type{T}) =
    PropertyStimulus{T}(a,b)

"Sourcing a PropertyStimulus configures an InstrumentProperty."
function source(ch::PropertyStimulus, val::Real)
    #methodexists?....
    ch.val = val
    configure(ch.ins,ch.typ,val,ch.tuple...)
end
