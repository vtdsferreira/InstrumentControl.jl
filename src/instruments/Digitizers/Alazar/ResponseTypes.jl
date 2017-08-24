export ContinuousStreamResponse
export TriggeredStreamResponse
export NPTRecordResponse
export FFTHardwareResponse
export IQSoftwareResponse

"Abstract `Response` from an Alazar digitizer instrument."
abstract type AlazarResponse{T} <: Response end

"Abstract time-domain streaming `Response` from an Alazar digitizer instrument."
abstract type StreamResponse{T} <: AlazarResponse{T} end

"Abstract time-domain record `Response` from an Alazar digitizer instrument."
abstract type RecordResponse{T} <: AlazarResponse{T} end

"Abstract FFT `Response` from an Alazar digitizer instrument."
abstract type FFTResponse{T}    <: AlazarResponse{T} end

"""
Response type implementing the "continuous streaming mode" of the Alazar API.
"""
mutable struct ContinuousStreamResponse{T} <: StreamResponse{T}
    ins::InstrumentAlazar
    samples_per_ch::Int

    m::AlazarMode

    (::Type{ContinuousStreamResponse{T}}){T}(a,b) = begin
        b <= 0 && error("Need at least one sample.")
        r = new{T}(a,b)
        r.m = ContinuousStreamMode(r.samples_per_ch *
                                   r.ins[ChannelCount])
        r
    end
end
ContinuousStreamResponse(a::InstrumentAlazar, samples_per_ch) =
    ContinuousStreamResponse{SharedArray{Float16,1}}(a, samples_per_ch)

"""
Response type implementing the "triggered streaming mode" of the Alazar API.
"""
mutable struct TriggeredStreamResponse{T} <: StreamResponse{T}
    ins::InstrumentAlazar
    samples_per_ch::Int

    m::AlazarMode

    (::Type{TriggeredStreamResponse{T}}){T}(a,b) = begin
        b <= 0 && error("Need at least one sample.")
        r = new{T}(a,b)
        r.m = TriggeredStreamMode(r.samples_per_ch *
                                  r.ins[ChannelCount])
        r
    end
end
TriggeredStreamResponse(a::InstrumentAlazar, samples_per_ch) =
    TriggeredStreamResponse{SharedArray{Float16,1}}(a, samples_per_ch)

"""
Response type implementing the "NPT record mode" of the Alazar API.
"""
mutable struct NPTRecordResponse{T} <: RecordResponse{T}
    ins::InstrumentAlazar
    sam_per_rec_per_ch::Int
    total_recs::Int

    m::AlazarMode

    (::Type{NPTRecordResponse{T}}){T}(a,b,c) = begin
        b <= 0 && error("Need at least one sample.")
        c <= 0 && error("Need at least one record.")
        r = new{T}(a,b,c)
        r.m = NPTRecordMode(r.sam_per_rec_per_ch * r.ins[ChannelCount],
                            r.total_recs)
        r
    end
end
NPTRecordResponse(a::InstrumentAlazar, sam_per_rec_per_ch, total_recs) =
    NPTRecordResponse{SharedArray{Float16,2}}(a, sam_per_rec_per_ch, total_recs)

"""
Response type implementing the FPGA-based "FFT record mode" of the Alazar API.
"""
mutable struct FFTHardwareResponse{T} <: FFTResponse{T}
    ins::InstrumentAlazar
    sam_per_rec::Int
    sam_per_fft::Int
    total_recs::Int
    output_eltype::DataType

    m::AlazarMode

    (::Type{FFTHardwareResponse{T}}){T,S<:Alazar.AlazarFFTBits}(a,b,c,d,e::Type{S}) = begin
        b <= 0 && error("Need at least one sample.")
        c == 0 && error("FFT length (samples) too short.")
        !ispow2(c) && error("FFT length (samples) not a power of 2.")
        d <= 0 && error("Need at least one record.")
        !(e <: Alazar.AlazarFFTBits) && error("Takes an AlazarFFTBits type.")
        r = new{T}(a,b,c,d,e)
        r.m = FFTRecordMode(r.sam_per_rec, r.sam_per_fft,
                            r.total_recs, r.output_eltype)
        r
    end
end
FFTHardwareResponse(a,b,c,d,e::Type{S}) where {S <: Alazar.AlazarFFTBits} =
    FFTHardwareResponse{SharedArray{S,2}}(a,b,c,d,e)

"""
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

    (::Type{IQSoftwareResponse{T}}){T}(a,b,c,d) = begin
        b <= 0 && error("Need at least one sample.")
        c <= 0 && error("Need at least one record.")
        r = new{T}(a,b,c,d)
        r.m = NPTRecordMode(r.sam_per_rec_per_ch * (r.ins)[ChannelCount],
                            r.total_recs)
        r
    end
end
IQSoftwareResponse(a::InstrumentAlazar, sam_per_rec_per_ch, total_recs, f) =
    IQSoftwareResponse{SharedArray{Float32,2}}(a, sam_per_rec_per_ch, total_recs, f)
