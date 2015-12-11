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

# eventually we will not export these:
export bufferarray
export buffersizing
export prepare

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

function bufferarray(a::InstrumentAlazar, m::AlazarMode)
    bits = inspect_per(a, Bit, Sample)
    btype = begin # which does not introduce a new scope block, fyi
        bits == 8 ? Alazar8Bit :
        (bits == 12 ? Alazar12Bit : Alazar16Bit)
    end
    buf_size = inspect(a, BufferSize)
    buf_count = inspect(a, BufferCount)
    return Alazar.DMABufferArray{btype}(buf_size, buf_count)
end

function buffersizing(a::InstrumentAlazar, m::RecordMode)

    sr = m.sam_per_rec
    tr = m.total_recs

    chans = inspect(a, ChannelCount)
    min_sam = inspect(a, MinSamplesPerRecord)
    pagesize = Base.Mmap.PAGESIZE
    by_sam = inspect_per(a, Byte, Sample)

    # rec_align is the alignment needed for the start of each buffer, in bytes
    rec_align = inspect(a, BufferAlignment) * by_sam

    # buf_grain is the granularity of buffer allocation in bytes
    buf_grain = lcm(by_sam*chans, pagesize, rec_align)

    # max_buf_size will contain the largest acceptable buffer (in bytes)
    max_size_buf = inspect(a, MaxBufferBytes)
    max_size_buf = fld(max_size_buf, buf_grain) * buf_grain

    if sr * by_sam > max_size_buf
        # Record too big for one buffer. Choose largest possible record.
        size_buf = max_size_buf

        # Issue a warning and proceed.
        m.sam_per_rec = Int(size_buf/by_sam)
        warn("Samples per record has been truncated to $(m.sam_per_rec) ",
             "because of buffer size limitations.")
    else
        if sr < min_sam
            # Too few samples in record. Choose shortest possible record.
            # It seems that this will always be divisible by the number of channels,
            # at least for existing Alazar digitizers.
            sr = min_sam
            m.sam_per_rec = sr

            # Issue a warning and proceed.
            warn("Samples per record adjusted to $sr to meet minimum record ",
                 "length requirements.")
        end

        size_rec = cld(by_sam*sr, rec_align)*rec_align
        sr = Int(size_rec / by_sam) # will be an integer for sure
        sr != m.sam_per_rec &&
            warn("Samples per record adjusted to $sr to meet alignment ",
                 "requirements.")
        m.sam_per_rec = sr

        if sr * tr * by_sam > max_size_buf
            # Not everything will fit in one buffer.
            # Grow samples / record slightly so that it takes up the nearest
            # buffer granularity. Note that it cannot grow larger than
            # max_size_buf because we checked for that already.
            size_rec = cld(by_sam*sr, buf_grain)*buf_grain
            sr = Int(size_rec / by_sam) # will be an integer for sure
            sr != m.sam_per_rec &&
                warn("Samples per record adjusted to $sr to meet alignment ",
                     "requirements.")
            m.sam_per_rec = sr

            # Now we have to choose the buffer size carefully because
            # we need to have all buffers completely filled.
            # max_recs_buf: maximum number of records that will fit in a buffer
            max_recs_buf = fld(max_size_buf, size_rec)
            recs_buf = indmax([gcd(i, tr) for i in collect(1:max_recs_buf)])

            size_buf = recs_buf * size_rec
        else
            # Only one buffer.
            # We don't need to worry about alignment of nth buffer.
            size_buf = sr * tr * by_sam
        end
    end

    configure(a, BufferSize, size_buf)
    println("Buffer size: $size_buf")
end

