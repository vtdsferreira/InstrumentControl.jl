## Auxiliary IO

function configure{S<:Union{AuxOutputTrigger,AuxDigitalInput}}(
        a::InstrumentAlazar, aux::Type{S})
    val = aux(a) |> code

    r = @eh2 AlazarConfigureAuxIO(a.handle, val, U32(0))
    a.auxIOMode = val
    a.auxParam = U32(0)

    r
end

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

## Buffers ##########

function configure(a::InstrumentAlazar, ::Type{BufferCount}, bufcount)
    a.bufferCount = U32(bufcount)
end

function configure(a::InstrumentAlazar, ::Type{BufferSize}, bufsize::Integer)
    a.bufferSize = U32(bufsize)
end

configure(a::InstrumentAlazar, ::Type{RecordCount}, count) =
    @eh2 AlazarSetRecordCount(a.handle, count)

## Channels ##########

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

## Clocks ############

function configure{T<:SampleRate}(a::InstrumentAlazar, rate::Type{T})
    rate == SampleRate && error("Choose a sample rate.")

    val = rate(a) |> code

    r = @eh2 AlazarSetCaptureClock(a.handle,
            Alazar.INTERNAL_CLOCK, val, a.clockSlope, 0)

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

## Data packing #########

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

## Miscellaneous ######

@eh configure(a::InstrumentAlazar, ::Type{LED}, ledState::Bool) =
    AlazarSetLED(a.handle, ledState)

@eh configure(a::InstrumentAlazar, ::Type{Sleep}, sleepState) =
    AlazarSleepDevice(a.handle, sleepState)

# not supported by ATS310, 330, 850.
function configure{T<:AlazarTimestampReset}(a::InstrumentAlazar, t::Type{T})
    (t == AlazarTimestampReset) && error("Choose TimestampReset[Once|Always]")
    option = code(t(a))
    @eh2 AlazarResetTimeStamp(a.handle, option)
end

## Trigger engine ###########

function configure{T<:Coupling}(a::InstrumentAlazar, coupling::Type{T})
    coup = code(coupling(a))
    @eh2 AlazarSetExternalTrigger(a.handle, coup, a.triggerRange)
end

function configure{T<:AlazarTriggerRange}(a::InstrumentAlazar, range::Type{T}...)
    rang = code(range(a))
    @eh2 AlazarSetExternalTrigger(a.handle, a.coupling, rang)
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
