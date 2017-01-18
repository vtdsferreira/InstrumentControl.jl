module GS200
import Base: getindex, setindex!
import VISA
importall InstrumentControl

returntype(::Type{Bool}) = (Int, Bool)
returntype(::Type{Real}) = (Float64, Float64)
returntype(::Type{Integer}) = (Int, Int)
fmt(v::Bool) = string(Int(v))
fmt(v) = string(v)

@generate_all(InstrumentControl.meta["GS200"])

end
