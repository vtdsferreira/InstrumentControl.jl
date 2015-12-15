export ResponseStimulus

type ResponseStimulus{T} <: Stimulus
    res::Response
    name::Symbol
    val::T
end

ResponseStimulus(res::Response,name::Symbol) = begin
    ourtype = fieldtype(typeof(res),name)
    curval = getfield(res,name)
    PropertyStimulus{ourtype}(res,name,curval)
end

function source{T}(ch::ResponseStimulus{T}, val)
    ch.val = val
    setfield!(ch.res, ch.name, val)
end
