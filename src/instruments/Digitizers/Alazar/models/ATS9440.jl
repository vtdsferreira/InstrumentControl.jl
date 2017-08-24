"Abstract type; not implemented."
abstract AlazarATS9440 <: InstrumentAlazar

function configure(a::AlazarATS9440,
        lsb0::Type{S}, lsb1::Type{T}) where {S <: AlazarLSB,T <: AlazarLSB}
    (lsb1 == AlazarLSB || lsb0 == AlazarLSB) &&
        error("Choose a subtype of AlazarLSB.")
    val0 = code(a,lsb0)
    val1 = code(a,lsb1)
    r = @eh2 AlazarConfigureLSB(a.handle, val0, val1)
    a.lsb0 = val0
    a.lsb1 = val1
    r
end
