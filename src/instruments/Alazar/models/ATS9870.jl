export AlazarATS9870

"""
Concrete InstrumentAlazar subtype representing an ATS9870 digitizer.

Defaults are selected as:

- DC coupling for channels A, B and external trigger input.
- Input range +/- 0.4V for channel A, B.
- External trigger range: 5 V. Cannot be changed for the ATS9360 (?)
- All impedances 50 Ohm. Cannot be changed for the ATS9360.
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

    clockSource::U32
    sampleRate::U32
    clockSlope::U32
    decimation::U32

    coupling::U32
    triggerRange::Symbol

    engine::U32
    channelJ::U32
    slopeJ::U32
    levelJ::AbstractFloat
    channelK::U32
    slopeK::U32
    levelK::AbstractFloat

    triggerDelaySamples::U32
    triggerTimeoutTicks::U32

    auxIOMode::U32
    auxInTriggerSlope::U32
    auxOutDivider::U32
    auxOutTTLLevel::U32
    auxOutTriggerEnable::Bool

    acquisitionChannel::Symbol
    channelCount::U32

    packingA::Clong
    packingB::Clong

    dspModules::Array{DSPModule,1}
    reWindowType::DataType
    imWindowType::DataType

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
        a.clockSource = Alazar.INTERNAL_CLOCK
        a.sampleRate = Alazar.SAMPLE_RATE_1000MSPS
        a.clockSlope = Alazar.CLOCK_EDGE_RISING
        a.decimation = 0
        @eh2 AlazarSetCaptureClock(a.handle,
            a.clockSource, a.sampleRate, a.clockSlope, a.decimation)
        nothing
    end

    trigger_defaults(a::AlazarATS9870) = begin
        set_triggeroperation(a,  Alazar.TRIG_ENGINE_OP_J,
            Alazar.TRIG_CHAN_A,  Alazar.TRIGGER_SLOPE_POSITIVE, 0.0,
            Alazar.TRIG_DISABLE, Alazar.TRIGGER_SLOPE_POSITIVE, 0.0)
        nothing
    end

    externaltrigger_defaults(a::AlazarATS9870) = begin
        a.coupling = Alazar.DC_COUPLING
        a.triggerRange = :Range5V
        @eh2 AlazarSetExternalTrigger(a.handle, a.coupling, Alazar.ETR_5V)
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
        at.auxInTriggerSlope = Alazar.TRIGGER_SLOPE_POSITIVE
        at.auxOutDivider = 4
        at.auxOutTTLLevel = 0
        at[AlazarAux] = :AuxOutputTrigger
        at[AlazarChannel] = :BothChannels

        return at
    end
end

"""
Configure the sample rate to any multiple of 1 MHz (within 300 MHz and 1.8 GHz)
using the external clock.
"""
function configure(a::AlazarATS9870, ::Type{SampleRate}, rate::Real)
    actualRate = U32(fld(rate,1e6)*1e6)
    if (rate != actualRate)
        warning("Rate must be in increments of 1 MHz. Setting ",actualRate," Hz")
    end

    @eh2 AlazarSetCaptureClock(a.handle,
         Alazar.EXTERNAL_CLOCK_10MHz_REF, actualRate, a.clockSlope, 1)

    a.clockSource = Alazar.EXTERNAL_CLOCK_10MHz_REF
    a.sampleRate = actualRate
    a.decimation = 1
    nothing
end

"""
Does nothing but display info telling you that this parameter cannot be changed
from DC coupling on the ATS9360.
"""
function configure{T<:Coupling}(a::AlazarATS9870, coupling::Type{T})
    info("Only DC coupling is available on the ATS9360.")
end

"""
Does nothing but display info telling you that this parameter cannot be changed
from 5V range on the ATS9360.
"""
function configure{T<:AlazarTriggerRange}(a::AlazarATS9870, range::Type{T})
    info("Only 5V range is available on the ATS9360.")
end

"""
Configures the DSP windows. `AlazarFFTSetWindowFunction` is called towards
the start of `measure` rather than here.
"""
function configure{S<:DSPWindow, T<:DSPWindow}(
        a::AlazarATS9870, re::Type{S}, im::Type{T})
    a.reWindowType = S
    a.imWindowType = T
    nothing
end

# The following were obtained using Table 8 as a crude guide, followed
# by some experimentation to see what actually worked.
#
# Romain Deterre at AlazarTech claims Table 8 is samples / record / channel,
# but that does not explain the observed behavior with MinSamplesPerRecord.
"""
Minimum samples per record. Observed behavior deviates from Table 8 of the
Alazar API.
"""
inspect(a::AlazarATS9870, ::Type{MinSamplesPerRecord}) =
    Int(512 / inspect(a, ChannelCount))

"""
Maximum number of bytes for a given DMA buffer.
"""
inspect(a::AlazarATS9870, ::Type{MaxBufferBytes}) = 64*1024*1024  # 64 MB

"""
Minimum number of samples in an FPGA-based FFT. Set by the minimum record size.
"""
inspect(a::AlazarATS9870, ::Type{MinFFTSamples}) = 128

"""
Maximum number of samples in an FPGA-based FFT. Can be obtained from `dsp_getinfo`
but we have hardcoded since it should not change for this model of digitizer.
"""
inspect(a::AlazarATS9870, ::Type{MaxFFTSamples}) = 4096

"""
Returns the buffer alignment requirement (samples / record / channel).
Note that buffers must also be page-aligned.
From Table 8 of the Alazar API.
"""
inspect(a::AlazarATS9870, ::Type{BufferAlignment}) =
    128 * inspect(a, ChannelCount)

"""
Returns the pretrigger alignment requirement (samples / record / channel).
From Table 8 of the Alazar API.
"""
inspect(a::AlazarATS9870, ::Type{PretriggerAlignment}) =
    128 * inspect(a, ChannelCount)

# How does this change with data packing?
"""
Hard coded to return 0x0c. May need to change if we want to play with data packing.
"""
bits_per_sample(a::AlazarATS9870) = 0x0c

"""
Hard coded to return 2. May need to change if we want to play with data packing.
"""
bytes_per_sample(a::AlazarATS9870) = 2

"""
Returns a UInt32 in the range 0--255 given a desired trigger level in Volts.
"""
triglevel(a::AlazarATS9870, x) = U32(round((x+0.4)/0.8 * 255 + 0.5))
