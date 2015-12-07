export AveragingResponse

type AveragingResponse{T} <: Response{T}
    r::Response{T}
    n_avg::Int
end
AveragingResponse{T}(r::Response{T}, n_avg) = AveragingResponse{T}(r,Int(n_avg))

function measure{T}(ch::AveragingResponse{T})
    meas = measure(ch.r)::T
    for i = 2:ch.n_avg
        meas += measure(ch.r)::T
    end
    meas / ch.n_avg
end
