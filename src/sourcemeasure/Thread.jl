export ThreadStimulus

"""
`type ThreadStimulus <: Stimulus`

Changes the number of Julia worker threads. An Expr object is used to
initialize new threads.
"""
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

show(io::IO, ch::ThreadStimulus) = print(io,
    "Will init workers with: ", ch.initialization)

"""
`source(ch::ThreadStimulus, nw::Int)`

Adds or removes threads to reach the desired number of worker threads.
"""
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
