"""
    bufferarray(ch::AlazarResponse{S,T}) where {S,T}
Given an `AlazarResponse`, returns a `DMABufferVector` with the correct number of buffers
and buffer sizes. `buffersizing` should have been called before this function.
"""
function bufferarray end

bufferarray(ch::AlazarResponse{S,8}) where {S} =
    return DMABufferVector(PageAlignedVector{Alazar8Bit}, ch.m.buf_size, ch.m.buf_count)
bufferarray(ch::AlazarResponse{S,12}) where {S} =
    return DMABufferVector(PageAlignedVector{Alazar12Bit}, ch.m.buf_size, ch.m.buf_count)
bufferarray(ch::AlazarResponse{S,16}) where {S} =
    return DMABufferVector(PageAlignedVector{Alazar16Bit}, ch.m.buf_size, ch.m.buf_count)
bufferarray(a::FFTHardwareResponse{S,T,U}) where {S,T,U} =
    return DMABufferVector(PageAlignedVector{U}, ch.m.buf_size, ch.m.buf_count)

"""
    initmodes(r::AlazarResponse)
Should be called at the beginning of a measure method to do initial checks and initialize
the AlazarMode objects.
"""
function initmodes(r::AlazarResponse)
    declared_bits(r) != bits_per_sample(r.ins) &&
        error("bits/sample does not match digitizer. ",
              "To fix, make a new AlazarResponse object.")
    _initmodes(r)
end

function _initmodes(r::StreamResponse)
    r.m.total_samples = r.samples_per_ch * (r.ins)[ChannelCount]
end

function _initmodes(r::FFTResponse)
    r.m.sam_per_rec = r.sam_per_rec
    r.m.sam_per_fft = r.sam_per_fft
    r.m.total_recs = r.total_recs
end

function _initmodes(r::RecordResponse)
    r.m.sam_per_rec = r.sam_per_rec_per_ch * (r.ins)[ChannelCount]
    r.m.total_recs = r.total_recs
end

"""
    measure(ch::AlazarResponse, diagnostic::Bool=false)
Largely generic method for measuring `AlazarResponse`. Can be considered a
prototype for more complicated user-defined methods.
"""
function measure(ch::AlazarResponse, diagnostic::Bool=false)
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
    m.buf_count = buffers_per_acquisition(a,m)

    # Initialize some parameters
    buf_size = m.buf_size
    buf_count = m.buf_count
    #println(buf_size," ",buf_count)
    timeout_ms = a[BufferTimeout]
    buf_completed = 0
    by_transferred = 0
    transfertime_s = 0

    # Allocate memory for DMA buffers
    buf_array = bufferarray(ch)

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
            # processing(ch, sam_per_buf, buf_completed, backing)
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
    measure(ch::IQSoftwareResponse, diagnostic::Bool=false)
