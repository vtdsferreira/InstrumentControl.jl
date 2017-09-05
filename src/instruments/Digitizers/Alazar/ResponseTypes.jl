export ContinuousStreamResponse
export TriggeredStreamResponse
export NPTRecordResponse
export FFTHardwareResponse
export IQSoftwareResponse

"""
    abstract type AlazarResponse{T} <: Response
Abstract `Response` from an Alazar digitizer instrument. Subtypes should implement
`return_type` to specify the output array type if they rely on the generic method
`measure(::AlazarResponse)`.
"""
abstract type AlazarResponse{T} <: Response end

"""
    abstract type StreamResponse{T} <: AlazarResponse{T}
Abstract time-domain streaming `Response` from an Alazar digitizer instrument.
"""
abstract type StreamResponse{T} <: AlazarResponse{T} end

"""
    abstract type RecordResponse{T} <: AlazarResponse{T}
Abstract time-domain record `Response` from an Alazar digitizer instrument.
"""
abstract type RecordResponse{T} <: AlazarResponse{T} end

"""
    abstract type FFTResponse{T} <: AlazarResponse{T}
Abstract FFT `Response` from an Alazar digitizer instrument.
"""
abstract type FFTResponse{T} <: AlazarResponse{T} end

"""
    mutable struct ContinuousStreamResponse{T} <: StreamResponse{T}
Response type implementing the "continuous streaming mode" of the Alazar API.
"""
mutable struct ContinuousStreamResponse{T} <: StreamResponse{T}
    ins::T
    samples_per_ch::Int
    m::ContinuousStreamMode

    function ContinuousStreamResponse{T}(ins, samples_per_ch) where {T}
        @assert samples_per_ch > 0
        return new{T}(ins, samples_per_ch,
            ContinuousStreamMode(samples_per_ch * ins[ChannelCount]))
    end
end
ContinuousStreamResponse(a::InstrumentAlazar, samples_per_ch) =
    ContinuousStreamResponse{typeof(a)}(a, samples_per_ch)
return_type(::ContinuousStreamResponse) = Vector{Float16}

"""
    mutable struct TriggeredStreamResponse{T} <: StreamResponse{T}
Response type implementing the "triggered streaming mode" of the Alazar API.
"""
mutable struct TriggeredStreamResponse{T} <: StreamResponse{T}
    ins::T
    samples_per_ch::Int
    m::TriggeredStreamMode

    function TriggeredStreamResponse{T}(ins, samples_per_ch) where {T}
        @assert samples_per_ch > 0
        return new{T}(ins, samples_per_ch,
            TriggeredStreamMode(samples_per_ch * ins[ChannelCount]))
    end
end
TriggeredStreamResponse(a::InstrumentAlazar, samples_per_ch) =
    TriggeredStreamResponse{typeof(a)}(a, samples_per_ch)
return_type(::TriggeredStreamResponse) = Vector{Float16}

"""
    mutable struct NPTRecordResponse{T} <: RecordResponse{T}
Response type implementing the "NPT record mode" of the Alazar API.
"""
mutable struct NPTRecordResponse{T} <: RecordResponse{T}
    ins::T
    sam_per_rec_per_ch::Int
    total_recs::Int
    m::NPTRecordMode

    function NPTRecordResponse{T}(ins, sam_per_rec_per_ch, total_recs) where {T}
        @assert sam_per_rec_per_ch > 0
        @assert total_recs > 0
        return new{T}(ins, sam_per_rec_per_ch, total_recs,
            NPTRecordMode(sam_per_rec_per_ch * ins[ChannelCount], total_recs))
    end
end
NPTRecordResponse(a::InstrumentAlazar, sam_per_rec_per_ch, total_recs) =
    NPTRecordResponse{typeof(a)}(a, sam_per_rec_per_ch, total_recs)
return_type(::NPTRecordResponse) = Matrix{Float16}

"""
    mutable struct FFTHardwareResponse{T,S} <: FFTResponse{T}
Response type implementing the FPGA-based "FFT record mode" of the Alazar API.
"""
mutable struct FFTHardwareResponse{T,S} <: FFTResponse{T}
    ins::T
    sam_per_rec::Int
    sam_per_fft::Int
    total_recs::Int
    m::FFTRecordMode{S}

    function (FFTHardwareResponse{T,S}(ins, sam_per_rec, sam_per_fft, total_recs)
            where {T,S<:Alazar.AlazarFFTBits})
        @assert sam_per_rec > 0
        @assert sam_per_fft > 0
        @assert ispow2(sam_per_fft)
        @assert total_recs > 0
        return new{T,S}(ins, sam_per_rec, sam_per_fft, total_recs,
            FFTRecordMode{S}(sam_per_rec, sam_per_fft, total_recs))
    end
end
(FFTHardwareResponse(a::InstrumentAlazar, sam_per_rec, sam_per_fft, total_recs, ::Type{S})
    where {S <: Alazar.AlazarFFTBits}) =
        FFTHardwareResponse{typeof(a), S}(a, sam_per_rec, sam_per_fft, total_recs)
return_type(::FFTHardwareResponse{T,S}) where {T,S} = Matrix{S}

"""
    mutable struct IQSoftwareResponse{T} <: RecordResponse{T}
Response type for measuring with NPT record mode, then using Julia's FFTW to
return the FFT. Slower than doing it with the FPGA, but ultimately necessary if
we want to use both channels as inputs to the FFT.
"""
mutable struct IQSoftwareResponse{T} <: RecordResponse{T}
    ins::T
    sam_per_rec_per_ch::Int
    total_recs::Int
    f::Float64
    m::NPTRecordMode

    function IQSoftwareResponse{T}(ins, sam_per_rec_per_ch, total_recs, f) where {T}
        @assert sam_per_rec_per_ch > 0
        @assert total_recs > 0
        return new{T}(ins, sam_per_rec_per_ch, total_recs, f,
            NPTRecordMode(sam_per_rec_per_ch * ins[ChannelCount], total_recs))
    end
end
IQSoftwareResponse(a::InstrumentAlazar, sam_per_rec_per_ch, total_recs, f) =
    IQSoftwareResponse{typeof(a)}(a, sam_per_rec_per_ch, total_recs, f)
