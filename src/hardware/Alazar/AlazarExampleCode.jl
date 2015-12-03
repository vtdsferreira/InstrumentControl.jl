abstract AlazarResponse <: Response

type RawTimeDomainResponse <: AlazarResponse
    ins::InstrumentAlazar
    samples_per_ch::Integer

    RawTimeDomainResponse(a,b) = begin
        b <= 0 && error("Need at least one sample!")
        new(a,b)
    end
end

function measure(ch::RawTimeDomainResponse)

    a = ch.ins

    chans = inspect(a, ChannelCount)
    ts = ch.samples_per_ch * chans

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

    elseif ts * by_sam > max_size_buf

        # There will be multiple buffers, so we should make sure that they are
        # sized in multiples of the page size.

        # Choose biggest buffer <= the max size that is commensurate with
        # *both* the page size and (bytes/sample * channels)

        buf_grain = lcm(by_sam*chans, Base.Mmap.PAGESIZE)
        size_buf = fld(max_size_buf, buf_grain) * buf_grain

    else
        size_buf = ts * by_sam
    end

    m = ContinuousStreamMode(ts)

    # Buffers/acquisition is not the same as buffer count, in general.
    # buffer count determines how many buffers are allocated; a greater numbers
    # of buffers/acquisition may result in reuse of the allocated buffers.
    # In this case we do not want reuse of buffers

    configure(a, BufferSize, size_buf)
    buf_per_acq = inspect_per(a, m, Buffer, Acquisition)

    configure(a, BufferCount, buf_per_acq)

    buf_array = measure(a, m)
    postprocess(ch, buf_array)
end

function measure(a::AlazarATS9360, m::StreamMode)

    # Initialize some parameters
    buf_size = inspect(a, BufferSize)
    buf_count = inspect(a, BufferCount)
    timeout_ms = 5000
    buf_completed = 0
    by_transferred = 0

    # Sets record size and is followed by before_async_read
    configure(a, m)

    # Allocate memory for DMA buffers
    buf_array =
        Alazar.DMABufferArray(inspect_per(a, Byte, Sample), buf_size, buf_count)

    # Add the buffers to a list of buffers available to be filled by the board
    for buffer in buf_array
        post_async_buffer(a, buffer, buf_size)
    end

    try
        println("Capturing $(length(buf_array)) buffers...")
        starttime = time()

        # Arm the board system to wait for a trigger event to begin the acquisition
        startcapture(a)

        for buffer in buf_array

            wait_async_buffer(a, buffer, timeout_ms)

            buf_completed += 1
            by_transferred += buf_size

            # post_async_buffer(a, p_buffer, buf_size)
        end

        # Display results
        transfertime_s = time() - starttime
        println("Capture completed in $transfertime_s s")

        rec_transferred = inspect_per(a, m, Record, Buffer) * buf_completed

        if (transfertime_s > 0.)
            buf_per_s = buf_completed / transfertime_s
            by_per_s  = by_transferred / transfertime_s
            rec_per_s = rec_transferred / transfertime_s
        else
            buf_per_s = 0.
            by_per_s  = 0.
            rec_per_s = 0.
        end

        println("Captured $buf_completed buffers ($buf_per_s buffers / s)")
        println("Captured $rec_transferred records ($rec_per_s records / s)")
        println("Transferred $by_transferred bytes ($by_per_s bytes / s)")

    finally
        # Gracefully stop the acquisition, even if it failed
        abort(a)
    end

    buf_array
end

function postprocess(ch::RawTimeDomainResponse, dma_array::Alazar.DMABufferArray)
    t0=time()
    buffer = dma_array.buffer
    @sync begin
        for p in procs(buffer)
            @async begin
                remotecall_wait(p, tofloat!, buffer)
            end
        end
    end
    # for i in 1:length(buffer)
    #     # All Alazar digitizers are little endian.
    #     buffer[i] = ltoh(buffer[i]) #/ 0xFFF0
    #     #s = s*0.8
    #     #buffer[i] = reinterpret(UInt16,s)
    # end
    time()-t0
    #buffer
end

@everywhere include("C:\\Users\\Discord\\Documents\\Instruments.jl\\src\\hardware\\Alazar\\AlazarParallel.jl")
