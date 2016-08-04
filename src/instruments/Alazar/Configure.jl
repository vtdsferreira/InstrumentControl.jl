export configure

## Auxiliary IO

"Masks an AUX IO mode parameter to specify AUX IO software trigger enable."
auxmode(m::U32, b::Bool) = begin
    if b
        m | Alazar.AUX_OUT_TRIGGER_ENABLE
    else
        m & ~Alazar.AUX_OUT_TRIGGER_ENABLE
    end
end

"Configure a digitizer's AUX IO to output a trigger signal synced to the sample clock."
function configure(a::InstrumentAlazar, aux::Type{AuxOutputTrigger})
    val = code(a,aux)
    val = auxmode(val, a.auxOutTriggerEnable)

    @eh2 AlazarConfigureAuxIO(a.handle, val, U32(0))
    a.auxIOMode = val
    nothing
end

"Configure a digitizer's AUX IO to act as a digital input."
function configure(a::InstrumentAlazar, aux::Type{AuxDigitalInput})
    val = code(a,aux)

    @eh2 AlazarConfigureAuxIO(a.handle, val, U32(0))
    a.auxIOMode = val
    nothing
end

"""
Configure a digitizer's AUX IO port to use the edge of a pulse as an AutoDMA
trigger signal.
"""
function configure{T<:TriggerSlope}(a::InstrumentAlazar,
        aux::Type{AuxInputTriggerEnable}, trigSlope::Type{T})
    val = code(a,aux)
    val2 = code(a,trigSlope)

    @eh2 AlazarConfigureAuxIO(a.handle, val, val2)
    a.auxIOMode = val
    a.auxInTriggerSlope = val2
    nothing
end

"Configure a digitizer's AUX IO port to output the sample clock, divided by an integer."
function configure(a::InstrumentAlazar,
        aux::Type{AuxOutputPacer}, divider::Integer)
    val = code(a,aux)
    val = auxmode(val, a.auxOutTriggerEnable)

    @assert divider > 2 "Divider needs to be > 2."
    @eh2 AlazarConfigureAuxIO(a.handle, val, U32(divider))
    a.auxIOMode = val
    a.auxOutDivider = divider
    nothing
end

"Configure a digitizer's AUX IO port to act as a general purpose digital output."
function configure(a::InstrumentAlazar,
        aux::Type{AuxDigitalOutput}, level::Integer)
    val = code(a,aux)
    val = auxmode(val, a.auxOutTriggerEnable)
    @eh2 AlazarConfigureAuxIO(a.handle, val, U32(level))
    a.auxIOMode = val
    a.auxOutTTLLevel = level
    nothing
end

"""
If an AUX IO output mode has been configured, then this will configure
software trigger enable. From the Alazar API:

When this flag is set, the board will wait for software to call
`AlazarForceTriggerEnable` to generate a trigger enable event; then wait for
sufficient trigger events to capture the records in an AutoDMA buffer; then wait
for the next trigger enable event and repeat.
"""
function configure(a::InstrumentAlazar,
                    ::Type{AuxSoftwareTriggerEnable}, b::Bool)
    m = auxmode(a.auxIOMode,b)
    a.auxOutTriggerEnable = b

    if a.auxIOMode == AUX_OUT_TRIGGER
        p = U32(0)
    elseif a.auxIOMode == AUX_OUT_PACER
        p = a.auxOutDivider
    elseif a.auxIOMode == AUX_OUT_SERIAL_DATA
        p = a.auxOutTTLLevel
    else
        warn("Inoperative unless an aux output mode is configured.")
        return nothing
    end

    @eh2 AlazarConfigureAuxIO(a.handle, m, p)
    nothing
end

## Buffers ##########

"Wrapper for C function `AlazarSetRecordCount`. See the Alazar API."
function configure(a::InstrumentAlazar, ::Type{RecordCount}, count)
    @eh2 AlazarSetRecordCount(a.handle, count)
    nothing
end

## Channels ##########

# Some logic for the following is a bit specialized to the ATS9360

"Configures the acquisition channel."
function configure{T<:AlazarChannel}(a::InstrumentAlazar, ch::Type{T})
    ch == AlazarChannel && error("You must choose a channel.")
    a.acquisitionChannel = U32(code(a,ch))
    a.channelCount = 1
    nothing
end

"Configures acquisition from both channels, simultaneously."
function configure(a::InstrumentAlazar, ch::Type{BothChannels})
    a.acquisitionChannel = U32(code(a,ch))
    a.channelCount = 2
    nothing
end

## Clocks ############

"Configures one of the preset sample rates derived from the internal clock."
function configure{T<:SampleRate}(a::InstrumentAlazar, rate::Type{T})
    rate == SampleRate && error("Choose a sample rate.")

    val = code(a,rate)

    @eh2 AlazarSetCaptureClock(a.handle,
                               Alazar.INTERNAL_CLOCK, val, a.clockSlope, 0)

    a.clockSource = Alazar.INTERNAL_CLOCK
    a.sampleRate = val
    a.decimation = 0
    nothing
end

"Configures whether the clock ticks on a rising or falling slope."
function configure{T<:ClockSlope}(a::InstrumentAlazar, slope::Type{T})
    slope == ClockSlope && error("Choose a clock slope.")

    val = code(a,slope)

    @eh2 AlazarSetCaptureClock(a.handle,
                               a.clockSource,
                               a.sampleRate,
                               val,
                               a.decimation)
    a.clockSlope = val
    nothing
end

## Data packing #########

