export AlazarATS9360

"""
Concrete InstrumentAlazar subtype representing an ATS9360 digitizer.

Defaults are selected as:

- DC coupling (all). Cannot be changed for the ATS9360.
- Input range +/- 0.4V for channel A, B. Cannot be changed for the ATS9360.
- External trigger range: 5 V. Cannot be changed for the ATS9360 (?)
- All impedances 50 Ohm. Cannot be changed for the ATS9360.
- Internal clock, 1 GSps, rising edge.
- Trigger on J; engine J fires when channel A crosses zero from below.
- Trigger delay 0 samples; no trigger timeout
- Acquire with both channels
- AUX IO outputs a trigger signal synced to the sample clock.
"""
mutable struct AlazarATS9360 <: InstrumentAlazar

    systemId::Culong
    boardId::Culong
    handle::Culong

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
    inputcontrol_defaults(a::AlazarATS9360) = begin
        # There are no internal variables in the AlazarATS9360 type because
        # these are the only possible options for this particular instrument!
        @eh2 AlazarInputControl(a.handle, Alazar.CHANNEL_A, Alazar.DC_COUPLING,
            Alazar.INPUT_RANGE_PM_400_MV, Alazar.IMPEDANCE_50_OHM)
        @eh2 AlazarInputControl(a.handle, Alazar.CHANNEL_B, Alazar.DC_COUPLING,
            Alazar.INPUT_RANGE_PM_400_MV, Alazar.IMPEDANCE_50_OHM)
        nothing
    end

    captureclock_defaults(a::AlazarATS9360) = begin
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

    trigger_defaults(a::AlazarATS9360) = begin
        set_triggeroperation(a, :J,
            :ChannelA, :Rising, 0.0,
            :Disabled, :Rising, 0.0)
        nothing
    end

    externaltrigger_defaults(a::AlazarATS9360) = begin
        a.triggerCoupling = :DC
        a.triggerRange = :Range5V
        @eh2 AlazarSetExternalTrigger(a.handle,
            symbol_to_coupling(a.triggerCoupling),
            symbol_to_ext_trig_range(a.triggerRange))
        nothing
    end

    dsp_populate(a::AlazarATS9360) = begin
        dspModuleHandles = dsp_getmodulehandles(a)
        a.dspModules = map(x->DSPModule(a,x),dspModuleHandles)
        nothing
    end

    AlazarATS9360() = AlazarATS9360(1,1)
    AlazarATS9360(a,b) = begin
        if (AlazarModule.lib_opened == false)
            Alazar.alazaropen()
        end
        handle = boardhandle(a,b)
        if (handle == 0)
            error("Board $a.$b not found.")
        end

        btype = boardkind(handle)
        if (btype != Alazar.ATS9360)
            error("Board at $a.$b is not an ATS9360.")
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
        at[AcqusitionChannel] = :BothChannels
        dsp_populate(at)

        configure(at, WindowOnes, WindowZeroes)
        return at
    end
end

"""
Configure the sample rate to any multiple of 1 MHz (within 300 MHz and 1.8 GHz)
using the external clock.
"""
function setindex!(a::AlazarATS9360, ::Type{SampleRate}, rate::Real)
    actualRate = U32(fld(rate,1e6)*1e6)
    if (rate != actualRate)
        warning("Rate must be in increments of 1 MHz. Setting ",actualRate," Hz")
    end

    @eh2 AlazarSetCaptureClock(a.handle,
        Alazar.EXTERNAL_CLOCK_10MHz_REF, actualRate,
        symbol_to_clock_slope(a.clockSlope), 1)

    a.clockSource = :External
    a.sampleRate = actualRate
    a.decimation = 1
    nothing
end

"""
Does nothing but display info telling you that this parameter cannot be changed
from DC coupling on the ATS9360.
"""
function setindex!(a::AlazarATS9360, x::Symbol, ::Type{TriggerCoupling})
    warn("Only DC coupling is available on the ATS9360.")
end

"""
Does nothing but display info telling you that this parameter cannot be changed
from 5V range on the ATS9360.
"""
function setindex!(a::AlazarATS9360, x::Symbol, ::Type{TriggerRange})
    warn("Only 5V range is available on the ATS9360.")
end

"""
Configures the DSP windows. `AlazarFFTSetWindowFunction` is called towards
the start of `measure` rather than here.
"""
function configure(
        a::AlazarATS9360, re::Type{S}, im::Type{T}) where {S <: DSPWindow,T <: DSPWindow}
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
getindex(a::AlazarATS9360, ::Type{MinSamplesPerRecord}) =
    Int(512 / a[ChannelCount])

"""
Maximum number of bytes for a given DMA buffer.
"""
getindex(a::AlazarATS9360, ::Type{MaxBufferBytes}) = 64*1024*1024  # 64 MB

"""
Minimum number of samples in an FPGA-based FFT. Set by the minimum record size.
"""
getindex(a::AlazarATS9360, ::Type{MinFFTSamples}) = 128

"""
Maximum number of samples in an FPGA-based FFT. Can be obtained from `dsp_getinfo`
but we have hardcoded since it should not change for this model of digitizer.
"""
getindex(a::AlazarATS9360, ::Type{MaxFFTSamples}) = 4096

"""
Returns the buffer alignment requirement (samples / record / channel).
Note that buffers must also be page-aligned.
From Table 8 of the Alazar API.
"""
getindex(a::AlazarATS9360, ::Type{BufferAlignment}) = 128 * a[ChannelCount]

"""
Returns the pretrigger alignment requirement (samples / record / channel).
From Table 8 of the Alazar API.
"""
getindex(a::AlazarATS9360, ::Type{PretriggerAlignment}) = 128 * a[ChannelCount]

# How does this change with data packing?
"""
Hard coded to return 0x0c. May need to change if we want to play with data packing.
"""
bits_per_sample(a::AlazarATS9360) = 0x0c

"""
Hard coded to return 2. May need to change if we want to play with data packing.
"""
bytes_per_sample(a::AlazarATS9360) = 2

"""
Returns a UInt32 in the range 0--255 given a desired trigger level in Volts.
"""
triglevel(a::AlazarATS9360, x) = U32(round((x+0.4)/0.8 * 255 + 0.5))
# Incorrect if using external trigger in

adma(::AlazarATS9360, ::NPTRecordMode) = Alazar.ADMA_NPT |
                                         Alazar.ADMA_FIFO_ONLY_STREAMING |
                                         Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::AlazarATS9360, ::TriggeredStreamMode) = Alazar.ADMA_TRIGGERED_STREAMING |
                                               Alazar.ADMA_FIFO_ONLY_STREAMING |
                                               Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::AlazarATS9360, ::ContinuousStreamMode) = Alazar.ADMA_CONTINUOUS_MODE |
                                                Alazar.ADMA_FIFO_ONLY_STREAMING |
                                                Alazar.ADMA_EXTERNAL_STARTCAPTURE
