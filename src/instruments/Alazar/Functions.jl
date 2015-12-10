export abort
export before_async_read
export busy
export forcetrigger
export forcetriggerenable
export inputcontrol
export post_async_buffer
export set_parameter
export set_parameter_ul
export set_triggeroperation
export startcapture
export triggered
export wait_buffer

function abort(a::InstrumentAlazar, m::AlazarMode)
    @eh2 AlazarAbortAsyncRead(a.handle)
end

function before_async_read(a::InstrumentAlazar, m::AlazarMode)

    pretrig = -pretriggersamples(m) / inspect(a, ChannelCount)
    sam_rec_ch = inspect_per(a, m, Sample, Record) / inspect(a, ChannelCount)

    println("Pretrigger samples: $(pretriggersamples(m))")
    println("Samples per record: $(inspect_per(a, m, Sample, Record))")
    println("Records per buffer: $(inspect_per(a, m, Record, Buffer))")
    println("Records per acquis: $(inspect_per(a, m, Record, Acquisition))")
    sleep(1)
    r = @eh2 AlazarBeforeAsyncRead(a.handle,
                                   a.acquisitionChannel,
                                   pretrig,
                                   sam_rec_ch,
                                   inspect_per(a, m, Record, Buffer),
                                   inspect_per(a, m, Record, Acquisition),
                                   adma(m))
    r
end

function boardhandle(sysid::Integer,boardid::Integer)
    r = AlazarGetBoardBySystemID(sysid,boardid)
    r == C_NULL && error("Not found: system ID $sysid, board ID $boardid")
    r
end

boardkind(handle::U32) = AlazarGetBoardKind(handle)

busy(a::InstrumentAlazar) = AlazarBusy(a.handle) > 0 ? true : false

@eh forcetrigger(a::InstrumentAlazar) = AlazarForceTrigger(a.handle)

@eh forcetriggerenable(a::InstrumentAlazar) = AlazarForceTriggerEnable(a.handle)

@eh inputcontrol(a::InstrumentAlazar, channel, coupling, inputRange, impedance) =
    AlazarInputControl(a.handle, channel, coupling, inputRange, impedance)

@eh post_async_buffer(a::InstrumentAlazar, buffer, bufferLength) =
    AlazarPostAsyncBuffer(a.handle, buffer, bufferLength)

@eh set_parameter(a::InstrumentAlazar, channelId, parameterId, value) =
    AlazarSetParameter(a.handle, channelId, parameterId, value)

@eh set_parameter_ul(a::InstrumentAlazar, channelId, parameterId, value) =
    AlazarSetParameterUL(a.handle, channelId, parameterId, value)

function set_triggeroperation(a::InstrumentAlazar, args...)
    if length(args) != 7
        error("Need 7 arguments beside the instrument: operation, source1, ",
            "slope1, level1, source2, slope2, level2.")
    end
    r = @eh2 AlazarSetTriggerOperation(a.handle, args[1], Alazar.TRIG_ENGINE_J,
            args[2:4]..., Alazar.TRIG_ENGINE_K, args[5:7]...)
    (a.triggerOperation,
        a.triggerJChannel, a.triggerJSlope, a.triggerJLevel,
        a.triggerKChannel, a.triggerKSlope, a.triggerKLevel) = (args...)
    r
end

@eh startcapture(a::InstrumentAlazar) = AlazarStartCapture(a.handle)

@eh triggered(a::InstrumentAlazar) = AlazarTriggered(a.handle)

@eh wait_buffer(a::InstrumentAlazar, m::AlazarMode, buffer, timeout_ms) =
    AlazarWaitAsyncBufferComplete(a.handle, buffer, timeout_ms)