"Configures the data packing mode for channel A."
function configure{S<:AlazarDataPacking}(
        a::InstrumentAlazar, ::Type{AlazarDataPacking},
        pack::Type{S}, ch::Type{ChannelA})

    chcode = Alazar.CHANNEL_A

    pk = code(a,pack)

    @eh2 AlazarSetParameter(a.handle, chcode, Alazar.PACK_MODE, pk)
    a.packingA = pk
    nothing
end

"Configures the data packing mode for channel B."
function configure{S<:AlazarDataPacking}(
        a::InstrumentAlazar, ::Type{AlazarDataPacking},
        pack::Type{S}, ch::Type{ChannelB})

    chcode = Alazar.CHANNEL_B

    pk = code(a,pack)

    @eh2 AlazarSetParameter(a.handle, chcode, Alazar.PACK_MODE, pk)
    a.packingB = pk
    nothing
end

"Configures the data packing mode for both channels."
function configure{S<:AlazarDataPacking}(
        a::InstrumentAlazar, ::Type{AlazarDataPacking},
        pack::Type{S}, ch::Type{BothChannels})

    map((c)->configure(a,AlazarDataPacking,pack,c), (ChannelA, ChannelB))
    nothing
end

## Miscellaneous ######

"Configures the LED on the digitizer card chassis."
function configure(a::InstrumentAlazar, ::Type{LED}, ledState::Bool)
    @eh2 AlazarSetLED(a.handle, ledState)
    nothing
end

"Configures the sleep state of the digitizer card."
function configure(a::InstrumentAlazar, ::Type{Sleep}, sleepState)
    @eh2 AlazarSleepDevice(a.handle, sleepState)
    nothing
end

# not supported by ATS310, 330, 850.
"""
Configures timestamp reset. From the Alazar API, the choices are
`TimestampResetOnce`
(Reset the timestamp counter to zero on the next call to `AlazarStartCapture`,
but not thereafter.) or `TimestampResetAlways` (Reset the timestamp counter to
zero on each call to AlazarStartCapture. This is the default operation.)
"""
function configure{T<:AlazarTimestampReset}(a::InstrumentAlazar, t::Type{T})
    (t == AlazarTimestampReset) && error("Choose TimestampReset[Once|Always]")
    option = code(a,t)
    @eh2 AlazarResetTimeStamp(a.handle, option)
    nothing
end

## Trigger engine ###########

"Configures the trigger engines, e.g. TriggerOnJ, TriggerOnJAndNotK, etc."
function configure{T<:AlazarTriggerEngine}(a::InstrumentAlazar, engine::Type{T})
    eng = code(a,engine)
    set_triggeroperation(a, eng,
        a.channelJ, a.slopeJ, a.levelJ,
        a.channelK, a.slopeK, a.levelK)
    nothing
end

"Configures whether to trigger on a rising or falling slope, for engine J and K."
function configure{S<:TriggerSlope,T<:TriggerSlope}(
    a::InstrumentAlazar, slopeJ::Type{S}, slopeK::Type{T})

    sJ = code(a,slopeJ)
    sK = code(a,slopeK)
    set_triggeroperation(a, a.engine,
        a.channelJ, sJ, a.levelJ,
        a.channelK, sK, a.levelK)
    nothing
end

"""
Configure the trigger source for trigger engine J and K.
"""
function configure{S<:TriggerSource,T<:TriggerSource}(a::InstrumentAlazar,
        sourceJ::Type{S}, sourceK::Type{T})

    sJ = code(a,sourceJ)
    sK = code(a,sourceK)
    set_triggeroperation(a, a.engine,
        sJ, a.slopeJ, a.levelJ,
        sK, a.slopeK, a.levelK)
    nothing
end

"""
Configure the trigger level for trigger engine J and K. This should be an
unsigned 8 bit integer (0--255) corresponding to the full range of the digitizer.
"""
function configure(a::InstrumentAlazar, ::Type{TriggerLevel}, levelJ, levelK)
    set_triggeroperation(a.handle, a.engine,
        a.channelJ, a.slopeJ, levelJ,
        a.channelK, a.slopeK, levelK)
    nothing
end

"Configure the external trigger coupling."
function configure{T<:Coupling}(a::InstrumentAlazar, coupling::Type{T})
    coup = code(a,coupling)
    @eh2 AlazarSetExternalTrigger(a.handle, coup, a.triggerRange)
    nothing
end

"Configure the external trigger range."
function configure{T<:AlazarTriggerRange}(a::InstrumentAlazar, range::Type{T})
    rang = code(a,range)
    @eh2 AlazarSetExternalTrigger(a.handle, a.coupling, rang)
    nothing
end

"""
Configure how many samples to wait after receiving a trigger event before capturing
a record.
"""
function setindex!(a::InstrumentAlazar, delay_samples, ::Type{TriggerDelaySamples})
    @eh2 AlazarSetTriggerDelay(a.handle, delay_samples)
    a.triggerDelaySamples = delay_samples
    nothing
end

"""
Wrapper for C function `AlazarSetTriggerTimeOut`.
"""
function setindex!(a::InstrumentAlazar, ticks, ::Type{TriggerTimeoutTicks})
    @eh2 AlazarSetTriggerTimeOut(a.handle, ticks)
    a.triggerTimeoutTicks = ticks
    nothing
end

"""
Wrapper for C function `AlazarSetTriggerTimeOut`, except we take seconds here
instead of ticks (units of 10 us).
"""
function setindex!(a::InstrumentAlazar, timeout_s, ::Type{TriggerTimeoutS})
    a[TriggerTimeoutTicks] = ceil(timeout_s * 1.e5)
end
