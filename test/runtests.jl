using PainterQB
using Base.Test

# ░░░░░░░░░░ WARNING ░░░░░░░░░░░
#
# The following tests may be dangerous to run if you care about the
# configuration of the instruments you are testing, or the devices
# they may be connected to.

# E5071C testing
# Start from a clean slate by resetting the instrument configuration.
rst(e5071c)

for x in [Averaging, Smoothing]
    configure(e5071c, x, true)
    @test inspect(e5071c, x) == inspect(e5071c, x, 1) === true
end

for x in [TriggerOutput, Output]
    configure(e5071c, x, true)
    @test inspect(e5071c, x) === true
end

for (x,y) in [(AveragingFactor, 1),
              (FrequencyStart, 300000.0),
              (FrequencyStop, 300000.0),
              (FrequencySpan, 0.0),
              (FrequencyCenter, 300000.0),
              (IFBandwidth, 10.0),
              (PowerLevel, -85.0),
              (SmoothingAperture, 0.05)]

    configure(e5071c, x, -1000)
    @test inspect(e5071c, x) == inspect(e5071c, x, 1) === y
end

configure(e5071c, NumPoints, 2001)
@test inspect(e5071c, NumPoints) === 2001

configure(e5071c, TraceDisplay, false, 1, 1)
@test inspect(e5071c, TraceDisplay, 1, 1) === false
configure(e5071c, TraceDisplay, true, 1, 1)
@test autoscale(e5071c) == nothing

configure(e5071c, InternalTrigger)
@test inspect(e5071c, TriggerSource) == InternalTrigger

for x in 1:10
    configure(e5071c, SearchTracking, x, true)
    @test inspect(e5071c, SearchTracking, x) === true
    configure(e5071c, Marker, x, true)
    @test inspect(e5071c, Marker, x) === true
    configure(e5071c, MarkerX, x, 4e9)
    @test inspect(e5071c, MarkerX, x) === 4e9
end
