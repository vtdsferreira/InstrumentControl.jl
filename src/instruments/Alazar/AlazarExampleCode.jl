import PainterQB: measure, Response

abstract AlazarResponse{T} <: Response{T}
abstract StreamResponse{T} <: AlazarResponse{T}
abstract RecordResponse{T} <: AlazarResponse{T}

type ContinuousStreamResponse{T} <: StreamResponse{T}
    ins::InstrumentAlazar
    samples_per_ch::Int

    ContinuousStreamResponse(a,b) = begin
        b <= 0 && error("Need at least one sample!")
        new(a,b)
    end
end
ContinuousStreamResponse(a::AlazarATS9360, samples_per_ch) =
    ContinuousStreamResponse{SharedArray{Float16,1}}(a,samples_per_ch)

type TriggeredStreamResponse{T} <: StreamResponse{T}
    ins::InstrumentAlazar
    samples_per_ch::Int

    TriggeredStreamResponse(a,b) = begin
        b <= 0 && error("Need at least one sample!")
        new(a,b)
    end
end
TriggeredStreamResponse(a::AlazarATS9360, samples_per_ch) =
    TriggeredStreamResponse{SharedArray{Float16,1}}(a, samples_per_ch)

type NPTRecordResponse{T} <: RecordResponse{T}
    ins::InstrumentAlazar
    sam_per_rec_per_ch::Int
    total_recs::Int

    NPTRecordResponse(a,b,c) = begin
        b <= 0 && error("Need at least one sample!")
        c <= 0 && error("Need at least one record!")
        new(a,b,c)
    end
end
NPTRecordResponse(a::AlazarATS9360, sam_per_rec_per_ch, total_recs) =
    NPTRecordResponse{SharedArray{Float16,2}}(a, sam_per_rec_per_ch, total_recs)

type FFTRecordResponse{T} <: RecordResponse{T}
    ins::InstrumentAlazar
    sam_per_rec_per_ch::Int
    total_recs::Int

    FFTRecordResponse(a,b,c) = begin
        b <= 0 && error("Need at least one sample!")
        c <= 0 && error("Need at least one record!")
        new(a,b,c)
    end
end
FFTRecordResponse(a::AlazarATS9360, sam_per_rec_per_ch, total_recs) =
    FFTRecordResponse{SharedArray{Float16,2}}(a, sam_per_rec_per_ch, total_recs)


function measure(ch::AlazarResponse)
    a = ch.ins
    m = mode4response(ch)
    buffersizing(a,m)

    # Sets record size and is followed by before_async_read
    configure(a, m)

    # Buffers/acquisition is not the same as buffer count, in general.
    # buffer count determines how many buffers are allocated; a greater numbers
    # of buffers/acquisition may result in reuse of the allocated buffers.
    # In this case we do not want reuse of buffers.
    configure(a, BufferCount, inspect_per(a, m, Buffer, Acquisition))

    # Measure and interpret as SharedArray{Float16,1}
    buf_array = measure(a, m, during=processing(ch))
    postprocess(ch, buf_array)
end

mode4response(ch::ContinuousStreamResponse) =
    ContinuousStreamMode(ch.samples_per_ch * inspect(ch.ins, ChannelCount))
mode4response(ch::TriggeredStreamResponse) =
    TriggeredStreamMode(ch.samples_per_ch * inspect(ch.ins, ChannelCount))
mode4response(ch::NPTRecordResponse) =
    NPTRecordMode(ch.sam_per_rec_per_ch * inspect(ch.ins, ChannelCount), ch.total_recs)
mode4response(ch::FFTRecordResponse) =
    FFTRecordMode(ch.sam_per_rec_per_ch * inspect(ch.ins, ChannelCount), ch.total_recs)

# function buffersizing(a::InstrumentAlazar, m::RecordMode)
#
#     sr = m.sam_per_rec
#     tr = m.total_recs
#
#     chans = inspect(a, ChannelCount)
#     min_sam = inspect(a, MinSamplesPerRecord)
#     max_size_buf = inspect(a, MaxBufferSize)
#     by_sam = inspect_per(a, Byte, Sample)
#     pagesize = Base.Mmap.PAGESIZE
#     buf_grain = lcm(by_sam*chans, pagesize)
#
#     if sr < min_sam
#         # Some digitizers may measure 3 channels or some ugly number so
#         # we want the smallest sample count divisible by the number of channels.
#         # Only one buffer so we don't worry about the page size.
#         sr = cld(min_sam, chans) * chans
#         m.sam_per_rec = sr
#         warn("Samples per record adjusted to $sr to meet minimum record ",
#              "length requirements.")
#
#         # Now, will everything fit in one buffer or not?
#         if sr * tr * by_sam > max_size_buf
#             size_buf = fld(max_size_buf, buf_grain) * buf_grain
#         else
#             size_buf = sr * tr * by_sam
#         end
#     elseif sr * by_sam > max_size_buf
#         # There may be multiple buffers, so we should make sure that they are
#         # sized in multiples of the page size. Choose biggest buffer <= the max
#         # size that is commensurate with *both* the page size and
#         # (bytes/sample * channels)
#         size_buf = fld(max_size_buf, buf_grain) * buf_grain
#
#         # We can have at minimum one record per buffer, so we need to truncate
#         # the record size. There's really no way around this, so we issue a
#         # warning and proceed.
#         m.sam_per_rec = fld(size_buf,by_sam)
#         warn("Samples per record has been truncated to $(m.sam_per_rec) ",
#              "because of buffer size limitations.")
#     else
#         size_b
#     end
#
#     configure(a, BufferSize, size_buf)
# end

