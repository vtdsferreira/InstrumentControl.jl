function tofloat!(a::SharedArray{UInt16,1})
    for i in Base.localindexes(a)
        a[i] = reinterpret(UInt16,Float16(0.8*(ltoh(a[i])/0xFFF0)-0.4))
    end
    nothing
end
