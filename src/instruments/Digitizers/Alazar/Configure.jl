export configure

## Auxiliary IO
function auxmode(m::U32, b::Bool)
    if b
        m | Alazar.AUX_OUT_TRIGGER_ENABLE
    else
        m & ~Alazar.AUX_OUT_TRIGGER_ENABLE
    end
end

function auxparam(a::InstrumentAlazar, aux::Symbol)
    if aux == :AuxOutputTrigger
        U32(0)
    elseif aux == :AuxInputTriggerEnable
        symbol_to_trig_slope(a.auxInTriggerSlope)
    elseif aux == :AuxOutputPacer
        a.auxOutDivider
    elseif aux == :AuxDigitalInput
        U32(0)  # not really specified what this should be in ATS-SDK guide
    else#if aux == :AuxDigitalOutput
        symbol_to_ttl(a.auxOutTTLLevel)
    end
end

"""
    setindex!(a::InstrumentAlazar, aux::Symbol, ::Type{AuxIOMode})
Configure a digitizer's AUX I/O mode. Available choices include:

- `:AuxOutputTrigger`
- `:AuxOutputPacer`
- `:AuxDigitalOutput`
- `:AuxDigitalInput`
- `:AuxInputTriggerEnable`
"""
function setindex!(a::InstrumentAlazar, aux::Symbol, ::Type{AuxIOMode})
    m = symbol_to_aux_mode(aux)
    if aux == :AuxOutputTrigger ||
       aux == :AuxOutputPacer ||
       aux == :AuxDigitalOutput
        m = auxmode(m, a.auxOutTriggerEnable)
    end
    p = auxparam(a,aux)

    @eh2 AlazarConfigureAuxIO(a.handle, m, p)
    a.auxIOMode = aux
    nothing
end

"""
    setindex!(a::InstrumentAlazar, trigSlope::Symbol, ::Type{AuxInputTriggerSlope})
Trigger enable is on the [`:Rising` / `:Falling`] edge of a TTL pulse to the
AUX I/O connector. This does nothing immediately unless the AUX I/O
mode is `:AuxInTriggerEnable`.
"""
function setindex!(a::InstrumentAlazar, trigSlope::Symbol,
        ::Type{AuxInputTriggerSlope})
    a.auxInTriggerSlope = trigSlope
    a[AuxIOMode] = a.auxIOMode
    nothing
end

function setindex!(a::InstrumentAlazar, v::Integer, ::Type{AuxOutputPacerDivider})
    @assert v > 2 "Divider needs to be > 2."
    a.auxOutDivider = v
    a[AuxIOMode] = a.auxIOMode
    nothing
end

function setindex!(a::InstrumentAlazar, s::Symbol, ::Type{AuxOutputTTL})
    a.auxOutTTLLevel = s
    a[AuxIOMode] = a.auxIOMode
    nothing
end


"""
    setindex!(a::InstrumentAlazar, b::Bool, ::Type{AuxSoftwareTriggerEnable})
If an AUX I/O output mode has been configured, then this will configure
software trigger enable. From the Alazar API:

When this flag is set, the board will wait for software to call
`AlazarForceTriggerEnable` to generate a trigger enable event; then wait for
sufficient trigger events to capture the records in an AutoDMA buffer; then wait
for the next trigger enable event and repeat.
"""
function setindex!(a::InstrumentAlazar, b::Bool, ::Type{AuxSoftwareTriggerEnable})
    a.auxOutTriggerEnable = b
    a[AuxIOMode] = a.auxIOMode
    nothing
end

## Buffers ##########

"""
Wrapper for C function `AlazarSetRecordCount`. See the Alazar API.
"""
function setindex!(a::InstrumentAlazar, count, ::Type{RecordCount})
    @eh2 AlazarSetRecordCount(a.handle, count)
    nothing
end

## Channels ##########

# Logic for the following is a bit specialized to two-channel devices
"Configures the acquisition channel."
function setindex!(a::InstrumentAlazar, v::Symbol, ::Type{AcquisitionChannel})
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

function setindex!(a::InstrumentAlazar, timeout_ms, ::Type{BufferTimeout})
    a.bufferTimeout = timeout_ms
end

## Clocks ############

"""
    setindex!(a::InstrumentAlazar, rate::Symbol, ::Type{SampleRate})
Configures one of the preset sample rates derived from the internal clock.
"""
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

"""
    setindex!(a::InstrumentAlazar, slope::Symbol, ::Type{ClockSlope})
Configures whether the clock ticks on a rising or falling slope.
"""
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

# TODO: Rewrite this method
# "Configures the data packing mode for a channel."
function setindex!(a::InstrumentAlazar, pack::Symbol, ::Type{AlazarDataPacking},
        ch::Symbol)

    @eh2 AlazarSetParameter(a.handle, symbol_to_channel_code(ch),
        Alazar.PACK_MODE, symbol_to_pack(pack))
    a.packingA = pack
    nothing
end

