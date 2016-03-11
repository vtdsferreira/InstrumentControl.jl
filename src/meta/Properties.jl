"Creates and exports immutable singleton subtypes."
function generate_properties{S<:InstrumentProperty}(
    subtype::Symbol, supertype::Type{S}, exp::Bool=true)

    name = string(subtype)
    @eval immutable ($subtype) <: $supertype end
    exp && @eval export $subtype
end
