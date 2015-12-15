export PropertyStimulus

type PropertyStimulus{T<:NumericalProperty} <: Stimulus
    ins::Instrument
    typ::Type{T}
    val::AbstractFloat
    tuple::Tuple{Vararg{Int}}

    PropertyStimulus(a,b,c,d) = new(a,b,c,d)
    PropertyStimulus(a,b,c) = new(a,b,c,())
    PropertyStimulus(a,b) = new(a,b,0.,())
end

PropertyStimulus{T<:NumericalProperty}(a,b::Type{T},c,d) =
    PropertyStimulus{T}(a,b,c,d)

PropertyStimulus{T<:NumericalProperty}(a,b::Type{T},c) =
    PropertyStimulus{T}(a,b,c)

PropertyStimulus{T<:NumericalProperty}(a,b::Type{T}) =
    PropertyStimulus{T}(a,b)

function source(ch::PropertyStimulus, val::Real)
    #methodexists?....
    ch.val = val
    configure(ch.ins,ch.typ,val,ch.tuple...)
end
