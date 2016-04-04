export DependentStimulus

"""
`DependentStimulus <: Stimulus`

Permits multiple stimuli to be sourced along a given axis on a sweep.
"""
type DependentStimulus <: Stimulus
    indep::Stimulus
    dep::Tuple{Vararg{Tuple{Stimulus, Function}}}
end
DependentStimulus(i::Stimulus, d::Tuple{Stimulus, Function}...) = DependentStimulus(i, (d...,))

"""
`source(ch::DependentStimulus, val)`
"""
function source(ch::DependentStimulus, val)
    source(ch.indep, val)
    map(x->source(x[1],x[2](val)), ch.dep)
    nothing
end
