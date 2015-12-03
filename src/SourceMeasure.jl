export Stimulus, Response

export PropertyStimulus
export ThreadStimulus

export source, measure

abstract Stimulus
abstract Response

type PropertyStimulus{T<:NumericalProperty} <: Stimulus
    ins::Instrument
    typ::Type{T}
    val::AbstractFloat
    tuple::Tuple{Vararg{Int}}

    PropertyStimulus(a,b,c,d) = new(a,b,c,d)
    PropertyStimulus(a,b,c) = new(a,b,c,())
end

PropertyStimulus{T<:NumericalProperty}(a,b::Type{T},c,d) =
    PropertyStimulus{T}(a,b,c,d)

PropertyStimulus{T<:NumericalProperty}(a,b::Type{T},c) =
    PropertyStimulus{T}(a,b,c)

type ThreadStimulus <: Stimulus
    nthreads::Int
    initialization::Expr

    ThreadStimulus(a,b) = begin
        warn("Please verify that you don't care about your worker processes ",
            "before sourcing this ThreadStimulus, as it will obliterate them.")
        new(a,b)
    end

    ThreadStimulus(a) = begin
        warn("Please verify that you don't care about your worker processes ",
            "before sourcing this ThreadStimulus, as it will obliterate them.")
        new(a,:((()->nothing)()))
    end

    ThreadStimulus() = begin
        warn("Please verify that you don't care about your worker processes ",
            "before sourcing this ThreadStimulus, as it will obliterate them.")
        new(0,:((()->nothing)()))
    end
end

function source(ch::PropertyStimulus, val::Real)
    #methodexists?....
    ch.val = val
    configure(ch.ins,ch.typ,val,ch.tuple...)
end

function source(ch::ThreadStimulus, nthreads::Int)
    ch.nthreads = nthreads

    (nprocs(),nworkers()) != (1,1) &&
        rmprocs(workers())

    addprocs(ch.nthreads)

    ex = ch.initialization
    eval(:(@everywhere $ex))
end
