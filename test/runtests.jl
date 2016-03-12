using PainterQB
using Base.Test

# ░░░░░░░░░░ WARNING ░░░░░░░░░░░
#
# The following tests may be dangerous to run if you care about the
# configuration of the instruments you are testing, or the devices
# they may be connected to.

# E5071C testing
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
