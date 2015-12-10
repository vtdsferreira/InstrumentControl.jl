abstract AlazarATS9440 <: InstrumentAlazar

function configure{S<:AlazarLSB, T<:AlazarLSB}(a::AlazarATS9440,
        lsb0::Type{S}, lsb1::Type{T})
    (lsb1 == AlazarLSB || lsb0 == AlazarLSB) &&
        error("Choose a subtype of AlazarLSB.")
    val0 = code(lsb0(a))
    val1 = code(lsb1(a))
    r = @eh2 AlazarConfigureLSB(a.handle, val0, val1)
    a.lsb0 = val0
    a.lsb1 = val1
    r
end
