module SMB100A
import Base: getindex, setindex!
import VISA
importall InstrumentControl     # All the stuff in InstrumentDefs, etc.

returntype(::Type{Bool}) = (Int, Bool)
returntype(::Type{Real}) = (Any, Float64)
returntype(::Type{Integer}) = (Int, Int)
fmt(v::Bool) = string(Int(v))
fmt(v) = string(v)

@generate_all(InstrumentControl.meta["SMB100A"])

end