function buffersizing(a::InstrumentAlazar, m::StreamMode)

    ts = m.total_samples

    chans = inspect(a, ChannelCount)
    min_sam = inspect(a, MinSamplesPerRecord)
    pagesize = Base.Mmap.PAGESIZE
    by_sam = inspect_per(a, Byte, Sample)

    # There may be multiple buffers. We choose to make sure that they are
    # sized in multiples of the page size so that multiple buffers can come from
    # a contiguous allocation of memory. Choose biggest buffer <= the digitizer's
    # max size that is commensurate with *both* the page size and
    # (bytes/sample * channels)
    max_size_buf = inspect(a, MaxBufferBytes)    # from the digitizer's perspective.
    buf_grain = lcm(by_sam*chans, pagesize)
    max_size_buf = fld(max_size_buf, buf_grain) * buf_grain # from our requirements

    if ts < min_sam
        # Some digitizers may measure 3 channels or some ugly number so
        # we want the smallest sample count divisible by the number of channels.
        # Only one buffer so we don't worry about the page size.
        ts = cld(min_sam, chans) * chans
        size_buf = ts * by_sam
        m.total_samples = ts
        warn("Total samples adjusted to $ts to meet minimum record ",
             "length requirements.")
    elseif ts * by_sam > max_size_buf
        size_buf = max_size_buf
        # POTENTIAL BUG: < min_sam samples in last buffer???
    else
        size_buf = ts * by_sam
    end

    configure(a, BufferSize, size_buf)
end

busy(a::InstrumentAlazar) = AlazarBusy(a.handle) > 0 ? true : false

@eh forcetrigger(a::InstrumentAlazar) = AlazarForceTrigger(a.handle)

@eh forcetriggerenable(a::InstrumentAlazar) = AlazarForceTriggerEnable(a.handle)

@eh inputcontrol(a::InstrumentAlazar, channel, coupling, inputRange, impedance) =
    AlazarInputControl(a.handle, channel, coupling, inputRange, impedance)

function prepare(a::InstrumentAlazar, m::RecordMode)
    r = @eh2 AlazarSetRecordSize(a.handle,
                                 0,
                                 m.sam_per_rec / inspect(a,ChannelCount))

    before_async_read(a,m)
end

function prepare(a::InstrumentAlazar, m::TraditionalRecordMode)
    r = @eh2 AlazarSetRecordSize(a.handle,
                                 m.pre_sam_pre_rec / inspect(a,ChannelCount),
                                 m.post_sam_per_rec / inspect(a,ChannelCount))

    before_async_read(a,m)
end

# In streaming mode we don't need to do anything besides before_async_read
function prepare(a::InstrumentAlazar, m::StreamMode)
    before_async_read(a,m)
end

@eh post_async_buffer(a::InstrumentAlazar, buffer, bufferLength) =
    AlazarPostAsyncBuffer(a.handle, buffer, bufferLength)

@eh set_parameter(a::InstrumentAlazar, channelId, parameterId, value) =
    AlazarSetParameter(a.handle, channelId, parameterId, value)

@eh set_parameter_ul(a::InstrumentAlazar, channelId, parameterId, value) =
    AlazarSetParameterUL(a.handle, channelId, parameterId, value)

function set_triggeroperation(a::InstrumentAlazar, args...)
    if length(args) != 7
        error("Need 7 arguments beside the instrument: engine, source1, ",
            "slope1, level1, source2, slope2, level2.")
    end
    r = @eh2 AlazarSetTriggerOperation(a.handle, args[1],
        Alazar.TRIG_ENGINE_J, args[2], args[3], triglevel(a,args[4]),
        Alazar.TRIG_ENGINE_K, args[5], args[6], triglevel(a,args[7]))
    (a.engine,
        a.channelJ, a.slopeJ, a.levelJ,
        a.channelK, a.slopeK, a.levelK) = (args...)
    r
end

@eh startcapture(a::InstrumentAlazar) = AlazarStartCapture(a.handle)

@eh triggered(a::InstrumentAlazar) = AlazarTriggered(a.handle)

@eh wait_buffer(a::InstrumentAlazar, m::AlazarMode, buffer, timeout_ms) =
    AlazarWaitAsyncBufferComplete(a.handle, buffer, timeout_ms)
