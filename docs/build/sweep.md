


<a id='Sweeps-1'></a>

## Sweeps

<a id='InstrumentControl.sweep' href='#InstrumentControl.sweep'>#</a>
**`InstrumentControl.sweep`** &mdash; *Function*.



```
sweep(dep::Response, indep::Tuple{Stimulus, AbstractVector}...;
    priority = NORMAL, queue = sweepqueue)
```

Measures a response as a function of an arbitrary number of stimuli, and returns a handle to the sweep job. This can be used to access the results while the sweep is being measured.

This function is responsible for initializing an appropriate array, preparing a [`InstrumentControl.Sweep`](sweep.md#InstrumentControl.Sweep) object, and launching an asynchronous sweep job. The actual `source` and `measure` loops are in a private function [`InstrumentControl._sweep!`](sweep.md#InstrumentControl._sweep!).

The `priority` keyword may be `LOW`, `NORMAL`, or `HIGH`, or any integer greater than or equal to zero. You should not provide the `queue` keyword argument unless you know what you are doing.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/ba586e2571e90ba6f07196442bee1e25d207a455/src/Sweep.jl#L332-L350' class='documenter-source'>source</a><br>

<a id='InstrumentControl._sweep!' href='#InstrumentControl._sweep!'>#</a>
**`InstrumentControl._sweep!`** &mdash; *Function*.



```
@generated function _sweep!(updated_status_of, sw, dep::Response,
        indep::Tuple{Stimulus, AbstractVector}...)
```

This is a private function which should not be called directly by the user. It is launched asynchronously by [`sweep`](sweep.md#InstrumentControl.sweep). The implementation uses `@generated` and macros from [Base.Cartesian](http://docs.julialang.org/en/release-0.5/devdocs/cartesian/). The stimuli are sourced only when they need to be, at the start of each `for` loop level.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/ba586e2571e90ba6f07196442bee1e25d207a455/src/Sweep.jl#L373-L385' class='documenter-source'>source</a><br>

<a id='InstrumentControl.abort!' href='#InstrumentControl.abort!'>#</a>
**`InstrumentControl.abort!`** &mdash; *Function*.



```
abort!(x::Sweep)
```

Abort a sweep. Guaranteed to bail out of the sweep in such a way that the data has been measured for most recent sourcing of a stimulus, i.e. at the very start of a for loop in [`InstrumentControl._sweep!`](sweep.md#InstrumentControl._sweep!). You can also abort a sweep before it even begins. Presently this function does not interrupt [`measure`](@ref), so if a single measurement takes a long time then the sweep is only aborted after that finishes.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/ba586e2571e90ba6f07196442bee1e25d207a455/src/Sweep.jl#L169-L180' class='documenter-source'>source</a><br>

<a id='InstrumentControl.status' href='#InstrumentControl.status'>#</a>
**`InstrumentControl.status`** &mdash; *Function*.



```
status(x::Sweep)
```

Return the sweep status.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/ba586e2571e90ba6f07196442bee1e25d207a455/src/Sweep.jl#L145-L151' class='documenter-source'>source</a><br>

<a id='InstrumentControl.progress' href='#InstrumentControl.progress'>#</a>
**`InstrumentControl.progress`** &mdash; *Function*.



```
progress(x::Sweep)
```

Returns the sweep progress, a `Float64` between 0 and 1 (inclusive).


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/ba586e2571e90ba6f07196442bee1e25d207a455/src/Sweep.jl#L157-L163' class='documenter-source'>source</a><br>

<a id='Base.Math.eta-Tuple{InstrumentControl.Sweep}' href='#Base.Math.eta-Tuple{InstrumentControl.Sweep}'>#</a>
**`Base.Math.eta`** &mdash; *Method*.



```
eta(x::Sweep)
```

Return the estimated time of completion for sweep `x`. WIP; will not return correct time if job has been paused.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/ba586e2571e90ba6f07196442bee1e25d207a455/src/Sweep.jl#L127-L134' class='documenter-source'>source</a><br>

<a id='InstrumentControl.Sweep' href='#InstrumentControl.Sweep'>#</a>
**`InstrumentControl.Sweep`** &mdash; *Type*.



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

Object representing a sweep. `priority` is an `Int` from 0 to `typemax(Int)`, inclusive, typically one of the following:

  * `HIGH == 10`
  * `NORMAL == 5`
  * `LOW == 0`

`status` and `progress` are channels for intertask communication about the status and progress of the sweep. `whensub` is when the `Sweep` was created, `whenstart` is when the `Sweep` was initially run. `result` is the result array of the sweep, which need not be provided at the time the `Sweep` is created.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/ba586e2571e90ba6f07196442bee1e25d207a455/src/Sweep.jl#L39-L68' class='documenter-source'>source</a><br>

<a id='InstrumentControl.SweepStatus' href='#InstrumentControl.SweepStatus'>#</a>
**`InstrumentControl.SweepStatus`** &mdash; *Type*.



```
@enum SweepStatus Waiting Running Aborted Done
```

Sweep statuses are represented with an enum.

```jlcon
julia> InstrumentControl.SweepStatus
Enum InstrumentControl.SweepStatus:
Waiting = 0
Running = 1
Aborted = 2
Done = 3
```


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/ba586e2571e90ba6f07196442bee1e25d207a455/src/Sweep.jl#L21-L36' class='documenter-source'>source</a><br>


<a id='Sweep-queue-1'></a>

## Sweep queue


A priority queue has been implemented for running sweep jobs. Jobs with higher priority run first; jobs with the same priority are prioritized by submission date.

<a id='InstrumentControl.jobs' href='#InstrumentControl.jobs'>#</a>
**`InstrumentControl.jobs`** &mdash; *Function*.



```
jobs()
```

Returns the default job queue object. Typically you call this to see what jobs are waiting, aborted, or finished, and what job is running.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/ba586e2571e90ba6f07196442bee1e25d207a455/src/Sweep.jl#L259-L266' class='documenter-source'>source</a><br>


```
jobs(job_id)
```

Return the job associated with `job_id`.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/ba586e2571e90ba6f07196442bee1e25d207a455/src/Sweep.jl#L269-L275' class='documenter-source'>source</a><br>

<a id='InstrumentControl.prune!' href='#InstrumentControl.prune!'>#</a>
**`InstrumentControl.prune!`** &mdash; *Function*.



```
prune!(q::SweepQueue)
```

Prunes a [`SweepQueue`](sweep.md#InstrumentControl.SweepQueue) of all [`InstrumentControl.Sweep`](sweep.md#InstrumentControl.Sweep)s with a status of `Done` or `Aborted`.


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/ba586e2571e90ba6f07196442bee1e25d207a455/src/Sweep.jl#L314-L321' class='documenter-source'>source</a><br>

<a id='InstrumentControl.SweepQueue' href='#InstrumentControl.SweepQueue'>#</a>
**`InstrumentControl.SweepQueue`** &mdash; *Type*.



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


<a target='_blank' href='https://github.com/painterqubits/InstrumentControl.jl/tree/ba586e2571e90ba6f07196442bee1e25d207a455/src/Sweep.jl#L187-L201' class='documenter-source'>source</a><br>

