import Base: range_1dim
import Base: localindexes

function _tofloat!(a::SharedArray{UInt16,1})
    for i in localindexes(a)
        a[i] = reinterpret(UInt16,Float16(0.8*(ltoh(a[i])/0xFFF0)-0.4))
    end
    nothing
end

function _tofloat!(a::SharedArray{UInt16,1}, subrange::UnitRange)
    for i in localindexes(a, subrange)
        a[i] = reinterpret(UInt16,Float16(0.8*(ltoh(a[i])/0xFFF0)-0.4))
    end
    nothing
end

localindexes(S::SharedArray, subrange::UnitRange) =
    S.pidx > 0 ? range_1dim(S, subrange, S.pidx) : 1:0

function range_1dim(S::SharedArray, subrange::UnitRange, pidx)
    l = length(subrange)
    nw = length(S.pids)
    partlen = div(l, nw)

    if l < nw
        if pidx <= l
            return (pidx:pidx) + (subrange.start - 1)
        else
            return 1:0
        end
    elseif pidx == nw
        return ((((pidx-1) * partlen) + 1):l) + (subrange.start - 1)
    else
        return ((((pidx-1) * partlen) + 1):(pidx*partlen)) + (subrange.start - 1)
    end
end
