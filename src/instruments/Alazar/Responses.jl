export ContinuousStreamResponse
export TriggeredStreamResponse
export NPTRecordResponse
export FFTHardwareResponse
export FFTSoftwareResponse
export AlternatingRealImagResponse

export measure
import PainterQB.scaling

abstract AlazarResponse{T} <: Response{T}
abstract StreamResponse{T} <: AlazarResponse{T}
abstract RecordResponse{T} <: AlazarResponse{T}
abstract FFTResponse{T}    <: AlazarResponse{T}

type ContinuousStreamResponse{T} <: StreamResponse{T}
    ins::InstrumentAlazar
    samples_per_ch::Int

    m::AlazarMode

    ContinuousStreamResponse(a,b) = begin
        b <= 0 && error("Need at least one sample.")
        r = new(a,b)
        r.m = ContinuousStreamMode(r.samples_per_ch *
                                   inspect(r.ins, ChannelCount))
        r
    end
end
ContinuousStreamResponse(a::InstrumentAlazar, samples_per_ch) =
    ContinuousStreamResponse{SharedArray{Float16,1}}(a, samples_per_ch)

type TriggeredStreamResponse{T} <: StreamResponse{T}
    ins::InstrumentAlazar
    samples_per_ch::Int

    m::AlazarMode

    TriggeredStreamResponse(a,b) = begin
        b <= 0 && error("Need at least one sample.")
        r = new(a,b)
        r.m = TriggeredStreamMode(r.samples_per_ch *
                                  inspect(r.ins, ChannelCount))
        r
    end
end
TriggeredStreamResponse(a::InstrumentAlazar, samples_per_ch) =
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
        r.m = NPTRecordMode(r.sam_per_rec_per_ch * inspect(r.ins, ChannelCount),
                            r.total_recs)
        r
    end
end
NPTRecordResponse(a::InstrumentAlazar, sam_per_rec_per_ch, total_recs) =
    NPTRecordResponse{SharedArray{Float16,2}}(a, sam_per_rec_per_ch, total_recs)

type FFTHardwareResponse{T} <: FFTResponse{T}
    ins::InstrumentAlazar
    sam_per_rec::Int
    sam_per_fft::Int
    total_recs::Int
    output_eltype::DataType

    m::AlazarMode

    FFTHardwareResponse(a,b,c,d,e) = begin
        b <= 0 && error("Need at least one sample.")
        c == 0 && error("FFT length (samples) too short.")
        !ispow2(c) && error("FFT length (samples) not a power of 2.")
        d <= 0 && error("Need at least one record.")
        !(e <: Alazar.AlazarFFTBits) && error("Takes an AlazarFFTBits type.")
        r = new(a,b,c,d,e)
        r.m = FFTRecordMode(r.sam_per_rec, r.sam_per_fft,
                            r.total_recs, r.output_eltype)
        r
    end
end
FFTHardwareResponse{S<:Alazar.AlazarFFTBits}(a,b,c,d,e::Type{S}) =
    FFTHardwareResponse{SharedArray{S,2}}(a,b,c,d,e)

type FFTSoftwareResponse{T} <: FFTResponse{T}
    ins::Instrument
    sam_per_rec::Int
    sam_per_fft::Int
    total_recs::Int

    m::AlazarMode

    FFTSoftwareResponse(a,b,c,d) = begin
        b <= 0 && error("Need at least one sample.")
        c == 0 && error("FFT length (samples) too short.")
        !ispow2(c) && error("FFT length (samples) not a power of 2.")
        d <= 0 && error("Need at least one record.")
        r = new(a,b,c,d,e)
        r.m = NPTRecordMode(r.sam_per_rec, r.total_recs)
        r
    end
end

type AlternatingRealImagResponse{T} <: FFTResponse{T}
    ins::InstrumentAlazar
    sam_per_rec::Int
    sam_per_fft::Int
    total_recs::Int

    mRe::AlazarMode
    mIm::AlazarMode

    AlternatingRealImagResponse(a,b,c,d) = begin
        b <= 0 && error("Need at least one sample.")
        c == 0 && error("FFT length (samples) too short.")
        !ispow2(c) && error("FFT length (samples) not a power of 2.")
        d <= 0 && error("Need at least one record.")
        r = new(a,b,c,d)
        r.mRe = FFTRecordMode(r.sam_per_rec, r.sam_per_fft,
                              1, Alazar.S32Real)
        r.mIm = FFTRecordMode(r.sam_per_rec, r.sam_per_fft,
                              1, Alazar.S32Imag)
        r
    end
end

# Triangular dispatch would be nice here (waiting for Julia 0.5)
# scaling{T, S<:AbstractArray{T,2}}(resp::FFTRecordResponse{S}, ...

function scaling{T<:AbstractArray}(resp::FFTResponse{T},
        whichaxis::Integer=1)

    rate = inspect(resp.ins, SampleRate)
    npts = resp.m.sam_per_fft # single-sided
    dims = T.parameters[2]::Int
    if (dims == 1)
        @assert whichaxis == 1
        return repeat(collect(0:rate/npts:(rate/2-rate/npts)),outer=[resp.m.total_recs])
    elseif (dims == 2)
        @assert 1<=whichaxis<=2
        if (whichaxis == 1)
            return collect(0:rate/npts:(rate/2-rate/npts))
        else
            return collect(1:resp.m.total_recs)
        end
    end

