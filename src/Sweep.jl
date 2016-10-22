export sweep, eta, status, progress, abort!, prune!, jobs, result
using Base.Cartesian
import Base.Cartesian.inlineanonymous
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
    indep::Vector{Tuple{Stimulus, AbstractVector}}
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
    username::String
    notifications::Bool
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
`whenstart` is when the `Sweep` was initially run. `username` is who submitted
the sweep job. If `notifications` is true, status updates are sent out if
possible.
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
    username::String
    notifications::Bool
end

"""
```
SweepJob(dep, indeps; priority=NORMAL_PRIORITY, username=confd["username"],
    notifications=confd["notifications"])
```

Initialize a `SweepJob` object given `dep` and `indeps`. Until interaction
with the database, `job_id` is set to zero and `whenstart` is temporarily
(and inaccurately) set to `whensub`.
"""
function SweepJob(dep, indeps;
        priority=NORMAL, username=confd["username"],
        notifications=confd["notifications"])
    priority < 0 && error("priority must be greater than zero.")
    dt = now()
    sj = SweepJob(Sweep(dep, [indeps...]), priority, 0, false,
        Channel{SweepStatus}(1), Channel{Float64}(1), dt, dt, username,
        notifications)
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
result(sj::SweepJob)
```

Return the result array of a sweep job `sj`. Throws an error if the result array
has not yet been initialized.
"""
function result(sj::SweepJob)
    if isdefined(sj.sweep, :result)
        sj.sweep.result
    else
        error("result array has not yet been initialized.")
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
    sj = wait(sq.update_condition)
    while true
        st = status(sj)
        if st == Done || st == Aborted
            # No jobs are running right now so we can take our time
            # with the database update (no @async).
            update_job_in_db(sj, jobstop=now(), jobstatus=Int(st)) ||
                error("failed to update job $(sj.job_id).")

            # Set to priority lower than can be specified by the user
            dequeue!(sq.q, sj.job_id)
            sj.priority = NEVER
            enqueue!(sq.q, sj.job_id, sj)

            # Flag that nothing is running
            # (if statement in case we aborted a job that wasn't running)
            if sj.job_id == sq.running_id
                sq.running_id = -1
            end

            # Save whatever was measured, regardless of abort or done
            # archive_result(sj.sweep)
        end

        # Sync block ensures that the enclosed db update finishes before the
        # next db update. Updating db asynchronously so that there is no task
        # switching before we wait for the update condition.
        @sync begin
            if !isempty(sq.q)  # maybe unnecessary to even check
                k,sjtop = peek(sq.q)
                sttop = status(sjtop)

                # job is waiting, nothing is running, and job is runnable
                if sttop == Waiting && sq.running_id == -1 &&
                        sjtop.priority > NEVER

                    sjtop.whenstart = now()
                    sjtop.has_started = true
                    @async begin
                        update_job_in_db(sjtop, jobstart=sjtop.whenstart,
                        jobstatus=Int(Running)) ||
                            error("failed to update job $(sjtop.job_id).")
                    end

                    sq.running_id = k
                    take!(sjtop.status)
                    put!(sjtop.status, Running)
                end
            end
            sj = wait(sq.update_condition)
        end
    end
end

# Set up and initialize a sweep queue.
const sweepjobqueue = SweepJobQueue()
const sweepjobtask = @schedule sweepjobqueue()

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
function new_job_in_db(;username="default")::Tuple{UInt, DateTime}
    request = NewJobRequest(username=username, dataserver="local_data")
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
sweep{N}(dep::Response, indep::Vararg{Tuple{Stimulus, AbstractVector}, N};
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
function sweep{N}(dep::Response, indep::Vararg{Tuple{Stimulus, AbstractVector}, N};
    priority = NORMAL, username=confd["username"],
    notifications=confd["notifications"])

    # Make a new SweepJob object and assign the array we made to it
    sj = SweepJob(dep, indep; priority = priority, username = username,
        notifications = notifications)

    # Get a new job_id
    job_id, jobsubmit = new_job_in_db(username=username)
    sj.job_id = job_id
    sj.whensub = jobsubmit
    sj.whenstart = jobsubmit

    T = returntype(measure, (typeof(dep),))
    tup = (ndims(T), N)
    t = Task(()->_sweep!(sweepjobqueue.update_condition, sj, Val{tup}()))
    @schedule begin
        for x in t
            ZMQ.send(plotsock, ZMQ.Message(x))
        end
        take!(sj.status); put!(sj.status, Done)
        notify(sweepjobqueue.update_condition, sj)
    end

    push!(sweepjobqueue, sj)

    info("Sweep submitted with job id: $(sj.job_id)")
    sj
end


"""
```
@generated function _sweep!{T}(updated_status_of, sj, ::Val{T})
```

This is a private function which should not be called directly by the user.
It is launched asynchronously by [`sweep`](@ref).
The implementation uses `@generated` and macros from
[Base.Cartesian](http://docs.julialang.org/en/release-0.5/devdocs/cartesian/).
The stimuli are sourced only when they need to be, at the start of each
`for` loop level.

`T` is a `Tuple{Int,Int}` object where the first `Int` is the number of dimensions
coming from a single measurement, and the second `Int` is the number of independent
sweep axes.

`source` operations are assumed to commute (it should not matter what order
stimuli are `source`d for a given loop index).
"""
# ⚠
@generated function _sweep!{T}(updated_status_of, sj, ::Val{T})
    D,N = T
    quote
        # Assign some local variable names for convenience
        # and setup our progress indicator.
        indep = sj.sweep.indep
        dep = sj.sweep.dep
        it = 0; tot = reduce(*, length(indep[i][2]) for i in 1:$N)

        # Wait for job to run or be aborted
        @respond_to_status

        # Source to first value for each stimulus and do first measurement.
        @nexprs $N j->source(indep[$(N+1)-j][1], indep[$(N+1)-j][2][1])
        data = measure(dep)

        # Setup a result array with the correct shape and assign first result.
        # Update progress.
        array = Array{eltype(data)}(
            size(data)..., (length(a) for (stim, a) in indep)...)
        sj.sweep.result = array
        inds = ((@ntuple $D t->Colon())..., (@ntuple $N t->1)...)
        array[inds...] = data
        it += 1; take!(sj.progress); put!(sj.progress, it/tot)

        # Setup a plot and send our first result
        io = IOBuffer()
        serialize(io, PlotSetup(Array{eltype(data)}, size(array)))
        produce(io)
        io = IOBuffer()
        serialize(io, PlotPoint(inds, data))
        produce(io)

        (@ntuple $N t) = (@ntuple $N x->true)
        t_body = true
        @nloops $N i k->indices(array,k+$D) j->(@respond_to_status;
            @skipfirst t_j source(indep[j][1], indep[j][2][i_j])) begin

            if t_body == true
                t_body = false
            else
                data = measure(dep)
                (@dnref $D $N array i) = data

                # update progress
                it += 1; take!(sj.progress); put!(sj.progress, it/tot)

                # send forth results
                io = IOBuffer()
                serialize(io, PlotPoint((@dntuple $D $N i), data))
                produce(io)
            end
        end
    end
end

"""
```
@dnref(D, N, A, sym)
```

This is a lot like `@nref` in `Base.Cartesian`. See the Julia documentation;
the only difference here is that we are going to have the first `D` indices
be `:` (which are constructed programmatically by `Colon()`).
"""
macro dnref(D, N, A, sym)
    _dnref(D, N, A, sym)
end

function _dnref(D::Int, N::Int, A, ex)
    vars = [ inlineanonymous(ex,i) for i = 1:N ]
    Expr(:escape, Expr(:ref, A, [Colon() for i = 1:D]..., vars...))
end

"""
```
@dntuple(D, N, A, sym)
```

This is a lot like `@ntuple` in `Base.Cartesian`. See the Julia documentation;
the only difference here is that we are going to have the first `D` elements
be `:` (which may be constructed programmatically by `Colon()`).
"""
macro dntuple(D, N, ex)
    _dntuple(D, N, ex)
end

# This is a lot like @ntuple in Base.Cartesian, except we are going to have the
# first D indices be Colon().
function _dntuple(D::Int, N::Int, ex)
    vars = [ inlineanonymous(ex,i) for i = 1:N ]
    Expr(:escape, Expr(:tuple, [Colon() for i = 1:D]..., vars...))
end

"""
```
@skipfirst(t, ex)
```

Place `ex` in a code block such that `ex` is only after the first time this code
block is encountered.

`t` is a symbol bound to `true`, which is the flag for if the code block should
be skipped or not. This macro sets `t` to `false` if it is `true` or otherwise
evaluates `ex`.
"""
macro skipfirst(t, ex)
    esc(quote
        if $t == true
            $t = false
        else
            $ex
        end
    end)
end

"""
```
@respond_to_status
```

Respond to status changes during a sweep. This is the entry point for sweeps to
be paused or aborted. Not meant to be called by the user. It will break if
argument names of [`InstrumentControl._sweep!`](@ref) are modified.
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
