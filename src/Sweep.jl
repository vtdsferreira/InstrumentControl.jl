export sweep, eta, status, progress, abort!, prune!, jobs
using Base.Cartesian
import Compat.view
import Base: show, isless, getindex, push!, length, eta
import Base.Collections: PriorityQueue, enqueue!, dequeue!, peek
# export Sweep, SweepJob, SweepStatus

# Priorities for sweep jobs
const NEVER = -1
const LOW = 0
const NORMAL = 5
const HIGH = 10

"""
```
type Sweep
    dep::Response
    indep::Tuple{Tuple{Stimulus, AbstractVector}}
    result::Array
    Sweep(a,b) = new(a,b)
    Sweep(a,b,c) = new(a,b,c)
end
```

Object representing a sweep. `dep` (short for dependent) is a [`Response`](@ref)
that will be measured. `indep` is a tuple of [`Stimulus`](@ref) objects and the
values they will be sourced over. `result` is the result array of the sweep,
which need not be provided at the time the Sweep object is created.
"""
type Sweep
    dep::Response
    indep::Tuple{Tuple{Stimulus, AbstractVector}}
    result::Array
    Sweep(a,b) = new(a,b)
    Sweep(a,b,c) = new(a,b,c)
end

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
type SweepJob
    sweep::Sweep
    priority::Int
    job_id::Int
    has_started::Bool
    status::Channel{SweepStatus}
    progress::Channel{Float64}
    whensub::DateTime
end
```

Object representing a "sweep job," that is a sweep with some associated metadata
to play nicely with queueing and logging. `sweep` is a
[`InstrumentControl.Sweep`](@ref) object. `priority` is an `Int` from 0 to
`typemax(Int)`, inclusive, typically one of the following:

- `HIGH == 10`
- `NORMAL == 5`
- `LOW == 0`

`status` and `progress` are channels for intertask communication about the
status and progress of the sweep. `whensub` is when the `Sweep` was created,
`whenstart` is when the `Sweep` was initially run.
"""
type SweepJob
    sweep::Sweep
    priority::Int
    job_id::Int
    has_started::Bool
    status::Channel{SweepStatus}
    progress::Channel{Float64}
    whensub::DateTime
    whenstart::DateTime
end

"""
```
SweepJob(dep, indeps; priority=NORMAL_PRIORITY)
```

Initialize a `SweepJob` object given `dep` and `indeps`. Until interaction
with the database, `job_id` is set to zero and `whenstart` is temporarily
(and inaccurately) set to `whensub`.
"""
function SweepJob(dep, indeps; priority=NORMAL_PRIORITY)
    priority < 0 && error("priority must be greater than zero.")
    dt = now()
    sj = SweepJob(Sweep(dep, indeps), priority, 0, false,
        Channel{SweepStatus}(1), Channel{Float64}(1), dt, dt)
    put!(sj.status, Waiting)
    put!(sj.progress, 0.0)
    sj
end

# For PriorityQueue sorting
function isless(a::SweepJob, b::SweepJob)
    ap, bp = a.priority, b.priority
    isless(ap, bp) ||
        (ap == bp && isless(b.whensub, a.whensub))
end

function show(io::IO, s::SweepJob)
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
eta(x::SweepJob)
```

Return the estimated time of completion for sweep job `x`.
"""
function eta(x::SweepJob)
    # Check if job has started
    if !x.has_started
        error("job has not started yet.")
    end
    # Check if job has finished
    if progress(x) == 1.0
        error("job finished already.")
    end

    # returns Float64 seconds
    interval = Dates.datetime2unix(now())-Dates.datetime2unix(x.whenstart)
    interval /= progress(x)

    Dates.Millisecond(round(interval*1000.0)) + x.whenstart
end

"""
```
status(x::SweepJob)
```

Return the sweep job status.
"""
function status(x::SweepJob)
    isready(x.status) || error("status unavailable.")
    fetch(x.status)
end

"""
```
progress(x::SweepJob)
```

Returns the sweep job progress, a `Float64` between 0 and 1 (inclusive).
"""
function progress(x::SweepJob)
    isready(x.progress) || error("progress unavailable.")
    fetch(x.progress)
end

"""
```
abort!(x::SweepJob)
```

