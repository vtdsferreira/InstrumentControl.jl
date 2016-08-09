import Alazar: AlazarBits
import Base: range_1dim
import Base: localindexes

# src is assumed to be a big shared array you are indexing into;
# dest can either be the same size as the big shared array, or have
# the same size as the subrange.
function worker_tofloat!{S<:AlazarBits,T<:AbstractFloat}(src::SharedArray{S,1},
        subrange::UnitRange, dest::SharedArray{T,1})
    local st
    if size(dest) == size(subrange)
        st = start(subrange) - 1
    elseif size(dest) == size(src)
        st = 0
    else
        error("Unexpected size for `dest`.")
    end
    for i in localindexes(src, subrange)
        dest[i - st] = convert(T, src[i])
    end
    nothing
end

localindexes(S::SharedArray, subrange::UnitRange) =
    S.pidx > 0 ? range_1dim(S, subrange, S.pidx) : 1:0

function range_1dim(S::SharedArray, subrange::UnitRange, pidx)
    l = length(subrange)
    nw = length(S.pids)
    partlen = div(l, nw)
    off = start(subrange) - 1
    if l < nw
        if pidx <= l
            return (pidx:pidx) + off
        else
            return 1:0
        end
    elseif pidx == nw
        return ((((pidx-1) * partlen) + 1):l) + off
    else
        return ((((pidx-1) * partlen) + 1):(pidx*partlen)) + off
    end
end
