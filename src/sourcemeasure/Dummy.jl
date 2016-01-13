export DummyStimulus

"Random number response suitable for testing the measurement code without having
a physical instrument."
immutable DummyStimulus <: Stimulus end

"Returns a random number in the unit interval."
source(ch::DummyStimulus) = nothing
