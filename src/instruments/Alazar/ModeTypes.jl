export AlazarMode
export StreamMode, RecordMode
export ContinuousStreamMode, TriggeredStreamMode
export NPTRecordMode, TraditionalRecordMode
export FFTRecordMode

"Abstract type representing a mode of operation for an AlazarTech digitizer."
abstract type AlazarMode end

"""
Abstract type representing any streaming mode of operation for an
AlazarTech digitizer.
"""
abstract type StreamMode <: AlazarMode end

"""
Abstract type representing any record mode of operation for an
AlazarTech digitizer.
"""
abstract type RecordMode <: AlazarMode end

"See the AlazarTech documentation. Need to set `total_samples`."
mutable struct ContinuousStreamMode <: StreamMode
    total_samples::Int

    buf_size::Int
    buf_count::Int

    ContinuousStreamMode(a) = new(a,0,0)
end

"See the AlazarTech documentation. Need to set `total_samples`."
mutable struct TriggeredStreamMode <: StreamMode
    total_samples::Int

    buf_size::Int
    buf_count::Int

    TriggeredStreamMode(a) = new(a,0,0)
end

"""
See the AlazarTech documentation. Need to set samples per record `sam_per_rec`
and total number of records `total_recs`. These must meet certain requirements.
"""
mutable struct NPTRecordMode <: RecordMode
    sam_per_rec::Int
    total_recs::Int

    buf_size::Int
    buf_count::Int

    NPTRecordMode(a,b) = new(a,b,0,0)
end

"""
See the AlazarTech documentation. Need to set pre-trigger samples per record
`pre_sam_per_rec`, post-trigger samples per record `post_sam_per_rec`, and
total number of records `total_recs`. These must meet certain requirements.
"""
mutable struct TraditionalRecordMode <: RecordMode
    pre_sam_per_rec::Int
    post_sam_per_rec::Int
    total_recs::Int

    buf_size::Int
    buf_count::Int

    TraditionalRecordMode(a,b,c) = new(a,b,c,0,0)
end

"""
See the AlazarTech documentation. Need to set samples per record `sam_per_rec`,
samples per FFT `sam_per_fft` (which should be bigger than `sam_per_rec`),
total number of records `total_recs`, and the FFT output type `output_eltype`.
Some parameters must meet certain requirements.
"""
mutable struct FFTRecordMode <: RecordMode
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
