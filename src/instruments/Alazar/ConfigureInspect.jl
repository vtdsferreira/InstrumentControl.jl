export inspect_per

inspect(a::InstrumentAlazar, ::Type{SampleMemoryPerChannel}) = begin
    memorysize_samples = Array{U32}(1)
    memorysize_samples[1] = U32(0)

    bitspersample = Array{U8}(1)
    bitspersample[1] = U8(0)

    @eh2 AlazarGetChannelInfo(a.handle, memorysize_samples, bitspersample)

    return memorysize_samples[1]
end

# not supported by ATS310, 330, 850.
function configure{T<:AlazarTimestampReset}(a::InstrumentAlazar, t::Type{T})
    (t == AlazarTimestampReset) && error("Choose TimestampResetOnce or ...Always")
    option = code(t(a))
    @eh2 AlazarResetTimeStamp(a.handle, option)
end

function configure{T<:Coupling}(a::InstrumentAlazar, coupling::Type{T})
    coup = code(coupling(a))
    @eh2 AlazarSetExternalTrigger(a.handle, coup, a.triggerRange)
end

function configure{T<:AlazarTriggerRange}(a::InstrumentAlazar, range::Type{T}...)
    rang = code(range(a))
    @eh2 AlazarSetExternalTrigger(a.handle, a.coupling, rang)
end

@eh configure(a::InstrumentAlazar, ::Type{LED}, ledState::Bool) =
    AlazarSetLED(a.handle, ledState)

function inspect{T<:AlazarChannel}(a::InstrumentAlazar, ::Type{AlazarDataPacking}, ch::Type{T})
    ch == AlazarChannel && error("Specify a particular channel.")

    arr = Array{Clong}(1)
    arr[1] = 0

    r = @eh2 AlazarGetParameter(a.handle, code(ch(a)), Alazar.PACK_MODE, arr)
    AlazarDataPacking(a,arr[1])
end

configure(a::InstrumentAlazar, ::Type{RecordCount}, count) =
    @eh2 AlazarSetRecordCount(a.handle, count)

function configure(a::InstrumentAlazar, m::RecordMode)
    r = @eh2 AlazarSetRecordSize(a.handle,
                                 0,
                                 m.sam_per_rec / inspect(a,ChannelCount))

    before_async_read(a,m)
end

function configure(a::InstrumentAlazar, m::TraditionalRecordMode)
    r = @eh2 AlazarSetRecordSize(a.handle,
                                 m.pre_sam_pre_rec / inspect(a,ChannelCount),
                                 m.post_sam_per_rec / inspect(a,ChannelCount))

    before_async_read(a,m)
end

# In streaming mode we don't need to do anything besides before_async_read
function configure(a::InstrumentAlazar, m::StreamMode)
    before_async_read(a,m)
end

function configure(a::InstrumentAlazar, ::Type{TriggerDelaySamples}, delay_samples)
    r = @eh2 AlazarSetTriggerDelay(a.handle, delay_samples)
    a.triggerDelaySamples = delay_samples
    r
end

function configure(a::InstrumentAlazar, ::Type{TriggerTimeoutTicks}, ticks)
    r = @eh2 AlazarSetTriggerTimeOut(a.handle, ticks)
    a.triggerTimeoutTicks = ticks
    r
end

function configure(a::InstrumentAlazar, ::Type{TriggerTimeoutS}, timeout_s)
    configure(a, TriggerTimeoutTicks, ceil(timeout_s * 1.e5))
end

@eh configure(a::InstrumentAlazar, ::Type{Sleep}, sleepState) =
    AlazarSleepDevice(a.handle, sleepState)

function inspect(a::InstrumentAlazar, ::Type{SampleRate})
    a.sampleRate > 0x80 ? float(a.sampleRate) :
        float(samplerate(typeof(SampleRate(a,a.sampleRate))))
end

# Set by data type
function configure{T<:SampleRate}(a::InstrumentAlazar, rate::Type{T})
    rate == SampleRate && error("Choose a sample rate.")

    val = rate(a) |> code

    r = @eh2 AlazarSetCaptureClock(a.handle, Alazar.INTERNAL_CLOCK, val, a.clockSlope, 0)

    a.clockSource = Alazar.INTERNAL_CLOCK
    a.sampleRate = val
    a.decimation = 0
    r
end

