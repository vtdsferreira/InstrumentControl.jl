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
function setindex!(a::InstrumentAlazar, aux::Symbol, ::Type{AlazarAux})
    val = symbol_to_aux_mode(aux)
    if aux == :AuxOutputTrigger
        val = auxmode(val, a.auxOutTriggerEnable)
    end

    @eh2 AlazarConfigureAuxIO(a.handle, val, U32(0))
    a.auxIOMode = val
    nothing
end
#
# """
# Configure a digitizer's AUX IO port to use the edge of a pulse as an AutoDMA
# trigger signal.
# """
# function configure{T<:TriggerSlope}(a::InstrumentAlazar,
#         aux::Type{AuxInputTriggerEnable}, trigSlope::Type{T})
#     val = code(a,aux)
#     val2 = code(a,trigSlope)
#
#     @eh2 AlazarConfigureAuxIO(a.handle, val, val2)
#     a.auxIOMode = val
#     a.auxInTriggerSlope = val2
#     nothing
# end

"""
- `:AuxOutputPacer` Configure a digitizer's AUX IO port to output the sample clock, divided by an integer.
- `:AuxDigitalOutput` Configure a digitizer's AUX IO port to act as a general purpose digital output.
"""
function setindex!(a::InstrumentAlazar,
        v::Tuple{Symbol,Integer}, ::Type{AlazarAux})
    aux,d = v
    val = code(a,aux)
    val = auxmode(val, a.auxOutTriggerEnable)

    if aux == :AuxOutputPacer
        @assert d > 2 "Divider needs to be > 2."
        @eh2 AlazarConfigureAuxIO(a.handle, val, U32(d))
        a.auxIOMode = val
        a.auxOutDivider = d
    elseif aux == :AuxDigitalOutput
        @eh2 AlazarConfigureAuxIO(a.handle, val, U32(d))
        a.auxIOMode = val
        a.auxOutTTLLevel = d
    else
        error("Unexpected symbol.")
    end
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
function setindex!(a::InstrumentAlazar, b::Bool,
        ::Type{AuxSoftwareTriggerEnable})
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
function setindex!(a::InstrumentAlazar, count, ::Type{RecordCount})
    @eh2 AlazarSetRecordCount(a.handle, count)
    nothing
end

## Channels ##########

# Logic for the following is a bit specialized to two-channel devices

"Configures the acquisition channel."
function setindex!(a::InstrumentAlazar, v::Symbol, ::Type{AlazarChannel})
    if v == :ChannelA || v == :ChannelB
        a.channelCount = 1
    elseif v == :BothChannels
        a.channelCount = 2
    else
        error("Unexpected symbol.")
    end
    a.acquisitionChannel = v

    nothing
end

## Clocks ############

"Configures one of the preset sample rates derived from the internal clock."
function setindex!(a::InstrumentAlazar, rate::Symbol, ::Type{SampleRate})
    @eh2 AlazarSetCaptureClock(a.handle,
        Alazar.INTERNAL_CLOCK,
        symbol_to_clock_code(rate),
        symbol_to_clock_slope(a.clockSlope), 0)

    a.clockSource = :Internal
    a.sampleRate = symbol_to_clock_code(rate)
    a.decimation = 0
    nothing
end

"Configures whether the clock ticks on a rising or falling slope."
function setindex!(a::InstrumentAlazar, slope::Symbol, ::Type{ClockSlope})
    @eh2 AlazarSetCaptureClock(a.handle,
                               symbol_to_clock_source(a.clockSource),
                               a.sampleRate,
                               symbol_to_clock_slope(slope),
                               a.decimation)
    a.clockSlope = slope
    nothing
end

## Data packing #########

"Configures the data packing mode for a channel."
function setindex!(a::InstrumentAlazar, pack::Symbol, ::Type{AlazarDataPacking},
        ch::Symbol)

    @eh2 AlazarSetParameter(a.handle, symbol_to_channel_code(ch),
        Alazar.PACK_MODE, symbol_to_pack(pack))
    a.packingA = pack
    nothing
end

## Miscellaneous #####

