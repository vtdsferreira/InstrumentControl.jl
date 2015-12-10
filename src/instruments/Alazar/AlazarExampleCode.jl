import PainterQB: measure, Response

abstract AlazarResponse{T} <: Response{T}
abstract StreamResponse{T} <: AlazarResponse{T}
abstract RecordResponse{T} <: AlazarResponse{T}

type ContinuousStreamResponse{T} <: StreamResponse{T}
    ins::InstrumentAlazar
    samples_per_ch::Int

    m::AlazarMode

    ContinuousStreamResponse(a,b) = begin
        b <= 0 && error("Need at least one sample.")
        r = new(a,b)
        r.m = mode4response(r)
        r
    end
end
ContinuousStreamResponse(a::AlazarATS9360, samples_per_ch) =
    ContinuousStreamResponse{SharedArray{Float16,1}}(a,samples_per_ch)

type TriggeredStreamResponse{T} <: StreamResponse{T}
    ins::InstrumentAlazar
    samples_per_ch::Int

    m::AlazarMode

    TriggeredStreamResponse(a,b) = begin
        b <= 0 && error("Need at least one sample.")
        r = new(a,b)
        r.m = mode4response(r)
        r
    end
end
TriggeredStreamResponse(a::AlazarATS9360, samples_per_ch) =
    TriggeredStreamResponse{SharedArray{Float16,1}}(a, samples_per_ch)

type NPTRecordResponse{T} <: RecordResponse{T}
    ins::InstrumentAlazar
    sam_per_rec_per_ch::Int
    total_recs::Int

    m::AlazarMode

    NPTRecordResponse(a,b,c) = begin
        b <= 0 && error("Need at least one sample.")
        c <= 0 && error("Need at least one record.")
        r = new(a,b,c)
        r.m = mode4response(r)
        r
    end
end
NPTRecordResponse(a::AlazarATS9360, sam_per_rec_per_ch, total_recs) =
    NPTRecordResponse{SharedArray{Float16,2}}(a, sam_per_rec_per_ch, total_recs)

type FFTRecordResponse{T} <: RecordResponse{T}
    ins::InstrumentAlazar
    sam_per_rec::Int
    sam_per_fft::Int
    total_recs::Int
    output_eltype::DataType

    m::AlazarMode

    FFTRecordResponse(a,b,c,d,e) = begin
        b <= 0 && error("Need at least one sample.")
        c == 0 && error("FFT length (samples) too short.")
        !ispow2(c) && error("FFT length (samples) not a power of 2.")
        d <= 0 && error("Need at least one record.")
        !(e <: Alazar.AlazarFFTBits) && error("Takes an AlazarFFTBits type.")
        r = new(a,b,c,d,e)
        r.m = mode4response(r)
        r
    end
end
FFTRecordResponse{S<:Alazar.AlazarFFTBits}(a,b,c,d,e::Type{S}) =
    FFTRecordResponse{SharedArray{S,2}}(a,b,c,d,e)

function measure(ch::AlazarResponse)
    a = ch.ins
    m = ch.m

    # Calculate and adjust record and buffer sizes.
    buffersizing(a,m)

    # Sets record size or performs FFT setup if needed.
    # Calls before_async_read with appropriate parameters.
    prepare(a,m)

    # Buffers/acquisition is not the same as buffer count, in general.
    # Buffer count determines how many buffers are allocated; a greater numbers
    # of buffers/acquisition may result in reuse of the allocated buffers.
    # In applications where we don't want indefinite acquisition time,
    # we choose *not* to reuse buffers.
    configure(a, BufferCount, inspect_per(a, m, Buffer, Acquisition))
    println("Buf/acq: $(inspect_per(a,m,Buffer,Acquisition))")

    # Measure and interpret
    buf_array = measure(a, m, during=processing(ch))
    postprocess(ch, buf_array)
end

mode4response(ch::ContinuousStreamResponse) =
    ContinuousStreamMode(ch.samples_per_ch * inspect(ch.ins, ChannelCount))
mode4response(ch::TriggeredStreamResponse) =
    TriggeredStreamMode(ch.samples_per_ch * inspect(ch.ins, ChannelCount))
mode4response(ch::NPTRecordResponse) =
    NPTRecordMode(ch.sam_per_rec_per_ch * inspect(ch.ins, ChannelCount),
                  ch.total_recs)
mode4response(ch::FFTRecordResponse) =
    FFTRecordMode(ch.sam_per_rec, ch.sam_per_fft, ch.total_recs, ch.output_eltype)

processing(::StreamResponse) = tofloat!
processing(::RecordResponse) = tofloat!
processing(::FFTRecordResponse) = ((x,y,z)->nothing)

function measure(a::AlazarATS9360, m::AlazarMode;
    during::Function=((x,y,z)->nothing), diagnostic::Bool=false)

    # Initialize some parameters
    buf_size = inspect(a, BufferSize)
    buf_count = inspect(a, BufferCount)
    println(buf_size," ",buf_count)
    timeout_ms = 5000
    buf_completed = 0
    by_transferred = 0
    transfertime_s = 0

    # Allocate memory for DMA buffers
    buf_array = bufferarray(a,m)

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
            wait_buffer(a, m, dmaptr, timeout_ms)
            during(sam_per_buf, buf_completed, backing)
            buf_completed += 1
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
        # Gracefully stop the acquisition, even if it failed.
        # Strictly required when doing DSP, like FFTs.
        abort(a,m)
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

function postprocess{T}(ch::AlazarResponse{SharedArray{T,1}}, buf_array::Alazar.DMABufferArray)
    backing = buf_array.backing
    if sizeof(T) == sizeof(eltype(backing))
        convert(SharedArray, reinterpret(T, sdata(backing)))::SharedArray{T,1}
    else
        convert(SharedArray, convert(T, sdata(backing)))::SharedArray{T,1}
    end
end

function postprocess{T}(ch::AlazarResponse{SharedArray{T,2}}, buf_array::Alazar.DMABufferArray)
    backing = buf_array.backing
    if sizeof(T) == sizeof(eltype(backing))
        array = reinterpret(T, sdata(backing))  # now it has els of type T
        # Get 2D dimensions
    else
        array = convert(T, sdata(backing))
    end
    sam_per_rec = inspect_per(ch.ins, ch.m, Sample, Record)
    rec_per_acq = inspect_per(ch.ins, ch.m, Record, Acquisition)
    array = reshape(array, sam_per_rec, rec_per_acq)
    convert(SharedArray, array)::SharedArray{T,2}
end