Assume two-channel IQ FFT acquisition.
"""
function measure(ch::IQSoftwareResponse, diagnostic::Bool=false)
    a = ch.ins
    m = ch.m

    # Initial preparations.
    # This is for sure a two channel measurement; let's make it so.
    a[AcquisitionChannel] = :BothChannels

    initmodes(ch)
    buffersizing(a,m)
    recordsizing(a,m)
    before_async_read(a,m)

    # Generate the cosine and sine waves
    N = Int(m.sam_per_rec/2)
    tstep = 1/a[SampleRate]
    ftbase = ch.f*linspace(0., tstep*(N-1), N)

    imix0 = Matrix{Float32}(2, N)
    imix0[1,:] .= cos.(2pi*ftbase)
    imix0[2,:] .= sin.(2pi*ftbase)

    # Multiply by a Hann window function
    hann = Float32[(0.5*(1-cos(2π*i/N))) for i in 1:N]'
    imix0 = (imix0.*hann)::Matrix{Float32}

    qmix0 = Matrix{Float32}(2, N)
    qmix0[1,:] = imix0[2,:] .* -1
    qmix0[2,:] = imix0[1,:]

    # `imix` and `qmix` are now interleaved with cos,sin and -sin,cos, respectively.
    # These will be multiplied with the digitizer records to get I and Q.
    imix = reshape(imix0, (2N,))
    qmix = reshape(qmix0, (2N,))

    # Buffers/acquisition is not the same as buffer count, in general.
    # Buffer count determines how many buffers are allocated; a greater numbers
    # of buffers/acquisition may result in reuse of the allocated buffers.
    # In applications where we don't want indefinite acquisition time,
    # we choose *not* to reuse buffers.
    m.buf_count = buffers_per_acquisition(a,m)

    # Initialize some parameters
    buf_size = m.buf_size
    buf_count = m.buf_count

    timeout_ms = a[BufferTimeout]
    buf_completed = 0

    # Allocate memory for DMA buffers.
    buf_array = bufferarray(ch)

    # Add the buffers to a list of buffers available to be filled by the board
    for dmaptr in buf_array
        post_async_buffer(a, dmaptr, buf_size)
    end

    backing = buf_array.backing
    sam_per_buf = samples_per_buffer_returned(a,m)
    rec_per_buf = records_per_buffer(a,m)

    # We will need an array to store the 32-bit floats.
    fft_buffer = Vector{Float32}(sam_per_buf)

    # We also preallocate the output array.
    iqout = Vector{Complex{Float32}}(m.total_recs)

    try
        # FIRST turn off output to AUX I/O
        a[AuxIOMode] = :AuxDigitalOutput
        a[AuxOutputTTL] = :Low
        sleep(0.01)  # wait for any sequence to finish

        # NEXT arm the board to measure when receiving a trigger input
        startcapture(a)

        # THEN turn on the output pacer, which repeatedly triggers the AWG
        # This ensures the first trigger to the digitizer is the first trigger
        # sent by the AWG.
        a[AuxIOMode] = :AuxOutputPacer

        for dmaptr in buf_array
            wait_buffer(a, m, dmaptr, timeout_ms)
            prep_fft_buffer!(fft_buffer, backing)
            iqfft(fft_buffer, imix, qmix, iqout, sam_per_buf, rec_per_buf, buf_completed)

            buf_completed += 1
        end

    finally
        # Gracefully stop the acquisition, even if it failed.
        # Strictly required when doing DSP, like FFTs.
        abort(a,m)
    end
    iqout::Vector{Complex{Float32}}
end

"""
Arrange conversion of the Alazar formats to the usual IEEE floating-point format.
"""
function prep_fft_buffer!(fft_buffer::AbstractVector{T},
        backing::AbstractVector{<:AlazarBits}) where {T<:AbstractFloat}
    fft_buffer .= convert.(T, backing)
    fft_buffer .-= mean(fft_buffer)
    return nothing
end

"""
Multiply the measurement with iqfft
"""
function iqfft(fft_buffer, imix, qmix, iqout, sam_per_buf, rec_per_buf, buf_completed)
    sam_per_rec = div(sam_per_buf, rec_per_buf)
    rng = 1:sam_per_rec
    k = rec_per_buf * buf_completed
    for j in 1:rec_per_buf
        k += 1
        I = sum(i .* imix for i in @view fft_buffer[rng])
        Q = sum(q .* qmix for q in @view fft_buffer[rng])
        iqout[k] = Complex(I,Q)
        rng += sam_per_rec
    end
end

"""
    postprocess(ch::AlazarResponse, bufs::Alazar.DMABufferVector)
Arrange for reinterpretation or conversion of the data stored in a `DMABufferVector`
to the desired return type.
"""
function postprocess(ch::AlazarResponse, bufs::Alazar.DMABufferVector)
    _postprocess(return_type(ch), ch, bufs)
end

function _postprocess(T::Type{<:AbstractVector}, ch, bufs)
    T(bufs.backing)
end

function _postprocess(T::Type{<:AbstractMatrix}, ch, bufs)
    sam_per_rec = samples_per_record_returned(ch.ins, ch.m)
    rec_per_acq = records_per_acquisition(ch.ins, ch.m)
    convert(T, reshape(bufs.backing, sam_per_rec, rec_per_acq))
end

"""
    scaling(resp::FFTResponse, whichaxis::Integer = 1)
Returns the axis scaling for an FFT response.
"""
function scaling(resp::FFTResponse, whichaxis::Integer = 1)
    rate = (resp.ins)[SampleRate]
    npts = resp.m.sam_per_fft # single-sided

    @assert 1 <= whichaxis <= 2
    if whichaxis == 1
        return collect(0:rate/npts:(rate/2-rate/npts))
    else
        return collect(1:resp.m.total_recs)
    end
end
