export AlazarMode
export StreamMode, RecordMode
export ContinuousStreamMode, TriggeredStreamMode
export NPTRecordMode, TraditionalRecordMode
export FFTRecordMode

abstract AlazarMode
abstract StreamMode <: AlazarMode
abstract RecordMode <: AlazarMode

type ContinuousStreamMode <: StreamMode
    total_samples::Int

    buf_size::Int
    buf_count::Int

    ContinuousStreamMode(a) = new(a,0,0)
end

type TriggeredStreamMode <: StreamMode
    total_samples::Int

    buf_size::Int
    buf_count::Int

    TriggeredStreamMode(a) = new(a,0,0)
end

type NPTRecordMode <: RecordMode
    sam_per_rec::Int
    total_recs::Int

    buf_size::Int
    buf_count::Int

    NPTRecordMode(a,b) = new(a,b,0,0)
end

type TraditionalRecordMode <: RecordMode
    pre_sam_per_rec::Int
    post_sam_per_rec::Int
    total_recs::Int

    buf_size::Int
    buf_count::Int

    TraditionalRecordMode(a,b,c) = new(a,b,c,0,0)
end

type FFTRecordMode <: RecordMode
    sam_per_rec::Int
    sam_per_fft::Int
    total_recs::Int
    output_eltype::DataType

    re_window::Array{Cfloat}
    im_window::Array{Cfloat}
    by_rec::U32
    buf_size::Int
    buf_count::Int

    FFTRecordMode(a,b,c,d) =
        new(a,b,c,d,Array(Cfloat,0),Array(Cfloat,0),0,0,0)
end
