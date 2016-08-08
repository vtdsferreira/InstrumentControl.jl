
function initmodes(r::StreamResponse)
    r.m.total_samples = r.samples_per_ch * (r.ins)[ChannelCount]
end

function initmodes(r::FFTResponse)
    r.m.sam_per_rec = r.sam_per_rec
    r.m.sam_per_fft = r.sam_per_fft
    r.m.total_recs = r.total_recs
    r.m.output_eltype = r.output_eltype
end

function initmodes(r::RecordResponse)
    r.m.sam_per_rec = r.sam_per_rec_per_ch * (r.ins)[ChannelCount]
    r.m.total_recs = r.total_recs
end

function initmodes(r::AlternatingRealImagResponse)
    error("not yet implemented")
end

"""
Should be called at the beginning of a measure method to initialize the
AlazarMode objects.
"""
initmodes

function measure(ch::AlternatingRealImagResponse; diagnostic::Bool=false)
    a = ch.ins
    m = ch.m
    mIm = ch.mIm

    # Calculate and adjust record and buffer sizes.
    initmodes(ch)
    buffersizing(a,m)
    buffersizing(a,mIm)
    m.buf_count = 1
    mIm.buf_count = 1

    windowing(a,m)

    timeout_ms = 5000
    buf_completed = 0
    by_transferred = 0
    transfertime_s = 0

    re_buf = bufferarray(a,m)
    im_buf = bufferarray(a,mIm)

    # Assumes both are 32-bit integers
    final_buf = Alazar.DMABufferArray{Int32}(
                    4 * ch.total_recs * ch.sam_per_fft * 2, 1)

    # We are going to alternate between real and imaginary FFTs
    buf_iter = cycle((re_buf, im_buf))
    bis = start(buf_iter)

    mode_iter = cycle((m, mIm))
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

"Largely generic method for measuring `AlazarResponse`. Can be considered a
prototype for more complicated user-defined methods."
function measure(ch::AlazarResponse; diagnostic::Bool=false)
    a = ch.ins
    m = ch.m

    # Calculate and adjust record and buffer sizes.
    initmodes(ch)
    buffersizing(a,m)

    # Sets record size if needed.
    recordsizing(a,m)

    # If necessary do any FFT-on-FPGA setup and proceed to preparing for a read.
    fft_fpga_setup(a,m)
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

"""
Assume two-channel IQ FFT acquisition.
"""
function measure(ch::IQSoftwareResponse; diagnostic::Bool=false)
    a = ch.ins
    m = ch.m

    configure(a, BothChannels)

    # Initial prep
    initmodes(ch)
    buffersizing(a,m)
    recordsizing(a,m)
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

    timeout_ms = 5000
    buf_completed = 0

    # Allocate memory for DMA buffers.
    buf_array = bufferarray(a,m)
    backing = buf_array.backing

    # We will need an array to store the complex 32-bit floats.
    # / 2 comes from 2 channels.
    fft_array = SharedArray(Float32, (m.sam_per_rec, m.total_recs))

    # Add the buffers to a list of buffers available to be filled by the board
    for dmaptr in buf_array
        post_async_buffer(a, dmaptr, buf_size)
    end

    backing = buf_array.backing
    sam_per_buf = samples_per_buffer_returned(a,m)
    rec_per_buf = records_per_buffer(a,m)

    try

        # Arm the board system to wait for a trigger event to begin the acquisition
        startcapture(a)

        for dmaptr in buf_array
            wait_buffer(a, m, dmaptr, timeout_ms)
            processing(ch, sam_per_buf, buf_completed,
                rec_per_buf, backing, fft_array)

            buf_completed += 1
        end

    finally
        # Gracefully stop the acquisition, even if it failed.
        # Strictly required when doing DSP, like FFTs.
        abort(a,m)
    end

    postprocess(ch, fft_array)
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

# function postprocess{T}(ch::FFTResponse{SharedArray{T,2}}, buf_array::Alazar.DMABufferArray)
#     backing = buf_array.backing
#     if sizeof(T) == sizeof(eltype(backing))
#         array = reinterpret(T, sdata(backing))  # now it has els of type T
#         # Get 2D dimensions
#     else
#         array = convert(T, sdata(backing))
#     end
#     sam_per_rec = samples_per_record_returned(ch.ins, ch.m)
#     rec_per_acq = records_per_acquisition(ch.ins, ch.m)
#     array = reshape(array, sam_per_rec, rec_per_acq)
#     convert(SharedArray, array)::SharedArray{T,2}
# end

function postprocess{T<:Union{Float32,Float64}}(
        ch::IQSoftwareResponse, fft_array::SharedArray{T,2})

    data = sdata(fft_array)
    array = reinterpret(Complex{T}, data, (Int(size(data)[1]/2), size(data)[2]))

end

"""
Arrange for reinterpretation or conversion of the data stored in the
DMABuffers (backed by SharedArrays) to the desired return type.
"""
postprocess

processing(::StreamResponse,args...) = tofloat!(args...)
processing(::RecordResponse,args...) = tofloat!(args...)
processing(::FFTResponse,args...) = nothing
processing(::IQSoftwareResponse,args...) = iqfft(args...)

"""
Specifies what to do with the buffers during measurement based on the response type.
"""
processing

# Triangular dispatch would be nice here (waiting for Julia 0.6)
# scaling{T, S<:AbstractArray{T,2}}(resp::FFTRecordResponse{S}, ...

"Returns the axis scaling for an FFT response."
function scaling{T<:AbstractArray}(resp::FFTResponse{T},
        whichaxis::Integer=1)

    rate = (resp.ins)[SampleRate]
    npts = resp.m.sam_per_fft # single-sided
    dims = T.parameters[2]::Int
    if (dims == 1)
        @assert whichaxis == 1
        return repeat(collect(0:rate/npts:(rate/2-rate/npts)),
                      outer=[resp.m.total_recs])
    elseif (dims == 2)
        @assert 1<=whichaxis<=2
        if (whichaxis == 1)
            return collect(0:rate/npts:(rate/2-rate/npts))
        else
            return collect(1:resp.m.total_recs)
        end
    end

end

"""
Arrange multithreaded conversion of the Alazar 12-bit integer format to 16-bit
floating point format.
"""
function tofloat!(sam_per_buf::Int, buf_completed::Int, backing::SharedArray)
    @sync begin
        samplerange = ((1:sam_per_buf) + buf_completed*sam_per_buf)
        for p in procs(backing)
            @async begin
                remotecall_wait(p, Main.worker_tofloat!, backing, samplerange)
            end
        end
    end
end

"""
Convert and copy
"""
function iqfft(sam_per_buf::Int, buf_completed::Int, rec_per_buf::Int,
    backing::SharedArray, fft_array::SharedArray)

    @sync begin
        samplerange = ((1:sam_per_buf) + buf_completed*sam_per_buf)
        for p in procs(backing)
            @async begin
                remotecall_wait(p, Main.worker_iqfft, backing, samplerange, fft_array)
            end
        end
    end
end