end

function measure(ch::AlternatingRealImagResponse; diagnostic::Bool=false)
    a = ch.ins
    mRe = ch.mRe
    mIm = ch.mIm

    # Calculate and adjust record and buffer sizes.
    buffersizing(a,mRe)
    buffersizing(a,mIm)
    mRe.buf_count = 1
    mIm.buf_count = 1

    windowing(a,mRe)

    timeout_ms = 5000
    buf_completed = 0
    by_transferred = 0
    transfertime_s = 0

    re_buf = bufferarray(a,mRe)
    im_buf = bufferarray(a,mIm)

    # Assumes both are 32-bit integers
    final_buf = Alazar.DMABufferArray{Int32}(
                    4 * ch.total_recs * ch.sam_per_fft * 2, 1)

    # We are going to alternate between real and imaginary FFTs
    buf_iter = cycle((re_buf, im_buf))
    bis = start(buf_iter)

    mode_iter = cycle((mRe, mIm))
    mis = start(mode_iter)

    j = 1
    for i = 1:(ch.total_recs*2)
        println(i," ",j)

        (m, mis) = next(mode_iter, mis)
        (buf, bis) = next(buf_iter, bis)

        println(buf[1])
        println(m.buf_size)

        before_async_read(a, m)
        post_async_buffer(a, buf[1], m.buf_size)

        try
            # Arm the board system to wait for a trigger event to begin the acquisition
            startcapture(a)
            wait_buffer(a, m, buf[1], timeout_ms)
            for k = 1:div(m.sam_per_fft,2)
                final_buf.backing[j] = convert(Int32, buf.backing[k])
                j+=1
            end

            buf_completed += 1
        finally
            # Gracefully stop the acquisition, even if it failed.
            # Strictly required when doing DSP, like FFTs.
            abort(a,m)
        end
    end

    postprocess(ch, final_buf)

end

function measure(ch::AlazarResponse; diagnostic::Bool=false)
    a = ch.ins
    m = ch.m

    # Calculate and adjust record and buffer sizes.
    buffersizing(a,m)

    # Sets record size if needed.
    # Performs FFT windowing if needed.
    recordsizing(a,m)
    windowing(a,m)

    # Includes fft_setup if applicable
    before_async_read(a,m)

    # Buffers/acquisition is not the same as buffer count, in general.
    # Buffer count determines how many buffers are allocated; a greater numbers
    # of buffers/acquisition may result in reuse of the allocated buffers.
    # In applications where we don't want indefinite acquisition time,
    # we choose *not* to reuse buffers.
    m.buf_count = buffers_per_acquisition(a,m)

    # Initialize some parameters
    buf_size = m.buf_size
    buf_count = m.buf_count
    #println(buf_size," ",buf_count)
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
    sam_per_buf = samples_per_buffer_returned(a,m)

    try
        diagnostic && begin
            println("Capturing $(length(buf_array)) buffers...")
            starttime = time()
        end

        # Arm the board system to wait for a trigger event to begin the acquisition
        startcapture(a)

        for dmaptr in buf_array
            wait_buffer(a, m, dmaptr, timeout_ms)
            # Take care if this ever does something for FFTRecordResponse since
            # sam_per_buf is probably not the relevant number
            processing(ch, sam_per_buf, buf_completed, backing)
            buf_completed += 1
        end

        # Display results
        diagnostic && begin
            transfertime_s = time() - starttime
            println("Capture completed in $transfertime_s s")

            rec_transferred = records_per_buffer(a,m) * buf_count

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

    postprocess(ch, buf_array)
end

processing(::StreamResponse,a,b,c) = tofloat!(a,b,c)
processing(::RecordResponse,a,b,c) = tofloat!(a,b,c)
processing(::FFTResponse,a,b,c) = nothing

function tofloat!(sam_per_buf::Integer, buf_completed::Integer, backing::SharedArray)
    @sync begin
        samplerange = ((1:sam_per_buf) + buf_completed*sam_per_buf)
        for p in procs(backing)
            @async begin
                remotecall_wait(p, Main.worker_tofloat!, backing, samplerange)
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
    sam_per_rec = samples_per_record_returned(ch.ins, ch.m)
    rec_per_acq = records_per_acquisition(ch.ins, ch.m)
    array = reshape(array, sam_per_rec, rec_per_acq)
    convert(SharedArray, array)::SharedArray{T,2}
end

function postprocess{T}(ch::FFTResponse{SharedArray{T,2}}, buf_array::Alazar.DMABufferArray)
    backing = buf_array.backing
    if sizeof(T) == sizeof(eltype(backing))
        array = reinterpret(T, sdata(backing))  # now it has els of type T
        # Get 2D dimensions
    else
        array = convert(T, sdata(backing))
    end
    sam_per_rec = samples_per_record_returned(ch.ins, ch.m)
    rec_per_acq = records_per_acquisition(ch.ins, ch.m)
    array = reshape(array, sam_per_rec, rec_per_acq)
    convert(SharedArray, array)::SharedArray{T,2}
end
