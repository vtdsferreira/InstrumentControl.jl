## Sweep

```@docs
sweep
abort!
status
progress
eta
InstrumentControl.Sweep
InstrumentControl.SweepStatus
```

## Sweep queue

A priority queue has been implemented for running sweep jobs. Jobs with higher
priority run first; jobs with the same priority are prioritized by submission
date.

```@docs
jobs
prune!
```
