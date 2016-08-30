
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

"""
Should be called at the beginning of a measure method to initialize the
AlazarMode objects.
"""
initmodes

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
Assume two-channel IQ FFT acquisition.
"""
function measure(ch::IQSoftwareResponse; diagnostic::Bool=false)
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

    imix0 = Array{Float32}(2, N)
    imix0[1,:] = cos(2pi*ftbase)
    imix0[2,:] = sin(2pi*ftbase)

    # Multiply by a Hann window function
    hann = Float32[(0.5*(1-cos(2π*i/N))) for i in 1:N]'
    imix0 = broadcast(.*, imix0, hann)::Array{Float32,2}

    qmix0 = Array{Float32}(2, N)
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
    buf_array = bufferarray(a,m)
    backing = buf_array.backing

    # Add the buffers to a list of buffers available to be filled by the board
    for dmaptr in buf_array
        post_async_buffer(a, dmaptr, buf_size)
    end

    backing = buf_array.backing
    sam_per_buf = samples_per_buffer_returned(a,m)
    rec_per_buf = records_per_buffer(a,m)

    # We will need an array to store the 32-bit floats.
    fft_buffer = SharedArray(Float32, sam_per_buf)

    # We also preallocate the output array.
    iqout = Array{Complex{Float32}}(m.total_recs)

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
        a[AuxOutputPacerDivider] = 10

        for dmaptr in buf_array
            wait_buffer(a, m, dmaptr, timeout_ms)
            tofloat!(backing, fft_buffer, sam_per_buf, buf_completed)
            @sync begin
                for p in procs(fft_buffer)
                    @async begin
                        remotecall_wait(p, Main.worker_dotminus!,
                            fft_buffer, mean(fft_buffer))
                    end
                end
            end
            iqfft(fft_buffer, imix, qmix, iqout,
                sam_per_buf, rec_per_buf, buf_completed)

            buf_completed += 1
        end

    finally
        # Gracefully stop the acquisition, even if it failed.
        # Strictly required when doing DSP, like FFTs.
        abort(a,m)
    end
    iqout
end

"""
Arrange multithreaded conversion of the Alazar formats to the usual IEEE
floating-point format.
"""
function tofloat!(backing::SharedArray, fft_buffer::SharedArray,
    sam_per_buf, buf_completed)
    @sync begin
        samplerange = ((1:sam_per_buf) + buf_completed*sam_per_buf)
        for p in procs(backing)
            @async begin
                remotecall_wait(p, Main.worker_tofloat!,
                    backing, samplerange, fft_buffer)
            end
        end
    end
end

"""
Multiply the measurement with imix
"""
function iqfft(fft_buffer::SharedArray, imix, qmix, iqout,
    sam_per_buf, rec_per_buf, buf_completed)

    sam_per_rec = Int(sam_per_buf/rec_per_buf)
    rng = 1:sam_per_rec

    k = rec_per_buf*buf_completed
    for j in 1:rec_per_buf
        k += 1
        I = sum(fft_buffer[rng] .* imix)
        Q = sum(fft_buffer[rng] .* qmix)
        iqout[k] = Complex(I,Q)
        rng += sam_per_rec
    end
end

"""
Arrange for reinterpretation or conversion of the data stored in the
DMABuffers (backed by SharedArrays) to the desired return type.
"""
function postprocess end

function postprocess{T}(ch::AlazarResponse{SharedArray{T,1}}, buf_array::Alazar.DMABufferArray)
    backing = buf_array.backing
    SharedArray{T,1}(sdata(backing))
end

function postprocess{T}(ch::AlazarResponse{SharedArray{T,2}}, buf_array::Alazar.DMABufferArray)
    backing = buf_array.backing
    array = Array{T}(sdata(backing))

    sam_per_rec = samples_per_record_returned(ch.ins, ch.m)
    rec_per_acq = records_per_acquisition(ch.ins, ch.m)
    array = reshape(array, sam_per_rec, rec_per_acq)
    convert(SharedArray, array)::SharedArray{T,2}
end

function postprocess{T<:Union{Float32,Float64}}(
        ch::IQSoftwareResponse, fft_array::SharedArray{T,2})

    data = sdata(fft_array)
    array = reinterpret(Complex{T}, data, (Int(size(data)[1]/2), size(data)[2]))
end

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
