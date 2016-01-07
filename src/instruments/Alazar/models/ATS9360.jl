export AlazarATS9360

"""
Concrete InstrumentAlazar subtype.
"""
type AlazarATS9360 <: InstrumentAlazar

    systemId::Culong
    boardId::Culong
    handle::Culong

    clockSource::U32
    sampleRate::U32
    clockSlope::U32
    decimation::U32

    coupling::U32
    triggerRange::U32

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

    acquisitionChannel::U32
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
        a.clockSource = Alazar.INTERNAL_CLOCK
        a.sampleRate = Alazar.SAMPLE_RATE_1000MSPS
        a.clockSlope = Alazar.CLOCK_EDGE_RISING
        a.decimation = 0
        @eh2 AlazarSetCaptureClock(a.handle,
            a.clockSource, a.sampleRate, a.clockSlope, a.decimation)
        nothing
    end

    trigger_defaults(a::AlazarATS9360) = begin
        set_triggeroperation(a,  Alazar.TRIG_ENGINE_OP_J,
            Alazar.TRIG_CHAN_A,  Alazar.TRIGGER_SLOPE_POSITIVE, 0.0,
            Alazar.TRIG_DISABLE, Alazar.TRIGGER_SLOPE_POSITIVE, 0.0)
        nothing
    end

    externaltrigger_defaults(a::AlazarATS9360) = begin
        a.coupling = Alazar.DC_COUPLING
        a.triggerRange = Alazar.ETR_5V
        @eh2 AlazarSetExternalTrigger(a.handle, a.coupling, a.triggerRange)
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
        configure(at, TriggerDelaySamples, 0) #U32(0)
        configure(at, TriggerTimeoutTicks, 0) #U32(0)

        at.auxOutTriggerEnable = false
        at.auxInTriggerSlope = Alazar.TRIGGER_SLOPE_POSITIVE
        at.auxOutDivider = 4
        at.auxOutTTLLevel = 0
        configure(at, AuxOutputTrigger)
        # configure(at, AlazarDataPacking, Pack12Bits, BothChannels)

        configure(at, BothChannels)
        dsp_populate(at)
        configure(at, WindowOnes, WindowZeroes)
        return at
    end
end

function configure(a::AlazarATS9360, ::Type{SampleRate}, rate::Real)
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

function configure{T<:Coupling}(a::AlazarATS9360, coupling::Type{T})
    info("Only DC coupling is available on the ATS9360.")
end

function configure{T<:AlazarTriggerRange}(a::AlazarATS9360, range::Type{T})
    info("Only 5V range is available on the ATS9360.")
end

function configure{S<:DSPWindow, T<:DSPWindow}(
        a::AlazarATS9360, re::Type{S}, im::Type{T})
    a.reWindowType = S
    a.imWindowType = T
    nothing
    # AlazarFFTSetWindowFunction is called towards the start of measure()
end

# The following were obtained using Table 8 as a crude guide, followed
# by some experimentation to see what actually worked.
#
# Romain Deterre at AlazarTech claims Table 8 is samples / record / channel,
# but that does not explain the observed behavior with MinSamplesPerRecord.
inspect(a::AlazarATS9360, ::Type{MinSamplesPerRecord}) =
    Int(512 / inspect(a, ChannelCount))
inspect(a::AlazarATS9360, ::Type{MaxBufferBytes}) = 64*1024*1024  # 64 MB
inspect(a::AlazarATS9360, ::Type{MinFFTSamples}) = 128
inspect(a::AlazarATS9360, ::Type{MaxFFTSamples}) = 4096
inspect(a::AlazarATS9360, ::Type{BufferAlignment}) =
    128 * inspect(a, ChannelCount)
inspect(a::AlazarATS9360, ::Type{PretriggerAlignment}) =
    128 * inspect(a, ChannelCount)

# How does this change with data packing?
bits_per_sample(a::AlazarATS9360) = 0x0c
bytes_per_sample(a::AlazarATS9360) = 2
triglevel(a::AlazarATS9360, x) = U32(round((x+0.4)/0.8 * 255 + 0.5))
