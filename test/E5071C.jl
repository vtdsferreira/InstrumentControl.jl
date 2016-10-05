using InstrumentControl
using Base.Test

# ░░░░░░░░░░ WARNING ░░░░░░░░░░░
#
# The following tests may be dangerous to run if you care about the
# configuration of the instruments you are testing, or the devices
# they may be connected to.

# E5071C testing
# Start from a clean slate by resetting the instrument configuration.
rst(e5071c)

for x in (Averaging, Smoothing, AutoSweepTime)
    e5071c[x] = true
    @test e5071c[x] == e5071c[x,1]  === true
end

for x in (TriggerOutput, Output)
    e5071c[x] = true
    @test e5071c[x] === true
end

for (x,y) in [(AveragingFactor, 1),
              (FrequencyStart, 300000.0),
              (FrequencyStop, 300000.0),
              (FrequencySpan, 0.0),
              (FrequencyCenter, 300000.0),
              (IFBandwidth, 10.0),
              (PowerLevel, -85.0),
              (SmoothingAperture, 0.05)]

    e5071c[x] = -1000
    @test e5071c[x] == e5071c[x, 1] === y
end

e5071c[FrequencyStop] = 8e9
e5071c[NumPoints] = 2001
@test e5071c[NumPoints] === 2001

e5071c[TraceDisplay, 1, 1] = false
@test e5071c[TraceDisplay, 1, 1] === false
e5071c[TraceDisplay, 1, 1] = true
@test autoscale(e5071c) == nothing

e5071c[TriggerSource] = :Internal
@test e5071c[TriggerSource] == :Internal

e5071c[TriggerSlope] = :Rising
@test e5071c[TriggerSlope] == :Rising

for x in 1:10
    e5071c[SearchTracking, x] = true
    @test e5071c[SearchTracking, x] === true
    e5071c[Marker, x] = true
    @test e5071c[Marker, x] === true
    e5071c[MarkerX, x] = 4e9
    @test e5071c[MarkerX, x] === 4e9
end

for (x,y) in [(:LogMagnitude,    Float64),
              (:Phase,           Float64),
              (:GroupDelay,      Float64),
              (:SmithLinear,     Tuple{Float64, Float64}),
              (:SmithLog,        Tuple{Float64, Float64}),
              (:SmithComplex,    Complex{Float64}),
              (:Smith,           Tuple{Float64, Float64}),
              (:SmithAdmittance, Tuple{Float64, Float64}),
              (:PolarLinear,     Tuple{Float64, Float64}),
              (:PolarLog,        Tuple{Float64, Float64}),
              (:PolarComplex,    Complex{Float64}),
              (:LinearMagnitude, Float64),
              (:SWR,             Float64),
              (:RealPart,        Float64),
              (:ImagPart,        Float64),
              (:ExpandedPhase,   Float64),
              (:PositivePhase,   Float64)]
    e5071c[VNA.Format] = x
    @test typeof(e5071c[MarkerY, 1]) == y
end