function configure{T<:ClockSlope}(a::InstrumentAlazar, slope::Type{T})
    slope == ClockSlope && error("Choose a clock slope.")

    val = slope(a) |> code

    r = @eh2 AlazarSetCaptureClock(a.handle,
                                   a.clockSource,
                                   a.sampleRate,
                                   val,
                                   a.decimation)
    a.clockSlope = val
    r
end

function configure{S<:Union{AuxOutputTrigger,AuxDigitalInput}}(
        a::InstrumentAlazar, aux::Type{S})
    val = aux(a) |> code

    r = @eh2 AlazarConfigureAuxIO(a.handle, val, U32(0))
    a.auxIOMode = val
    a.auxParam = U32(0)

    r
end #of module

function configure{T<:AuxInputTriggerEnable}(
        a::InstrumentAlazar, aux::Type{T}, trigSlope::U32)
    val = aux(a) |> code

    r = @eh2 AlazarConfigureAuxIO(a.handle, val, trigSlope)
    a.auxIOMode = val
    a.auxParam = trigSlope

    r
end

function configure{S<:AuxInputTriggerEnable, T<:TriggerSlope}(
        a::InstrumentAlazar, aux::Type{S}, trigSlope::Type{T})
    val = aux(a) |> code
    val2 = trigSlope(a) |> code

    r = @eh2 AlazarConfigureAuxIO(a.handle, val, val2)
    a.auxIOMode = val
    a.auxParam = val2

    r
end

function configure{T<:AuxOutputPacer}(
        a::InstrumentAlazar, aux::Type{T}, divider::Integer)
    val = aux(a) |> code

    r = @eh2 AlazarConfigureAuxIO(a.handle, val, U32(divider))
    a.auxIOMode = val
    a.auxParam = divider

    r
end

function configure{T<:AuxDigitalOutput}(
        a::InstrumentAlazar, aux::Type{T}, level::Integer)
    val = aux(a) |> code

    r = @eh2 AlazarConfigureAuxIO(a.handle, val, U32(level))
    a.auxIOMode = val
    a.auxParam = level

    r
end

function configure(a::InstrumentAlazar,
                    ::Type{AuxSoftwareTriggerEnabled}, b::Bool)
    if b
        r = @eh2 AlazarConfigureAuxIO(a.handle,
                                      a.auxIOMode,
                                      a.auxParam | Alazar.AUX_OUT_TRIGGER_ENABLE)
        a.auxParam = a.auxParam | Alazar.AUX_OUT_TRIGGER_ENABLE
    else
        r = @eh2 AlazarConfigureAuxIO(a.handle,
                                      a.auxIOMode,
                                      a.auxParam & ~Alazar.AUX_OUT_TRIGGER_ENABLE)
        a.auxParam = a.auxParam & ~Alazar.AUX_OUT_TRIGGER_ENABLE
    end

    r
end

function configure{S<:AlazarDataPacking}(
        a::InstrumentAlazar, ::Type{AlazarDataPacking},
        pack::Type{S}, ch::Type{ChannelA})

    chcode = Alazar.CHANNEL_A

    pk = code((pack)(a))

    r = @eh2 AlazarSetParameter(a.handle, chcode, Alazar.PACK_MODE, pk)
    a.packingA = pk
    r
end

function configure{S<:AlazarDataPacking}(
        a::InstrumentAlazar, ::Type{AlazarDataPacking},
        pack::Type{S}, ch::Type{ChannelB})

    chcode = Alazar.CHANNEL_B

    pk = code((pack)(a))

    r = @eh2 AlazarSetParameter(a.handle, chcode, Alazar.PACK_MODE, pk)
    a.packingB = pk
    r
end

function configure{S<:AlazarDataPacking}(
        a::InstrumentAlazar, ::Type{AlazarDataPacking},
        pack::Type{S}, ch::Type{BothChannels})

    map((c)->configure(a,AlazarDataPacking,pack,c), (ChannelA, ChannelB))
end

# Some logic for the following is a bit specialized to the ATS9360
function configure{T<:AlazarChannel}(a::InstrumentAlazar, ch::Type{T})
    ch == AlazarChannel && error("You must choose a channel.")
    a.acquisitionChannel = U32((ch)(a) |> code)
    a.channelCount = 1
end

function configure{T<:BothChannels}(a::InstrumentAlazar, ch::Type{T})
    a.acquisitionChannel = U32((ch)(a) |> code)
    a.channelCount = 2
end

function inspect(a::InstrumentAlazar, ::Type{AlazarChannel})
    AlazarChannel(a,a.acquisitionChannel)
end

