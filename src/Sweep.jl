export sweep, eta, status, progress, abort!, prune!, jobs
using Base.Cartesian
using ICCommon
import Compat.view
import Base: show, isless, getindex, push!, length
import Base.Collections: PriorityQueue, enqueue!, dequeue!, peek

# Priorities for sweep jobs
const NEVER = -1
const LOW = 0
const NORMAL = 5
const HIGH = 10

import ZMQ
const ctx = ZMQ.Context()
const s = ZMQ.Socket(ctx, ZMQ.PUB)
ZMQ.bind(s, "tcp://127.0.0.1:50001")

@enum SweepStatus Waiting Running Aborted Done

"""
```
@enum SweepStatus Waiting Running Aborted Done
```

Sweep statuses are represented with an enum.

```jldoctest
julia> InstrumentControl.SweepStatus
Enum InstrumentControl.SweepStatus:
Waiting = 0
Running = 1
Aborted = 2
Done = 3
```
"""
SweepStatus

"""
```
type Sweep
    dep::Response
    indep::Tuple{Tuple{Stimulus, AbstractVector}}
    priority::Int
    job_id::Int
    has_started::Bool
    status::Channel{SweepStatus}
    progress::Channel{Float64}
    whensub::DateTime
    whenstart::DateTime
    result::Array
    Sweep(a,b,c,d,e,f,g,h,i) = new(a,b,c,d,e,f,g,h,i)
    Sweep(a,b,c,d,e,f,g,h,i,j) = new(a,b,c,d,e,f,g,h,i,j)
end
```

Object representing a sweep. `priority` is an `Int` from 0 to `typemax(Int)`,
inclusive, typically one of the following:

- `HIGH == 10`
- `NORMAL == 5`
- `LOW == 0`

`status` and `progress` are channels for intertask communication about the
status and progress of the sweep. `whensub` is when the `Sweep` was created,
`whenstart` is when the `Sweep` was initially run. `result` is the result array
of the sweep, which need not be provided at the time the `Sweep` is created.
"""
type Sweep
    dep::Response
    indep::Tuple{Tuple{Stimulus, AbstractVector}}
    priority::Int
    job_id::Int
    has_started::Bool
    status::Channel{SweepStatus}
    progress::Channel{Float64}
    whensub::DateTime
    whenstart::DateTime
    result::Array
    Sweep(a,b,c,d,e,f,g,h,i) = new(a,b,c,d,e,f,g,h,i)
    Sweep(a,b,c,d,e,f,g,h,i,j) = new(a,b,c,d,e,f,g,h,i,j)
end

"""
```
Sweep(dep, indeps; priority=NORMAL_PRIORITY)
```

Initialize a `Sweep` object given `dep` and `indeps`.
"""
function Sweep(dep, indeps; priority=NORMAL_PRIORITY)
    priority < 0 && error("priority must be greater than zero.")
    dt = now()
    sw = Sweep(dep, indeps, priority, -1, false,
        Channel{SweepStatus}(1), Channel{Float64}(1), dt, dt)
    put!(sw.status, Waiting)
    put!(sw.progress, 0.0)
    sw
end

# For PriorityQueue sorting
function isless(a::Sweep, b::Sweep)
    ap, bp = a.priority, b.priority
    isless(ap, bp) ||
        (ap == bp && isless(b.whensub, a.whensub))
end

function show(io::IO, s::Sweep)
    progstr = @sprintf "%0.2f" progress(s)*100
    progstr *= "%"
    progstr = repeat(" ", 7-length(progstr))*progstr

    st = status(s)
    ststr = if st == Waiting
        "⌛"
    elseif st == Aborted
        "☠"
    elseif st == Running
        "🏃"
    else#if st == Done
        "🏁"
    end
    prstr = ifelse(s.priority == -1, "[----]", "[⚖  $(s.priority)]")
    println(io, "[$(ststr)  $(progstr)] $(prstr) $(s.whensub)")
end

"""
```
eta(x::Sweep)
```

Return the estimated time of completion for sweep `x`. WIP; will not return
correct time if job has been paused.
"""
function eta(x::Sweep)
    # Check if job has started
    if !x.has_started
        error("job has not started yet.")
    end

    # TODO: handle paused jobs
    (now()-x.whenstart)/progress + x.whenstart
end

"""
```
status(x::Sweep)
```

Return the sweep status.
"""
function status(x::Sweep)
    isready(x.status) || error("status unavailable.")
    fetch(x.status)
end

"""
```
progress(x::Sweep)
```

Returns the sweep progress, a `Float64` between 0 and 1 (inclusive).
"""
function progress(x::Sweep)
    isready(x.progress) || error("progress unavailable.")
    fetch(x.progress)
end

"""
```
abort!(x::Sweep)
```

Abort a sweep. Guaranteed to bail out of the sweep in such a way that the
data has been measured for most recent sourcing of a stimulus, i.e. at the very
start of a for loop in [`_sweep`](@ref). You can also abort a sweep before it
even begins.
"""
function abort!(x::Sweep)
    isready(x.status) || error("status unavailable.")
    oldstat = take!(x.status)
    put!(x.status, Aborted)
end

"""
```
type SweepQueue
    q::PriorityQueue{Int,Sweep,
        Base.Order.ReverseOrdering{Base.Order.ForwardOrdering}}
    next_job_id::Int
    update_condition::Condition
    function SweepQueue()
        new(PriorityQueue(Int[],Sweep[],Base.Order.Reverse), 1, Condition())
    end
end
```

A queue responsible for prioritizing sweeps and executing them accordingly.
"""
type SweepQueue
    q::PriorityQueue{Int,Sweep,
        Base.Order.ReverseOrdering{Base.Order.ForwardOrdering}}
    next_job_id::Int
    running_id::Int
    update_condition::Condition
    function SweepQueue()
        new(PriorityQueue(Int[],Sweep[],Base.Order.Reverse), 1, -1, Condition())
    end
