export AveragingResponse

"""
`type AveragingResponse <: Response`

Response that averages other responses.
"""
type AveragingResponse{T<:Response} <: Response
    r::T
    n_avg::Int
end

"""
`measure{T<:Response}(ch::AveragingResponse{T})`

Measures the response held by `ch` `n_avg` times, and returns the average.
"""
function measure{T<:Response}(ch::AveragingResponse{T})
    meas = measure(ch.r)
    for i = 2:ch.n_avg
        meas .+= measure(ch.r)
    end
    meas / ch.n_avg
end
