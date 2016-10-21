export WorkerStimulus

"""
```
type WorkerStimulus <: Stimulus
    nworkers::Int
    initialization::Expr

    _tsinfo() = info("Sourcing this WorkerStimulus will ",
        "obliterate your worker processes.")

    WorkerStimulus(a,b) = begin
        _tsinfo()
        new(a,b)
    end

    WorkerStimulus(a) = begin
        _tsinfo()
        new(0,a)
    end

    WorkerStimulus() = begin
        _tsinfo()
        new(0,:((()->nothing)()))
    end
end
```

Changes the number of Julia worker processes. An Expr object is used to
initialize new workers.
"""
type WorkerStimulus <: Stimulus
    nworkers::Int
    initialization::Expr

    _tsinfo() = info("Sourcing this WorkerStimulus will ",
        "obliterate your worker processes.")

    WorkerStimulus(a,b) = begin
        _tsinfo()
        new(a,b)
    end

    WorkerStimulus(a) = begin
        _tsinfo()
        new(0,a)
    end

    WorkerStimulus() = begin
        _tsinfo()
        new(0,:((()->nothing)()))
    end
end

show(io::IO, ch::WorkerStimulus) = print(io,
    "Will init workers with: ", ch.initialization)

"""
```
source(ch::WorkerStimulus, nw::Int)
```

Adds or removes workers to reach the desired number.
"""
function source(ch::WorkerStimulus, nw::Int)
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