"""
```
setindex!(a::InstrumentAlazar, ledState::Bool, ::Type{LED})
```

Configures the LED on the digitizer card chassis.
"""
function setindex!(a::InstrumentAlazar, ledState, ::Type{LED})
    @eh2 AlazarSetLED(a.handle, ledState)
    nothing
end

"""
```
setindex!(a::InstrumentAlazar, sleepState, ::Type{Sleep})
```

Configures the sleep state of the digitizer card.
"""
function setindex!(a::InstrumentAlazar, sleepState, ::Type{Sleep})
    @eh2 AlazarSleepDevice(a.handle, sleepState)
    nothing
end

#
"""
```
setindex!(a::InstrumentAlazar, s::Symbol, ::Type{AlazarTimestampReset})
```

Configures timestamp reset.
- `:Always`: Reset the timestamp counter to zero on each call to
`AlazarStartCapture`. This is the default operation.
- `:Once`: Reset the timestamp counter to zero on the next call to
`AlazarStartCapture`, but not thereafter.

Not supported by ATS310, 330, 850.
"""
function setindex!(a::InstrumentAlazar, s::Symbol, ::Type{AlazarTimestampReset})
    @eh2 AlazarResetTimeStamp(a.handle, symbol_to_ts_reset(s))
    nothing
end

## Trigger engine ###########

"""
```
setindex!(a::InstrumentAlazar, eng::Symbol, ::Type{TriggerEngine})
```

Configures the trigger engines J and K. Available arguments are `:J`, `:K`,
`:JOrK`, `:JAndK`, `:JXorK`, `:JAndNotK`, `:NotJAndK`.
"""
function setindex!(a::InstrumentAlazar, eng::Symbol, ::Type{TriggerEngine})
    set_triggeroperation(a, eng,
        a.sourceJ, a.slopeJ, a.levelJ,
        a.sourceK, a.slopeK, a.levelK)
    nothing
end

"Configures whether to trigger on a rising or falling slope, for engine J and K."
function setindex!(a::InstrumentAlazar, slope::Tuple{Symbol,Symbol},
        ::Type{TriggerSlope})
    sJ,sK = slope
    set_triggeroperation(a, a.engine,
        a.sourceJ, sJ, a.levelJ,
        a.sourceK, sK, a.levelK)
    nothing
end

"""
Configure the trigger source for trigger engine J and K.
"""
function setindex!(a::InstrumentAlazar, source::Tuple{Symbol,Symbol},
        ::Type{TriggerSource})
    sJ,sK = source
    set_triggeroperation(a, a.engine,
        sJ, a.slopeJ, a.levelJ,
        sK, a.slopeK, a.levelK)
    nothing
end

"""
Configure the trigger level for trigger engine J and K, in Volts.
"""
function setindex!(a::InstrumentAlazar, l::Tuple{Integer,Integer},
        ::Type{TriggerLevel})
    levelJ, levelK = l
    set_triggeroperation(a.handle, a.engine,
        a.sourceJ, a.slopeJ, levelJ,
        a.sourceK, a.slopeK, levelK)
    nothing
end

"Configure the external trigger coupling."
function setindex!(a::InstrumentAlazar, c::Symbol, ::Type{TriggerCoupling})
    if :triggerCoupling in fieldnames(a) && :triggerRange in fieldnames(a)
        a.triggerCoupling = c
        @eh2 AlazarSetExternalTrigger(a.handle, symbol_to_coupling(c),
            symbol_to_ext_trig_range(a.triggerRange))
    else
        warn("Cannot configure trigger coupling for $a.")
    end
    nothing
end

"Configure the external trigger range."
function setindex!(a::InstrumentAlazar, range, ::Type{TriggerRange})
    if :triggerCoupling in fieldnames(a) && :triggerRange in fieldnames(a)
        a.triggerRange = range
        @eh2 AlazarSetExternalTrigger(a.handle,
            symbol_to_coupling(a.triggerCoupling),
            symbol_to_ext_trig_range(range))
    else
        warn("Cannot configure trigger range for $a.")
    end
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