## Miscellaneous #####

"""
    setindex!(a::InstrumentAlazar, rng::Tuple{Symbol,Symbol}, ::Type{InputRange}
Configure the input range for each channel of the digitizer.
"""
function setindex!(a::InstrumentAlazar, rng::Tuple{Symbol,Symbol},
        ::Type{InputRange})
    @eh2 AlazarInputControl(a.handle, Alazar.CHANNEL_A,
        symbol_to_coupling(a.couplingA),
        symbol_to_input_range(rng[1]), Alazar.IMPEDANCE_50_OHM)
    @eh2 AlazarInputControl(a.handle, Alazar.CHANNEL_B,
        symbol_to_coupling(a.couplingB),
        symbol_to_input_range(rng[2]), Alazar.IMPEDANCE_50_OHM)
    a.rangeA, a.rangeB = rng
    nothing
end

"""
    setindex!(a::InstrumentAlazar, ledState::Bool, ::Type{LED})
Configures the LED on the digitizer card chassis.
"""
function setindex!(a::InstrumentAlazar, ledState, ::Type{LED})
    @eh2 AlazarSetLED(a.handle, ledState)
    nothing
end

"""
    setindex!(a::InstrumentAlazar, sleepState, ::Type{Sleep})
Configures the sleep state of the digitizer card.
"""
function setindex!(a::InstrumentAlazar, sleepState, ::Type{Sleep})
    @eh2 AlazarSleepDevice(a.handle, sleepState)
    nothing
end

#
"""
    setindex!(a::InstrumentAlazar, s::Symbol, ::Type{AlazarTimestampReset})
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
    setindex!(a::InstrumentAlazar, eng::Symbol, ::Type{TriggerEngine})
Configures the trigger engines J and K. Available arguments are `:J`, `:K`,
`:JOrK`, `:JAndK`, `:JXorK`, `:JAndNotK`, `:NotJAndK`.
"""
function setindex!(a::InstrumentAlazar, eng::Symbol, ::Type{TriggerEngine})
    set_triggeroperation(a, eng,
        a.sourceJ, a.slopeJ, a.levelJ,
        a.sourceK, a.slopeK, a.levelK)
    nothing
end

"""
    setindex!(a::InstrumentAlazar, slope::Tuple{Symbol,Symbol}, ::Type{TriggerSlope})
Configures whether to trigger on a rising or falling slope, for engine J and K.
"""
function setindex!(a::InstrumentAlazar, slope::Tuple{Symbol,Symbol},
        ::Type{TriggerSlope})
    sJ,sK = slope
    set_triggeroperation(a, a.engine,
        a.sourceJ, sJ, a.levelJ,
        a.sourceK, sK, a.levelK)
    nothing
end

"""
    setindex!(a::InstrumentAlazar, source::Tuple{Symbol,Symbol}, ::Type{TriggerSource})
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
    setindex!(a::InstrumentAlazar, l::Tuple{Integer,Integer}, ::Type{TriggerLevel})
Configure the trigger level for trigger engine J and K, in Volts.
"""
function setindex!(a::InstrumentAlazar, l::Tuple{Integer,Integer},
        ::Type{TriggerLevel})
    levelJ, levelK = l
    set_triggeroperation(a, a.engine,
        a.sourceJ, a.slopeJ, levelJ,
        a.sourceK, a.slopeK, levelK)
    nothing
end

"""
    setindex!(a::InstrumentAlazar, c::Symbol, ::Type{TriggerCoupling})
Configure the external trigger coupling.
"""
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

"""
    setindex!(a::InstrumentAlazar, range, ::Type{TriggerRange})
Configure the external trigger range.
"""
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
    setindex!(a::InstrumentAlazar, delay_samples, ::Type{TriggerDelaySamples})
Configure how many samples to wait after receiving a trigger event before capturing
a record.
"""
function setindex!(a::InstrumentAlazar, delay_samples, ::Type{TriggerDelaySamples})
    @eh2 AlazarSetTriggerDelay(a.handle, delay_samples)
    a.triggerDelaySamples = delay_samples
    nothing
end

"""
    setindex!(a::InstrumentAlazar, ticks, ::Type{TriggerTimeoutTicks})
Wrapper for C function `AlazarSetTriggerTimeOut`.
"""
function setindex!(a::InstrumentAlazar, ticks, ::Type{TriggerTimeoutTicks})
    @eh2 AlazarSetTriggerTimeOut(a.handle, ticks)
    a.triggerTimeoutTicks = ticks
    nothing
end

"""
    setindex!(a::InstrumentAlazar, timeout_s, ::Type{TriggerTimeoutS})
Wrapper for C function `AlazarSetTriggerTimeOut`, except we take seconds here
instead of ticks (units of 10 us).
"""
function setindex!(a::InstrumentAlazar, timeout_s, ::Type{TriggerTimeoutS})
    a[TriggerTimeoutTicks] = ceil(timeout_s * 1.e5)
end
