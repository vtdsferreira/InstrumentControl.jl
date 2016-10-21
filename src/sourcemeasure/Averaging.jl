export AveragingResponse

"""
```
type AveragingResponse <: Response
    r::Response
    n_avg::Int
end
```

Response that averages other responses.
"""
type AveragingResponse <: Response
    r::Response
    n_avg::Int
end

"""
```
measure{T<:Response}(ch::AveragingResponse{T})
```

Measures the response held by `ch` `n_avg` times, and returns the average.
"""
function measure(ch::AveragingResponse)
    meas = measure(ch.r)
    for i = 2:ch.n_avg
        meas .+= measure(ch.r)
    end
    meas / ch.n_avg
end
