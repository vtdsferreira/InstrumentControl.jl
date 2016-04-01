module GS200
import Base: getindex, setindex!
import VISA
importall PainterQB

returntype(::Type{Bool}) = (Int, Bool)
returntype(::Type{Real}) = (Float64, Float64)
returntype(::Type{Integer}) = (Int, Int)
fmt(v::Bool) = string(Int(v))
fmt(v) = string(v)

metadata = insjson(joinpath(Pkg.dir("PainterQB"),"deps/GS200.json"))
generate_all(metadata)

end
