```@meta
DocTestSetup = quote
    using InstrumentControl
end
```

## Sweeps

This package implements a general-purpose sweep routine that is capable of
efficiently handling multidimensional sweeps. The user should never have to
write a `for` loop again. Here are the highlights:

- Any kind of sweep is initiated with [`sweep`](@ref), which returns a
  [`SweepJob`](@ref) object describing the progress, etc.
- Regardless of whether a measurement returns a scalar, a vector, a matrix, or
  some higher-order tensor, and regardless of how many axes are being swept over,
  an appropriately dimensioned, typed, and sized array is created. The result
  array can be retrieved by calling [`result`](@ref) on a `SweepJob` object.
- Sweeps are submitted to a queue where they are run when available. The
  [`status`](@ref) of a job can be queried.
- Sweeps are run asynchronously. The result arrays can be accessed while the
  measurement is running for analysis or plotting.
- Sweeps may be aborted with [`abort!`](@ref) and end at a deterministic time,
  such that the instrument states can be inferred from where the result
  terminated.
- The [`progress`](@ref) of a sweep can be monitored, and an estimated completion
  time can be provided with [`eta(::InstrumentControl.SweepJob)`](@ref).
- Sweeps may be submitted with differing priorities.

```@docs
sweep
abort!
status
progress
eta(::InstrumentControl.SweepJob)
result
```

### Sweep internals

Most of the logic behind doing sweeps is buried inside the private function
[`InstrumentControl._sweep!`](@ref). This function uses several custom macros
that simplify the multidimensional array manipulation code. All of these
are detailed below.

```@docs
InstrumentControl._sweep!
InstrumentControl.@dnref
InstrumentControl.@dntuple
InstrumentControl.@skipfirst
InstrumentControl.@respond_to_status
```

## Sweep queue

A priority queue has been implemented for running sweep jobs. Jobs with higher
priority run first; jobs with the same priority are prioritized by submission
date. You can look at the [`jobs`](@ref) in the queue and [`prune!`](@ref) jobs
which have finished or have been aborted.

```@docs
jobs
prune!
```

## Sweep types

```@docs
InstrumentControl.SweepJob
InstrumentControl.SweepStatus
InstrumentControl.Sweep
InstrumentControl.SweepQueue
```