end
# Base method extensions.
function show(io::IO, x::SweepQueue)
    if length(x) == 0
        println(io, "No jobs in queue.")
    else
        if x.running_id != -1
            println("Running job")
            show(io, x[x.running_id])
            println(io)
        end
        println(io, "Ten highest priority jobs")
        println(io, "ID   Progress   Priority    Submitted")

        jobs = Sweep[]
        i = 10
        while length(x) > 0 && i > 0
            k,sw = peek(x)
            push!(jobs, sw)
            dequeue!(x,k)
            i -= 1
        end
        for sw in jobs
            show(io, Pair(sw.job_id, sw))
            enqueue!(x, sw.job_id, sw)
        end
    end
end

getindex(x::SweepQueue, k) = x.q[k]
enqueue!(x::SweepQueue, k, v) = enqueue!(x.q, k, v)
dequeue!(x::SweepQueue, k) = dequeue!(x.q, k)
dequeue!(x::SweepQueue) = dequeue!(x.q)
peek(x::SweepQueue) = peek(x.q)
length(x::SweepQueue) = length(x.q)

function push!(q::SweepQueue, sw::Sweep)
    # Assign a job_id
    sw.job_id = q.next_job_id

    # Stick it in the queue and increment next job id
    enqueue!(q.q, q.next_job_id, sw)
    q.next_job_id += 1

    # Maybe the job should be run, let's give the queue a chance to react
    notify(q.update_condition, sw)
end

jobs() = sweepqueue

# Make SweepQueues callable
function (sq::SweepQueue)()
    while true
        sw = wait(sq.update_condition)
        st = status(sw)
        if st == Done || st == Aborted
            # set to priority lower than can be specified by the user
            dequeue!(sq.q, sw.job_id)
            sw.priority = NEVER
            enqueue!(sq.q, sw.job_id, sw)

            # Flag that nothing is running
            # (if statement in case we aborted a job that wasn't running)
            if sw.job_id == sq.running_id
                sq.running_id = -1
            end
        end

        if !isempty(sq.q)  # maybe unnecessary to even check
            k,swtop = peek(sq.q)
            sttop = status(swtop)

            # job is waiting, nothing is running, and job is runnable
            if sttop == Waiting && sq.running_id == -1 && swtop.priority > NEVER
                take!(swtop.status)
                put!(swtop.status, Running)
                sq.running_id = k
            end
        end
    end
end

# Set up and initialize a sweep queue.
const sweepqueue = SweepQueue()
@async sweepqueue()

"""
```
prune!(q::SweepQueue)
```

Prunes a [`SweepQueue`](@ref) of all [`Sweep`](@ref)s with a status of
`Done` or `Aborted`.
"""
function prune!(q::SweepQueue)
    for i in 1:length(q.q)
        s = q[i]
        st = status(s)
        if st == Done || st == Aborted
            dequeue!(q,i)
        end
    end
end

"""
```
sweep(dep::Response, indep::Tuple{Stimulus, AbstractVector}...;
    priority = NORMAL, queue = sweepqueue)
```

Measures a response as a function of an arbitrary number of stimuli, and returns
an appropriately-sized and typed Array object. The implementation uses
`@generated` and macros from
[Base.Cartesian](http://docs.julialang.org/en/release-0.5/devdocs/cartesian/).
The stimuli are sourced only when they need to be, at the start of each
`for` loop level.

The `priority` keyword may be `LOW`, `NORMAL`, or `HIGH`.

You should not provide the `queue` keyword argument unless you know what you
are doing.
"""
function sweep(dep::Response, indep::Tuple{Stimulus, AbstractVector}...;
        priority = NORMAL, queue = sweepqueue)

    T = returntype(measure, (typeof(dep),))
    array = Array{T}([length(a) for (stim, a) in indep]...)

    sw = Sweep(dep, indep; priority = priority)
    sw.result = array
    push!(queue, sw)

    t = Task(()->_sweep!(queue.update_condition, sw, dep, indep...))
    @async begin
        for x in t
            ZMQ.send(s, ZMQ.Message(x))
        end
    end

    info("Sweep submitted with job id: $(sw.job_id)")
    sw
end

# ⚠ If the argument names are changed, change @respond_to_status also.
@generated function _sweep!(updated_status_of, sw, dep::Response,
        indep::Tuple{Stimulus, AbstractVector}...)

    N = length(indep)
    quote
        @respond_to_status

        array = sw.result
        T = eltype(array)
        io = IOBuffer()
        serialize(io, PlotSetup(Array{T}, size(array)))
        produce(io)

        it = 0; tot = reduce(*, length(indep[i][2]) for i in 1:$N)
        @nloops $N i array j->(@respond_to_status;
            source(indep[j][1], indep[j][2][i_j])) begin

            # measure
            data = measure(dep)
            (@nref $N array i) = data

            # update progress
            it += 1; take!(sw.progress); put!(sw.progress, it/tot)

            # send forth results
            io = IOBuffer()
            serialize(io, PlotPoint((@ntuple $N i), data))
            produce(io)
        end

        take!(sw.status); put!(sw.status, Done)
        notify(updated_status_of, sw)
    end
end

"""
```
@respond_to_status
```

Respond to status changes during a sweep. This is the entry point for sweeps to
be paused or aborted. Not meant to be called by the user.
"""
macro respond_to_status()
    esc(quote
        while status(sw) == Waiting
            sleep(0.1)
        end

        if status(sw) == Aborted
            notify(updated_status_of, sw)
            return
        end
    end)
end