Abort a sweep job. Guaranteed to bail out of the sweep in such a way that the
data has been measured for most recent sourcing of a stimulus, i.e. at the very
start of a for loop in [`InstrumentControl._sweep!`](@ref). You can also abort a
sweep before it even begins. Presently this function does not interrupt
[`measure`](@ref), so if a single measurement takes a long time then the sweep
is only aborted after that finishes.
"""
function abort!(x::SweepJob)
    isready(x.status) || error("status unavailable.")
    oldstat = take!(x.status)
    if oldstat == Waiting || oldstat == Running
        put!(x.status, Aborted)
    else
        put!(x.status, oldstat)
        if oldstat == Done
            error("job already done.")
        else
            error("job already aborted.")
        end
    end
end

"""
```
abort!()
```

Abort the currently running job (if any). If no job is running, the method does
not throw an error.
"""
function abort!()
    sjq = sweepjobqueue
    job_id = sjq.running_id
    if job_id > 0
        abort!(sjq[job_id])
    end
end

"""
```
type SweepJobQueue
    q::PriorityQueue{Int,SweepJob,
        Base.Order.ReverseOrdering{Base.Order.ForwardOrdering}}
    running_id::Int
    update_condition::Condition
    function SweepJobQueue()
        new(PriorityQueue(Int[],SweepJob[],Base.Order.Reverse), -1, Condition())
    end
end
```

A queue responsible for prioritizing sweeps and executing them accordingly.
"""
type SweepJobQueue
    q::PriorityQueue{Int,SweepJob,
        Base.Order.ReverseOrdering{Base.Order.ForwardOrdering}}
    running_id::Int
    update_condition::Condition
    function SweepJobQueue()
        new(PriorityQueue(Int[],SweepJob[],Base.Order.Reverse), -1, Condition())
    end
end

# Base method extensions.
function show(io::IO, x::SweepJobQueue)
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

        jobs = SweepJob[]
        i = 10
        while length(x) > 0 && i > 0
            k,sj = peek(x)
            push!(jobs, sj)
            dequeue!(x,k)
            i -= 1
        end
        for sj in jobs
            show(io, Pair(sj.job_id, sj))
            enqueue!(x, sj.job_id, sj)
        end
    end
end

getindex(x::SweepJobQueue, k) = x.q[k]
enqueue!(x::SweepJobQueue, k, v) = enqueue!(x.q, k, v)
dequeue!(x::SweepJobQueue, k) = dequeue!(x.q, k)
dequeue!(x::SweepJobQueue) = dequeue!(x.q)
peek(x::SweepJobQueue) = peek(x.q)
length(x::SweepJobQueue) = length(x.q)

function push!(q::SweepJobQueue, sw::SweepJob)
    # Stick it in the queue and increment next job id
    enqueue!(q.q, sw.job_id, sw)

    # Maybe the job should be run, let's give the queue a chance to react
    notify(q.update_condition, sw)
end

"""
```
jobs()
```

Returns the default sweep job queue object. Typically you call this to see what
jobs are waiting, aborted, or finished, and what job is running.
"""
jobs() = sweepjobqueue

"""
```
jobs(job_id)
```

Return the job associated with `job_id`.
"""
jobs(job_id) = jobs()[job_id]

# Make SweepJobQueues callable
function (sq::SweepJobQueue)()
    while true
        sj = wait(sq.update_condition)
        st = status(sj)
        if st == Done || st == Aborted
            # Update stop time
            update_job_in_db(sj, jobstop=now(), jobstatus=Int(st)) ||
                error("failed to update job $(sj.job_id).")

            # set to priority lower than can be specified by the user
            dequeue!(sq.q, sj.job_id)
            sj.priority = NEVER
            enqueue!(sq.q, sj.job_id, sj)

            # Flag that nothing is running
            # (if statement in case we aborted a job that wasn't running)
            if sj.job_id == sq.running_id
                sq.running_id = -1
            end

            # Save whatever was measured, regardless of abort or done
            archive_result(sj.sweep)
        end

        if !isempty(sq.q)  # maybe unnecessary to even check
            k,sjtop = peek(sq.q)
            sttop = status(sjtop)

            # job is waiting, nothing is running, and job is runnable
            if sttop == Waiting && sq.running_id == -1 && sjtop.priority > NEVER
                take!(sjtop.status)
                put!(sjtop.status, Running)
                sjtop.whenstart = now()
                sjtop.has_started = true
                update_job_in_db(sjtop, jobstart=sjtop.whenstart,
                    jobstatus=Int(Running)) || error("failed to update job $(sjtop.job_id).")

                sq.running_id = k
            end
        end
    end
end

# Set up and initialize a sweep queue.
const sweepjobqueue = SweepJobQueue()
@async sweepjobqueue()

"""
```
prune!(q::SweepJobQueue)
```

