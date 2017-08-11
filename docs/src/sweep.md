# Sweeps

When thinking of measurement, one generally imagines measuring some dependent
variable with respect to some independent variable that is swept across a range
of values. While the devil is in the details of the measurement, with Julia's
multiple dispatch functionality, it should be possible to abstract executing a
"sweep" to just one function, thus affording a simple but general interface for the
user to conduct his measurements.

Moreover, the need to automate measurements and facilitate use of the same instruments
by multiple users warrants some sort of queueing structure for "sweeps", which is
maintained automatically and in the background of the Julia interface that the user is
using.

We have achieved precisely these goals in a object-oriented way with our "Sweep"
portion of IntrumentControl.jl" package. Below we describe the functionality meant
for the user: how to use `Response` and `Stimulus` objects as well as `source`
and `measure` functions to submit a sweep, how to interact with the sweep job
to see it's result, estimated time of completion, etc. In [Implementation](https://painterqubits.github.io/InstrumentControl.jl/implementation/)
we describe how exactly sweep and queueing functionality is implemented

## Prerequisites for a Sweep

A sweep is submitted by the user via the `sweep` function:

```julia
sweep{N}(dep::Response, indep::Vararg{Tuple{Stimulus, AbstractVector}, N};
    priority = NORMAL)
```

`sweep` measures a response as a function of an arbitrary number of stimuli,
sourced over the values given in the `AbstractVector` input, and returns
a handle to the sweep job in the form of a `SweepJob` object, which will be discussed more in detail in [Implementation](https://painterqubits.github.io/InstrumentControl.jl/implementation/).
This can be used to access the results while the sweep is being measured.
`priority` is an `Int` from 0 to `typemax(Int)`, inclusive, and is used to prioritize
the next sweep in a queue (with multiple sweeps) to be run. It is typically one
of the following:

- `HIGH == 10`
- `NORMAL == 5`
- `LOW == 0`

Thus, the `priority` keyword argument may be `LOW`, `NORMAL`, or `HIGH`, or any
integer greater than or equal to zero.

The `sweep` functions assumes that appropriate `measure` methods have been written
for the dep object passed, and that appropriate `source` methods have been written
for all `Stimulus` objects in the passed `indep` argument. Thus, to use the function
the user must have defined `Response` and `Stimulus` subtypes, as well as `source`
and `measure` functions for those types.

For example, ... put example here with definition of `Stimulus`, `source`, `response`,
`measure`, and `sweep`

## Queueing

InstrumentControl employs a queueing structure for job handling through manipulation
of `SweepJob` objects, which are instantiated when the `sweep` function is used.
The actual "queue" is a `SweepJobQueue` object, described more in detail in [Implementation](https://painterqubits.github.io/InstrumentControl.jl/implementation/)
When the InstrumentControl package is imported by the user, a 'SweepJobQueue' object,
as well as communication with the database set up by [ICDataServer.jl](https://github.com/PainterQubits/ICDataServer.jl),
is automatically initialized; in the documentation this object is referred to as the
"default sweep job queue object".

When `sweep` is used, a job ID is automatically
obtained for the new sweep job (which exists in Julia as a `SweepJob` object) via
communication with the database; the job is then put into the queue with the
job ID as it's identifier. In essence, a `SweepJobQueue` object can be thought of
as a *collection* (in the Julia sense) of `SweepJob` objects, indexed by their job ID,
along with other fields and helper functions for automatic scheduling of jobs in
the background. The queue prioritizes jobs based on their priorities; for equal
priority values, the job submitted earlier takes precedent

## Interacting with a sweep job

When `sweep` is called, the returned `SweepJob` object displays it's job ID as
well as it's status (waiting, running, done, etc), priority, progress
(percentage of job completed), and time of submission. Both the job ID and the returned
`SweepJob` object itself can be used to interact with the job in the following ways:

```@docs
    InstrumentControl.eta
    InstrumentControl.progress    
    InstrumentControl.jobs(::Any)
    InstrumentControl.result
    InstrumentControl.abort!
    InstrumentControl.prune!
```
