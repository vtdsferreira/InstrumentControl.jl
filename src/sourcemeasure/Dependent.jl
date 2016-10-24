export DependentStimulus

"""
```
type DependentStimulus <: Stimulus
    indep::Stimulus
    dep::Tuple{Vararg{Tuple{Stimulus, Function}}}
    axisname::Symbol
    axislabel::String
end
```

Permits multiple stimuli to be sourced along a given axis on a sweep.
"""
type DependentStimulus <: Stimulus
    indep::Stimulus
    dep::Tuple{Vararg{Tuple{Stimulus, Function}}}
    axisname::Symbol
    axislabel::String
end
DependentStimulus(i::Stimulus, d::Tuple{Stimulus, Function}...;
    axisname = gensym(:dep),
    axislabel = axislabel(indep) * "; " *
        mapreduce(x->axislabel(x[1]), (x,y)->"$x,$y", dep)) =
    DependentStimulus(i, (d...,), axisname, axislabel)

"""
```
source(ch::DependentStimulus, val)
```
"""
function source(ch::DependentStimulus, val)
    source(ch.indep, val)
    map(x->source(x[1],x[2](val)), ch.dep)
    nothing
end