Prunes a [`SweepJobQueue`](@ref) of all [`InstrumentControl.SweepJob`](@ref)s
with a status of `Done` or `Aborted`. This will have the side effect of releasing
old sweep results if there remain no references to them in julia, however they
should still be saved to disk and can be recovered later.
"""
function prune!(q::SweepJobQueue)
    for i in 1:length(q.q)
        s = q[i]
        st = status(s)
        if st == Done || st == Aborted
            dequeue!(q,i)
        end
    end
end

# TODO: default username and server mechanism
function new_job_in_db()::Tuple{UInt, DateTime}
    request = NewJobRequest(username="ajk", dataserver="discord")
    io = IOBuffer()
    serialize(io, request)
    ZMQ.send(dbsock, ZMQ.Message(io))

    # this is blocking, probably a more robust implementation is in order
    msg = ZMQ.recv(dbsock)
    out = convert(IOStream, msg)
    seekstart(out)
    job_id, jobsubmit = deserialize(out)
end

function update_job_in_db(sw; kwargs...)::Bool
    request = UpdateJobRequest(sw.job_id; kwargs...)
    io = IOBuffer()
    serialize(io, request)
    ZMQ.send(dbsock, ZMQ.Message(io))

    msg = ZMQ.recv(dbsock)
    out = convert(IOStream, msg)
    seekstart(out)
    deserialize(out)
end

function archive_result(sw::Sweep)

    # archive format
    Dict("data"=>sw.result)

    io = IOBuffer()


end

"""
```
sweep(dep::Response, indep::Tuple{Stimulus, AbstractVector}...;
    priority = NORMAL)
```

Measures a response as a function of an arbitrary number of stimuli, and returns
a handle to the sweep job. This can be used to access the results while the
sweep is being measured.

This function is responsible for initializing an appropriate array, preparing
a [`InstrumentControl.SweepJob`](@ref) object, and launching an asynchronous
sweep job. The actual `source` and `measure` loops are in a private function
[`InstrumentControl._sweep!`](@ref).

The `priority` keyword may be `LOW`, `NORMAL`, or `HIGH`, or any
integer greater than or equal to zero.
"""
function sweep(dep::Response, indep::Tuple{Stimulus, AbstractVector}...;
        priority = NORMAL)

    T = returntype(measure, (typeof(dep),))

    array = Array{T}([length(a) for (stim, a) in indep]...)

    # Make a new SweepJob object and assign the array we made to it
    sj = SweepJob(dep, indep; priority = priority)
    sj.sweep.result = array

    # Get a new job_id
    job_id, jobsubmit = new_job_in_db()
    sj.job_id = job_id
    sj.whensub = jobsubmit
    sj.whenstart = jobsubmit

    push!(sweepjobqueue, sj)

    t = Task(()->_sweep!(sweepjobqueue.update_condition, sj, dep, indep...))
    @async begin
        for x in t
            ZMQ.send(plotsock, ZMQ.Message(x))
        end
    end

    info("Sweep submitted with job id: $(sj.job_id)")
    sj
end


"""
```
@generated function _sweep!(updated_status_of, sj, dep::Response,
        indep::Tuple{Stimulus, AbstractVector}...)
```

This is a private function which should not be called directly by the user.
It is launched asynchronously by [`sweep`](@ref).
The implementation uses `@generated` and macros from
[Base.Cartesian](http://docs.julialang.org/en/release-0.5/devdocs/cartesian/).
The stimuli are sourced only when they need to be, at the start of each
`for` loop level.
"""
# ⚠ If the argument names are changed, change @respond_to_status also.
@generated function _sweep!(updated_status_of, sj, dep::Response,
        indep::Tuple{Stimulus, AbstractVector}...)

    N = length(indep)
    quote
        @respond_to_status

        array = sj.sweep.result
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
            it += 1; take!(sj.progress); put!(sj.progress, it/tot)

            # send forth results
            io = IOBuffer()
            serialize(io, PlotPoint((@ntuple $N i), data))
            produce(io)
        end

        take!(sj.status); put!(sj.status, Done)
        notify(updated_status_of, sj)
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
        while status(sj) == Waiting
            sleep(0.1)
        end

        if status(sj) == Aborted
            notify(updated_status_of, sj)
            return
        end
    end)
end
