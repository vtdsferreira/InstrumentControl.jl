export ContinuousStreamResponse
export TriggeredStreamResponse
export NPTRecordResponse
export FFTHardwareResponse
export IQSoftwareResponse

"""
    abstract type AlazarResponse{T} <: Response
Abstract `Response` from an Alazar digitizer instrument.
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
    ins::InstrumentAlazar
    samples_per_ch::Int
    m::AlazarMode

    function ContinuousStreamResponse{T}(ins,samples_per_ch) where {T}
        @assert samples_per_ch > 0
        return new{T}(ins, samples_per_ch,
            ContinuousStreamMode(samples_per_ch * ins[ChannelCount]))
    end
end
ContinuousStreamResponse(a::InstrumentAlazar, samples_per_ch) =
    ContinuousStreamResponse{SharedArray{Float16,1}}(a, samples_per_ch)

"""
    mutable struct TriggeredStreamResponse{T} <: StreamResponse{T}
Response type implementing the "triggered streaming mode" of the Alazar API.
"""
mutable struct TriggeredStreamResponse{T} <: StreamResponse{T}
    ins::InstrumentAlazar
    samples_per_ch::Int
    m::AlazarMode

    function TriggeredStreamResponse{T}(ins, samples_per_ch) where {T}
        @assert samples_per_ch > 0
        return new{T}(ins, samples_per_ch,
            TriggeredStreamMode(samples_per_ch * ins[ChannelCount]))
    end
end
TriggeredStreamResponse(a::InstrumentAlazar, samples_per_ch) =
    TriggeredStreamResponse{SharedArray{Float16,1}}(a, samples_per_ch)

"""
    mutable struct NPTRecordResponse{T} <: RecordResponse{T}
Response type implementing the "NPT record mode" of the Alazar API.
"""
mutable struct NPTRecordResponse{T} <: RecordResponse{T}
    ins::InstrumentAlazar
    sam_per_rec_per_ch::Int
    total_recs::Int
    m::AlazarMode

    function NPTRecordResponse{T}(ins, sam_per_rec_per_ch, total_recs) where {T}
        @assert sam_per_rec_per_ch > 0
        @assert total_recs > 0
        return new{T}(ins, sam_per_rec_per_ch, total_recs,
            NPTRecordMode(sam_per_rec_per_ch * ins[ChannelCount], total_recs))
    end
end
NPTRecordResponse(a::InstrumentAlazar, sam_per_rec_per_ch, total_recs) =
    NPTRecordResponse{SharedArray{Float16,2}}(a, sam_per_rec_per_ch, total_recs)

"""
    mutable struct FFTHardwareResponse{T} <: FFTResponse{T}
Response type implementing the FPGA-based "FFT record mode" of the Alazar API.
"""
mutable struct FFTHardwareResponse{T} <: FFTResponse{T}
    ins::InstrumentAlazar
    sam_per_rec::Int
    sam_per_fft::Int
    total_recs::Int
    output_eltype::DataType
    m::AlazarMode

    function (FFTHardwareResponse{T}(ins, sam_per_rec, sam_per_fft, total_recs, ::Type{S})
            where {T,S<:Alazar.AlazarFFTBits})
        @assert sam_per_rec > 0
        @assert sam_per_fft > 0
        @assert ispow2(sam_per_fft)
        @assert total_recs > 0
        return new{T}(ins, sam_per_rec, sam_per_fft, total_recs, S,
            FFTRecordMode(sam_per_rec, sam_per_fft, total_recs, S))
    end
end
FFTHardwareResponse(a,b,c,d,e::Type{S}) where {S <: Alazar.AlazarFFTBits} =
    FFTHardwareResponse{SharedArray{S,2}}(a,b,c,d,e)

"""
    mutable struct IQSoftwareResponse{T} <: RecordResponse{T}
Response type for measuring with NPT record mode, then using Julia's FFTW to
return the FFT. Slower than doing it with the FPGA, but ultimately necessary if
we want to use both channels as inputs to the FFT.
"""
mutable struct IQSoftwareResponse{T} <: RecordResponse{T}
    ins::InstrumentAlazar
    sam_per_rec_per_ch::Int
    total_recs::Int
    f::Float64
    m::AlazarMode

    function IQSoftwareResponse{T}(ins, sam_per_rec_per_ch, total_recs, f) where {T}
        @assert sam_per_rec_per_ch > 0
        @assert total_recs > 0
        return new{T}(ins, sam_per_rec_per_ch, total_recs, f,
            NPTRecordMode(sam_per_rec_per_ch * ins[ChannelCount], total_recs))
    end
end
IQSoftwareResponse(a::InstrumentAlazar, sam_per_rec_per_ch, total_recs, f) =
    IQSoftwareResponse{SharedArray{Float32,2}}(a, sam_per_rec_per_ch, total_recs, f)
