export ResponseStimulus

"""
```
type ResponseStimulus{T} <: Stimulus
    res::Response
    name::Symbol
    val::T
end
```

Esoteric stimulus to consider changing the fields of a `Response` as a stimulus.
Sounds absurd at first, but could be useful if the fields of a `Response` affect
how that `Response` is measured. For instance, this may be useful to change
`n_avg` in the `AveragingResponse` to see the effect of averaging.
"""
type ResponseStimulus{T} <: Stimulus
    res::Response
    name::Symbol
    val::T
end

ResponseStimulus(res::Response, name::Symbol) = begin
    ourtype = fieldtype(typeof(res), name)
    curval = getfield(res, name)
    ResponseStimulus{ourtype}(res,name,curval)
end

"""
```
source(ch::ResponseStimulus, val)
```

Sets the field named `:name` in the `Response` held by `ch` to `val`.
"""
function source(ch::ResponseStimulus, val)
    ch.val = val
    setfield!(ch.res, ch.name, val)
end
