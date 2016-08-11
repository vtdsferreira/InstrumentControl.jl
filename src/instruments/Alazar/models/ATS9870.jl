export AlazarATS9870

"""
Concrete InstrumentAlazar subtype representing an ATS9870 digitizer.

Defaults are selected as:

- DC coupling for channels A, B and external trigger input.
- Input range +/- 0.4V for channel A, B.
- External trigger range: 5 V. Cannot be changed for the ATS9870.
- All impedances 50 Ohm. Cannot be changed for the ATS9870.
- Internal clock, 1 GSps, rising edge.
- Trigger on J; engine J fires when channel A crosses zero from below.
- Trigger delay 0 samples; no trigger timeout
- Acquire with both channels
- AUX IO outputs a trigger signal synced to the sample clock.
"""
type AlazarATS9870 <: InstrumentAlazar

    systemId::Culong
    boardId::Culong
    handle::Culong

    couplingA::Symbol
    couplingB::Symbol
    rangeA::Symbol
    rangeB::Symbol

    clockSource::Symbol
    sampleRate::U32
    clockSlope::Symbol
    decimation::U32

    triggerCoupling::Symbol
    triggerRange::Symbol

    engine::Symbol
    sourceJ::Symbol
    slopeJ::Symbol
    levelJ::AbstractFloat
    sourceK::Symbol
    slopeK::Symbol
    levelK::AbstractFloat

    triggerDelaySamples::U32
    triggerTimeoutTicks::U32

    auxIOMode::Symbol
    auxInTriggerSlope::Symbol
    auxOutDivider::U32
    auxOutTTLLevel::Symbol
    auxOutTriggerEnable::Bool

    acquisitionChannel::Symbol
    channelCount::U32

    # defaults
    inputcontrol_defaults(a::AlazarATS9870) = begin
        a.couplingA = :DC
        a.couplingB = :DC
        a.rangeA = :Range400mV
        a.rangeB = :Range400mV
        @eh2 AlazarInputControl(a.handle, Alazar.CHANNEL_A, Alazar.DC_COUPLING,
            Alazar.INPUT_RANGE_PM_400_MV, Alazar.IMPEDANCE_50_OHM)
        @eh2 AlazarInputControl(a.handle, Alazar.CHANNEL_B, Alazar.DC_COUPLING,
            Alazar.INPUT_RANGE_PM_400_MV, Alazar.IMPEDANCE_50_OHM)
        nothing
    end

    captureclock_defaults(a::AlazarATS9870) = begin
        a.clockSource = :Internal
        a.sampleRate = Alazar.SAMPLE_RATE_1000MSPS
        a.clockSlope = :Rising
        a.decimation = 0
        @eh2 AlazarSetCaptureClock(a.handle,
            symbol_to_clock_source(a.clockSource),
            a.sampleRate,
            symbol_to_clock_slope(a.clockSlope),
            a.decimation)
        nothing
    end

    trigger_defaults(a::AlazarATS9870) = begin
        set_triggeroperation(a, :J,
            :ChannelA, :Rising, 0.0,
            :Disabled, :Rising, 0.0)
        nothing
    end

    externaltrigger_defaults(a::AlazarATS9870) = begin
        a.triggerCoupling = :DC
        a.triggerRange = :Range5V
        @eh2 AlazarSetExternalTrigger(a.handle,
            symbol_to_coupling(a.triggerCoupling),
            symbol_to_ext_trig_range(a.triggerRange))
        nothing
    end

    AlazarATS9870() = AlazarATS9870(1,1)
    AlazarATS9870(a,b) = begin
        if (AlazarModule.lib_opened == false)
            Alazar.alazaropen()
        end
        handle = boardhandle(a,b)
        if (handle == 0)
            error("Board $a.$b not found.")
        end

        btype = boardkind(handle)
        if (btype != Alazar.ATS9870)
            error("Board at $a.$b is not an ATS9870.")
        end

        at = new()
        at.systemId = a
        at.boardId = b
        at.handle = handle

        inputcontrol_defaults(at)
        captureclock_defaults(at)
        trigger_defaults(at)
        externaltrigger_defaults(at)
        at[TriggerDelaySamples] = 0
        at[TriggerTimeoutTicks] = 0

        at.auxOutTriggerEnable = false
        at.auxInTriggerSlope = :Rising
        at.auxOutDivider = 4
        at.auxOutTTLLevel = :Low
        at[AuxIOMode] = :AuxOutputTrigger
        at[AcquisitionChannel] = :BothChannels

        return at
    end
