export Stimulus, Response

export PropertyStimulus
export ThreadStimulus

export AveragingResponse

export source, measure

abstract Stimulus
abstract Response{T}

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
    nworkers::Int
    initialization::Expr

    _tsinfo() = info("Sourcing this ThreadStimulus will ",
        "obliterate your worker processes.")

    ThreadStimulus(a,b) = begin
        _tsinfo()
        new(a,b)
    end

    ThreadStimulus(a) = begin
        _tsinfo()
        new(0,a)
    end

    ThreadStimulus() = begin
        _tsinfo()
        new(0,:((()->nothing)()))
    end
end

type AveragingResponse{T} <: Response{T}
    r::Response{T}
    n_avg::Int
end
AveragingResponse{T}(r::Response{T}, n_avg) = AveragingResponse{T}(r,Int(n_avg))

show(io::IO, ch::ThreadStimulus) = print(io,
    "Will init workers with: ", ch.initialization)

function source(ch::PropertyStimulus, val::Real)
    #methodexists?....
    ch.val = val
    configure(ch.ins,ch.typ,val,ch.tuple...)
end

# function source(ch::ThreadStimulus, nw::Int)
#     ch.nworkers = nw
#
#     (nprocs(),nworkers()) != (1,1) &&
#         rmprocs(workers())
#
#     addprocs(ch.nworkers)
#
#     ex = ch.initialization
#     eval(Main,:(@everywhere $ex))
# end
function source(ch::ThreadStimulus, nw::Int)
    ch.nworkers = nw

    if nw == 0
        rmprocs(workers())
    else
        nprocs() == 1 && (nw += 1)
        if (nworkers() > nw)
            rmprocs(workers()[(end-(nworkers() - nw - 1)):end])
        else
            addprocs(nw - nworkers())
        end
    end

    ex = ch.initialization
    try
        eval(Main,:(@everywhere $ex))
    catch
    end
end

function measure{T}(ch::AveragingResponse{T})
    meas = measure(ch.r)::T
    for i = 2:ch.n_avg
        meas += measure(ch.r)::T
    end
    meas / ch.n_avg
end
