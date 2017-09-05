export AlazarMode
export StreamMode, RecordMode
export ContinuousStreamMode, TriggeredStreamMode
export NPTRecordMode, TraditionalRecordMode
export FFTRecordMode

"""
    abstract type AlazarMode
Abstract type representing a mode of operation for an AlazarTech digitizer.
"""
abstract type AlazarMode end

"""
    abstract type StreamMode <: AlazarMode
Abstract type representing any streaming mode of operation for an AlazarTech digitizer.
"""
abstract type StreamMode <: AlazarMode end

"""
    abstract type RecordMode <: AlazarMode
Abstract type representing any record mode of operation for an AlazarTech digitizer.
"""
abstract type RecordMode <: AlazarMode end

"""
    mutable struct TriggeredStreamMode <: StreamMode
See the AlazarTech documentation. Need to set `total_samples`.
"""
mutable struct ContinuousStreamMode <: StreamMode
    total_samples::Int

    buf_size::Int
    buf_count::Int

    ContinuousStreamMode(total_samples) = new(total_samples, 0, 0)
end

"""
    mutable struct TriggeredStreamMode <: StreamMode
See the AlazarTech documentation. Need to set `total_samples`.
"""
mutable struct TriggeredStreamMode <: StreamMode
    total_samples::Int

    buf_size::Int
    buf_count::Int

    TriggeredStreamMode(total_samples) = new(total_samples, 0, 0)
end

"""
    mutable struct NPTRecordMode <: RecordMode
See the AlazarTech documentation. Need to set samples per record `sam_per_rec` and total
number of records `total_recs`. These must meet certain requirements.
"""
mutable struct NPTRecordMode <: RecordMode
    sam_per_rec::Int
    total_recs::Int

    buf_size::Int
    buf_count::Int

    NPTRecordMode(sam_per_rec, total_recs) = new(sam_per_rec, total_recs, 0, 0)
end

"""
    mutable struct TraditionalRecordMode <: RecordMode
See the AlazarTech documentation. Need to set pre-trigger samples per record
`pre_sam_per_rec`, post-trigger samples per record `post_sam_per_rec`, and total number of
records `total_recs`. These must meet certain requirements.
"""
mutable struct TraditionalRecordMode <: RecordMode
    pre_sam_per_rec::Int
    post_sam_per_rec::Int
    total_recs::Int

    buf_size::Int
    buf_count::Int

    TraditionalRecordMode(pre_sam_per_rec, post_sam_per_rec, total_recs) =
        new(pre_sam_per_rec, post_sam_per_rec, total_recs, 0, 0)
end

"""
    mutable struct FFTRecordMode{T} <: RecordMode
See the AlazarTech documentation. Need to set samples per record `sam_per_rec`, samples per
FFT `sam_per_fft` (which should be bigger than `sam_per_rec`), and total number of records
`total_recs`. The FFT output type is `T`. Some parameters must meet certain requirements.
"""
mutable struct FFTRecordMode{T} <: RecordMode
    sam_per_rec::Int
    sam_per_fft::Int
    total_recs::Int

    re_window::Vector{Cfloat}
    im_window::Vector{Cfloat}
    by_rec::U32
    buf_size::Int
    buf_count::Int

    FFTRecordMode{T}(sam_per_rec, sam_per_fft, total_recs) where {T} =
        new{T}(sam_per_rec, sam_per_fft, total_recs,
            Array(Cfloat, 0), Array(Cfloat, 0), 0, 0, 0)
end
