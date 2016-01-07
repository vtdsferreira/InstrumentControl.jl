export AveragingResponse

"Response that averages other responses. Not clear if this is a good idea yet."
type AveragingResponse{T} <: Response{T}
    r::Response{T}
    n_avg::Int
end
AveragingResponse{T}(r::Response{T}, n_avg) = AveragingResponse{T}(r,Int(n_avg))

"Measures the response held by `ch` `n_avg` times, and returns the average."
function measure{T}(ch::AveragingResponse{T})
    meas = measure(ch.r)::T
    for i = 2:ch.n_avg
        meas += measure(ch.r)::T
    end
    meas / ch.n_avg
end