end

"""
```
setindex!(a::AlazarATS9870, rate::Real, ::Type{SampleRate})
```

Configures the ATS9870 to 10 MHz PLL external clock mode. The resulting 1 GS/s
sample rate can be decimated by a factor of 1, 2, 4, or any multiple of 10 up
to 100000. The nearest possible sample rate above or equal to what is requested
is set, and a warning is issued if a different rate is set than desired.
"""
function setindex!(a::AlazarATS9870, rate::Real, ::Type{SampleRate})

    valid = [1,2,4,10,100,1000,10000,100000]
    div = 1e9/rate
    dist = valid-div

    local j = length(dist)
    for (i,v) in enumerate(dist)
        if v > 0
            j = max(1,i-1)
            break
        end
    end

    actualRate = 1e9/valid[j]

    if (rate != actualRate)
        warn("Rate was set to ",actualRate," Hz.")
    end

    @eh2 AlazarSetCaptureClock(a.handle,
         Alazar.EXTERNAL_CLOCK_10MHz_REF, 1000000000,
         symbol_to_clock_slope(a.clockSlope), valid[j])

    a.clockSource = :External
    a.sampleRate = actualRate
    a.decimation = valid[j]
    nothing
end

# The following were obtained using Table 8 as a crude guide, followed
# by some experimentation to see what actually worked.
#
# Romain Deterre at AlazarTech claims Table 8 is samples / record / channel,
# but that does not explain the observed behavior with MinSamplesPerRecord.
"""
```
getindex(a::AlazarATS9870, ::Type{MinSamplesPerRecord})
```

Minimum samples per record. Observed behavior deviates from Table 8 of the
Alazar API.
"""
getindex(a::AlazarATS9870, ::Type{MinSamplesPerRecord}) =
    Int(512 / a[ChannelCount])

"""
```
getindex(a::AlazarATS9870, ::Type{MaxBufferBytes})
```

Maximum number of bytes for a given DMA buffer.
"""
getindex(a::AlazarATS9870, ::Type{MaxBufferBytes}) = 64*1024*1024  # 64 MB

"""
```
getindex(a::AlazarATS9870, ::Type{MaxFFTSamples})
```

Maximum number of samples in an FPGA-based FFT. Can be obtained from `dsp_getinfo`
but we have hardcoded since it should not change for this model of digitizer.
"""
getindex(a::AlazarATS9870, ::Type{MaxFFTSamples}) = 0

"""
```
getindex(a::AlazarATS9870, ::Type{BufferAlignment})
```

Returns the buffer alignment requirement (samples / record / channel).
Note that buffers must also be page-aligned.
From Table 8 of the Alazar API.
"""
getindex(a::AlazarATS9870, ::Type{BufferAlignment}) = 64 * a[ChannelCount]

"""
```
getindex(a::AlazarATS9870, ::Type{PretriggerAlignment})
```

Returns the pretrigger alignment requirement (samples / record / channel).
From Table 8 of the Alazar API.
"""
getindex(a::AlazarATS9870, ::Type{PretriggerAlignment}) = 64 * a[ChannelCount]

"""
```
bits_per_sample(a::AlazarATS9870)
```

Always 8 bits per sample for this digitizer.
"""
bits_per_sample(a::AlazarATS9870) = 0x08

"""
```
bytes_per_sample(a::AlazarATS9870)
```

Always one byte per sample for this digitizer.
"""
bytes_per_sample(a::AlazarATS9870) = 1

"""
Returns a UInt32 in the range 0--255 given a desired trigger level in Volts.
"""
triglevel(a::AlazarATS9870, x) = x #U32(round((x+0.4)/0.8 * 255 + 0.5))

adma(::AlazarATS9870, ::NPTRecordMode) = Alazar.ADMA_NPT |
                                         Alazar.ADMA_INTERLEAVE_SAMPLES |
                                         Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::AlazarATS9870, ::TriggeredStreamMode) = Alazar.ADMA_TRIGGERED_STREAMING |
                                               Alazar.ADMA_INTERLEAVE_SAMPLES |
                                               Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::AlazarATS9870, ::ContinuousStreamMode) = Alazar.ADMA_CONTINUOUS_MODE |
                                                Alazar.ADMA_INTERLEAVE_SAMPLES |
                                                Alazar.ADMA_EXTERNAL_STARTCAPTURE