function buffersizing(a::InstrumentAlazar, m::StreamMode)

    ts = m.total_samples

    chans = inspect(a, ChannelCount)
    min_sam = inspect(a, MinSamplesPerRecord)
    max_size_buf = inspect(a, MaxBufferSize)
    by_sam = inspect_per(a, Byte, Sample)
    pagesize = Base.Mmap.PAGESIZE

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
        # There will be multiple buffers, so we should make sure that they are
        # sized in multiples of the page size. Choose biggest buffer <= the max
        # size that is commensurate with *both* the page size and
        # (bytes/sample * channels)
        buf_grain = lcm(by_sam*chans, pagesize)
        size_buf = fld(max_size_buf, buf_grain) * buf_grain

        # POTENTIAL BUG: < min_sam samples in last buffer???
    else
        size_buf = ts * by_sam
    end

    configure(a, BufferSize, size_buf)
end

processing(::StreamResponse) = tofloat!

function measure(a::AlazarATS9360, m::StreamMode; during::Function=((x,y,z)->nothing), diagnostic::Bool=false)

    # Initialize some parameters
    buf_size = inspect(a, BufferSize)
    buf_count = inspect(a, BufferCount)
    timeout_ms = 5000
    buf_completed = 0
    by_transferred = 0
    transfertime_s = 0

    # Allocate memory for DMA buffers
    buf_array =
        Alazar.DMABufferArray(inspect_per(a, Bit, Sample), buf_size, buf_count)

    # Add the buffers to a list of buffers available to be filled by the board
    for dmaptr in buf_array
        post_async_buffer(a, dmaptr, buf_size)
    end

    backing = buf_array.backing
    sam_per_buf = inspect_per(a, m, Sample, Buffer)

    try
        diagnostic && begin
            println("Capturing $(length(buf_array)) buffers...")
            starttime = time()
        end

        # Arm the board system to wait for a trigger event to begin the acquisition
        startcapture(a)

        for dmaptr in buf_array

            wait_async_buffer(a, dmaptr, timeout_ms)
            during(sam_per_buf, buf_completed, backing)
            buf_completed += 1
            # post_async_buffer(a, dmaptr, buf_size)
        end

        # Display results
        diagnostic && begin
            transfertime_s = time() - starttime
            println("Capture completed in $transfertime_s s")

            rec_transferred = inspect_per(a, m, Record, Buffer) * buf_count

            if (transfertime_s > 0.)
                buf_per_s = buf_completed / transfertime_s
                by_per_s  = buf_count * buf_size / transfertime_s
                rec_per_s = rec_transferred / transfertime_s
            else
                buf_per_s = 0.
                by_per_s  = 0.
                rec_per_s = 0.
            end

            println("Captured $buf_completed buffers ($buf_per_s buffers / s)")
            println("Captured $rec_transferred records ($rec_per_s records / s)")
            println("Transferred $by_transferred bytes ($by_per_s bytes / s)")
        end
    finally
        # Gracefully stop the acquisition, even if it failed
        abort(a)
    end

    buf_array
end

function tofloat!(sam_per_buf::Integer, buf_completed::Integer, backing::SharedArray)
    @sync begin
        samplerange = ((1:sam_per_buf) + buf_completed*sam_per_buf)
        for p in procs(backing)
            @async begin
                remotecall_wait(p, worker_tofloat!, backing, samplerange)
            end
        end
    end
end

function postprocess{T}(ch::StreamResponse{SharedArray{T,1}}, buf_array::Alazar.DMABufferArray)
    backing = buf_array.backing
    if sizeof(T) == sizeof(eltype(backing))
        convert(SharedArray, reinterpret(T, sdata(backing)))::SharedArray{T,1}
    else
        convert(SharedArray, convert(T, sdata(backing)))::SharedArray{T,1}
    end
end