function inspect_per{S<:PerProperty, T<:PerProperty}(
        a::InstrumentAlazar, ::Type{S}, ::Type{T})
    error("inspect_per not implemented for this pair.")
end

function inspect_per{S<:PerProperty, T<:PerProperty}(
        a::InstrumentAlazar, mode::AlazarMode, ::Type{S}, ::Type{T})
    error("inspect_per not implemented for this pair.")
end

inspect_per(a::InstrumentAlazar, ::Type{Bit}, ::Type{Sample}) = begin
    memorysize_samples = Array{U32}(1)
    memorysize_samples[1] = U32(0)

    bitspersample = Array{U8}(1)
    bitspersample[1] = U8(0)

    @eh2 AlazarGetChannelInfo(a.handle, memorysize_samples, bitspersample)

    return bitspersample[1]
end

inspect_per(a::InstrumentAlazar, ::Type{Byte}, ::Type{Sample}) =
    Int(cld(inspect_per(a, Bit, Sample), 8))

inspect_per(a::InstrumentAlazar, ::Type{Sample}, ::Type{Byte}) =
    float(1.0 / inspect_per(a, Byte, Sample))

inspect(a::InstrumentAlazar, ::Type{BufferSize})  = a.bufferSize

function configure(a::InstrumentAlazar, ::Type{BufferSize}, bufsize::Integer)
    a.bufferSize = U32(bufsize)
end

inspect(a::InstrumentAlazar, ::Type{BufferCount}) = a.bufferCount
function configure(a::InstrumentAlazar, ::Type{BufferCount}, bufcount)
    a.bufferCount = U32(bufcount)
end

# Since records/buffer is always 1 in stream mode, we fix samples/record:
inspect_per(a::InstrumentAlazar, m::StreamMode,
        ::Type{Sample}, ::Type{Record}) =
    Int(inspect(a, BufferSize) / (inspect_per(a, Byte, Sample)))

# For record mode, the number of samples per record must be specified.
inspect_per(a::InstrumentAlazar, m::RecordMode, ::Type{Sample}, ::Type{Record}) =
    m.sam_per_rec

inspect_per(a::InstrumentAlazar, m::TraditionalRecordMode,
    ::Type{Sample}, ::Type{Record}) = m.pre_sam_per_rec + m.post_sam_per_rec

# For any Alazar digitizer in stream mode, records per buffer should be 1.
inspect_per(a::InstrumentAlazar, m::StreamMode,
    ::Type{Record}, ::Type{Buffer}) = 1

# For record mode, the number of records per buffer is fixed based on the
# desired buffer size and samples per record.
inspect_per(a::InstrumentAlazar, m::RecordMode, ::Type{Record}, ::Type{Buffer}) =
    Int(fld(inspect(a, BufferSize),
        inspect_per(a, m, Sample, Record) * inspect_per(a, Byte, Sample)))

# Pretty straightforward...
inspect_per(a::InstrumentAlazar, m::AlazarMode, ::Type{Sample}, ::Type{Buffer}) =
    inspect_per(a, m, Sample, Record) * inspect_per(a, m, Record, Buffer)

# Parameter is ignored in stream mode for any Alazar digitizer.
inspect_per(::StreamMode, ::Type{Record}, ::Type{Acquisition}) = inf_records
inspect_per(a::InstrumentAlazar, m::StreamMode,
    ::Type{Record}, ::Type{Acquisition}) = inspect_per(m, Record, Acquisition)

# Pass 0x7FFFFFFF for indefinite acquisition count.
inspect_per(m::RecordMode, ::Type{Record}, ::Type{Acquisition}) = m.total_recs
inspect_per(a::InstrumentAlazar, m::RecordMode,
    ::Type{Record}, ::Type{Acquisition}) = inspect_per(m, Record, Acquisition)

inspect_per(a::InstrumentAlazar, m::StreamMode, ::Type{Buffer}, ::Type{Acquisition}) =
    Int(cld(m.total_samples, inspect_per(a, m, Sample, Buffer)))
    # Int(cld(m.total_acq_time_s * inspect(a, SampleRate),
    #     inspect_per(a, m, Sample, Buffer)))

inspect_per(a::InstrumentAlazar, m::RecordMode, ::Type{Buffer}, ::Type{Acquisition}) =
    Int(cld(m.total_recs, inspect_per(a, m, Record, Buffer)))

inspect(a::InstrumentAlazar, ::Type{ChannelCount}) = a.channelCount
