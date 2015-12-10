export inspect_per

## Buffers #########

inspect(a::InstrumentAlazar, ::Type{BufferCount}) = a.bufferCount

## Channels ########

inspect(a::InstrumentAlazar, ::Type{AlazarChannel}) =
    AlazarChannel(a,a.acquisitionChannel)

inspect(a::InstrumentAlazar, ::Type{ChannelCount}) = a.channelCount

## Data packing #####

function inspect{T<:AlazarChannel}(a::InstrumentAlazar,
        ::Type{AlazarDataPacking}, ch::Type{T})
    ch == AlazarChannel && error("Specify a particular channel.")

    arr = Array{Clong}(1)
    arr[1] = 0

    r = @eh2 AlazarGetParameter(a.handle, code(ch(a)), Alazar.PACK_MODE, arr)
    AlazarDataPacking(a,arr[1])
end

function inspect(a::InstrumentAlazar, ::Type{SampleRate})
    a.sampleRate > 0x80 ? float(a.sampleRate) :
        float(samplerate(typeof(SampleRate(a,a.sampleRate))))
end

function inspect(a::InstrumentAlazar, ::Type{SampleMemoryPerChannel})
    memorysize_samples = Array{U32}(1)
    memorysize_samples[1] = U32(0)

    bitspersample = Array{U8}(1)
    bitspersample[1] = U8(0)

    @eh2 AlazarGetChannelInfo(a.handle, memorysize_samples, bitspersample)

    return memorysize_samples[1]
end

function inspect_per{S<:PerProperty, T<:PerProperty}(
        a::InstrumentAlazar, ::Type{S}, ::Type{T})
    error("inspect_per not implemented for this pair.")
end

function inspect_per{S<:PerProperty, T<:PerProperty}(
        a::InstrumentAlazar, mode::AlazarMode, ::Type{S}, ::Type{T})
    error("inspect_per not implemented for this pair.")
end

inspect_per(a::InstrumentAlazar, ::Type{Bit}, ::Type{Sample}) = begin
    memorysize_samples = Array{U32}(1)
    memorysize_samples[1] = U32(0)

    bitspersample = Array{U8}(1)
    bitspersample[1] = U8(0)

    @eh2 AlazarGetChannelInfo(a.handle, memorysize_samples, bitspersample)

    return bitspersample[1]
end

inspect_per(a::InstrumentAlazar, ::Type{Byte}, ::Type{Sample}) =
    Int(cld(inspect_per(a, Bit, Sample), 8))

inspect_per(a::InstrumentAlazar, ::Type{Sample}, ::Type{Byte}) =
    float(1.0 / inspect_per(a, Byte, Sample))

inspect(a::InstrumentAlazar, ::Type{BufferSize})  = a.bufferSize

# Since records/buffer is always 1 in stream mode, we fix samples/record:
inspect_per(a::InstrumentAlazar, m::StreamMode,
        ::Type{Sample}, ::Type{Record}) =
    Int(inspect(a, BufferSize) / (inspect_per(a, Byte, Sample)))

# For record mode, the number of samples per record must be specified.
inspect_per(a::InstrumentAlazar, m::RecordMode, ::Type{Sample}, ::Type{Record}) =
    m.sam_per_rec

inspect_per(a::InstrumentAlazar, m::TraditionalRecordMode,
    ::Type{Sample}, ::Type{Record}) = m.pre_sam_per_rec + m.post_sam_per_rec

# For any Alazar digitizer in stream mode, records per buffer should be 1.
inspect_per(a::InstrumentAlazar, m::StreamMode,
    ::Type{Record}, ::Type{Buffer}) = 1

# For record mode, the number of records per buffer is fixed based on the
# desired buffer size and samples per record.
inspect_per(a::InstrumentAlazar, m::RecordMode, ::Type{Record}, ::Type{Buffer}) =
    Int(fld(inspect(a, BufferSize),
        inspect_per(a, m, Sample, Record) * inspect_per(a, Byte, Sample)))

# Pretty straightforward...
inspect_per(a::InstrumentAlazar, m::AlazarMode, ::Type{Sample}, ::Type{Buffer}) =
    inspect_per(a, m, Sample, Record) * inspect_per(a, m, Record, Buffer)

# Parameter is ignored in stream mode for any Alazar digitizer.
inspect_per(::StreamMode, ::Type{Record}, ::Type{Acquisition}) = inf_records
inspect_per(a::InstrumentAlazar, m::StreamMode,
    ::Type{Record}, ::Type{Acquisition}) = inspect_per(m, Record, Acquisition)

# Pass 0x7FFFFFFF for indefinite acquisition count.
inspect_per(m::RecordMode, ::Type{Record}, ::Type{Acquisition}) = m.total_recs
inspect_per(a::InstrumentAlazar, m::RecordMode,
    ::Type{Record}, ::Type{Acquisition}) = inspect_per(m, Record, Acquisition)

inspect_per(a::InstrumentAlazar, m::StreamMode, ::Type{Buffer}, ::Type{Acquisition}) =
    Int(cld(m.total_samples, inspect_per(a, m, Sample, Buffer)))
    # Int(cld(m.total_acq_time_s * inspect(a, SampleRate),
    #     inspect_per(a, m, Sample, Buffer)))

inspect_per(a::InstrumentAlazar, m::RecordMode, ::Type{Buffer}, ::Type{Acquisition}) =
    Int(cld(m.total_recs, inspect_per(a, m, Record, Buffer)))
