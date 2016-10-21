export DummyStimulus

"""
```
immutable DummyStimulus <: Stimulus end
```

Dummy stimulus suitable for testing the measurement code without having
a physical instrument.
"""
immutable DummyStimulus <: Stimulus end

"""
```
source(ch::DummyStimulus, x...)
```

Does nothing.
"""
source(ch::DummyStimulus, x...) = nothing
