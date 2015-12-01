# Call set_recordsize first
# function process(a::AlazarATS9360, m::StreamMode, c::Channel)
#     # buffers per Acquisition
#     buf_per_acq = buffersperacquisition(a,m)
#     c = Channel{Array{UInt16,1}}(buffercount(a))
#
#     io = IOBuffer(buf_per_acq * buffersize(a))
#
#     @schedule producer(a,m,c)
#     for (i = 1:buf_per_acq)
#         array = take!(c)
#         for sample in 1:length(array)
#             write(io,ltoh(i))
#         end
#     end
#
#     io
# end

function measure(a::AlazarATS9360, m::StreamMode,
        buf_count=inspect(a, BufferCount), buf_size=inspect(a, BufferSize))

    # set record size; no-op'd for StreamMode
    configure(a, m)

    # Allocate memory for DMA buffers
    buf_array = bufferarray(a, buf_count, buf_size)

    before_async_read(a, m)

    # Add the buffers to a list of buffers available to be filled by the board
    for (buf_index = 1:buf_count)
        p_buffer = buf_array[buf_index].addr
        post_async_buffer(a, p_buffer, buf_size)
    end

    # Wait for each buffer to be filled, process the buffer, and re-post it to
    # the board.
    timeout_ms = 5000
    buf_completed = 0
    by_transferred = 0
    buf_per_acq = inspect_per(a, m, Buffer, Acquisition)

    try
        println("Capturing $buf_per_acq buffers ... ")
        starttime = time()

        # Arm the board system to wait for a trigger event to begin the acquisition
        startcapture(a)

        while (buf_completed < buf_per_acq)

            # Wait for the buffer at the head of the list of available buffers
            # to be filled by the board.

            buf_index = mod(buf_completed, buf_count)
            p_buffer = buf_array[buf_index+1].addr
            wait_async_buffer(a, p_buffer, timeout_ms)

            buf_completed += 1
            by_transferred += buf_size

            # Samples are arranged in the buffer as follows: S0A, S0B, ..., S1A, S1B, ...
            # with SXY the sample number X of channel Y.

            # Sample codes are unsigned by default. As a result:
            # - a sample code of 0x0000 represents a negative full scale input signal.
            # - a sample code of 0x8000 represents a ~0V signal.
            # - a sample code of 0xFFFF represents a positive full scale input signal.

            post_async_buffer(a, p_buffer, buf_size)

            # println("Completed $buf_completed buffers")
        end

        # Display results

        transfertime_s = time() - starttime
        println("Capture completed in $transfertime_s s")

        rec_transferred = inspect_per(a,m,Record,Buffer) * buf_completed

        if (transfertime_s > 0.)
            buf_per_s = buf_completed / transfertime_s
            by_per_s = by_transferred / transfertime_s
            rec_per_s = rec_transferred / transfertime_s
        else
            buf_per_s = 0.
            by_per_s = 0.
            rec_per_s = 0.
        end

        println("Captured $buf_completed buffers ($buf_per_s buffers / s)")
        println("Captured $rec_transferred records ($rec_per_s records / s)")
        println("Transferred $by_transferred bytes ($by_per_s bytes / s)")

    finally
        # Abort the acquisition
        abort(a)
    end
    postprocess(a,m,buf_array)
end

function postprocess(a::AlazarATS9360, m::StreamMode, array::AbstractArray)
    out = Array{AbstractFloat,1}()
    for dma_buffer in array
        for sample in dma_buffer.array
            s = (ltoh(sample) >> 4)/0xFFF    ## All Alazar digitizers store little endian.
            s = s*0.8-0.4
            push!(out,s)
        end
    end
    out
end
