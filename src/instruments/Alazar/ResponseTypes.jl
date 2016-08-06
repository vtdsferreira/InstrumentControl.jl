export ContinuousStreamResponse
export TriggeredStreamResponse
export NPTRecordResponse
export FFTHardwareResponse
export IQSoftwareResponse
export AlternatingRealImagResponse

export measure
import InstrumentControl.scaling

"Abstract `Response` from an Alazar digitizer instrument."
abstract AlazarResponse{T} <: Response

"Abstract time-domain streaming `Response` from an Alazar digitizer instrument."
abstract StreamResponse{T} <: AlazarResponse{T}

"Abstract time-domain record `Response` from an Alazar digitizer instrument."
abstract RecordResponse{T} <: AlazarResponse{T}

"Abstract FFT `Response` from an Alazar digitizer instrument."
abstract FFTResponse{T}    <: AlazarResponse{T}

"""
Response type implementing the "continuous streaming mode" of the Alazar API.
"""
type ContinuousStreamResponse{T} <: StreamResponse
    ins::InstrumentAlazar
    samples_per_ch::Int

    m::AlazarMode

    ContinuousStreamResponse(a,b) = begin
        b <= 0 && error("Need at least one sample.")
        r = new(a,b)
        r.m = ContinuousStreamMode(r.samples_per_ch *
                                   inspect(r.ins, ChannelCount))
        r
    end
end
ContinuousStreamResponse(a::InstrumentAlazar, samples_per_ch) =
    ContinuousStreamResponse{SharedArray{Float16,1}}(a, samples_per_ch)

"""
Response type implementing the "triggered streaming mode" of the Alazar API.
"""
type TriggeredStreamResponse{T} <: StreamResponse{T}
    ins::InstrumentAlazar
    samples_per_ch::Int

    m::AlazarMode

    TriggeredStreamResponse(a,b) = begin
        b <= 0 && error("Need at least one sample.")
        r = new(a,b)
        r.m = TriggeredStreamMode(r.samples_per_ch *
                                  inspect(r.ins, ChannelCount))
        r
    end
end
TriggeredStreamResponse(a::InstrumentAlazar, samples_per_ch) =
    TriggeredStreamResponse{SharedArray{Float16,1}}(a, samples_per_ch)

"""
Response type implementing the "NPT record mode" of the Alazar API.
"""
type NPTRecordResponse{T} <: RecordResponse{T}
    ins::InstrumentAlazar
    sam_per_rec_per_ch::Int
    total_recs::Int

    m::AlazarMode

    NPTRecordResponse(a,b,c) = begin
        b <= 0 && error("Need at least one sample.")
        c <= 0 && error("Need at least one record.")
        r = new(a,b,c)
        r.m = NPTRecordMode(r.sam_per_rec_per_ch * inspect(r.ins, ChannelCount),
                            r.total_recs)
        r
    end
end
NPTRecordResponse(a::InstrumentAlazar, sam_per_rec_per_ch, total_recs) =
    NPTRecordResponse{SharedArray{Float16,2}}(a, sam_per_rec_per_ch, total_recs)

"""
Response type implementing the FPGA-based "FFT record mode" of the Alazar API.
"""
type FFTHardwareResponse{T} <: FFTResponse{T}
    ins::InstrumentAlazar
    sam_per_rec::Int
    sam_per_fft::Int
    total_recs::Int
    output_eltype::DataType

    m::AlazarMode

    FFTHardwareResponse{S<:Alazar.AlazarFFTBits}(a,b,c,d,e::Type{S}) = begin
        b <= 0 && error("Need at least one sample.")
        c == 0 && error("FFT length (samples) too short.")
        !ispow2(c) && error("FFT length (samples) not a power of 2.")
        d <= 0 && error("Need at least one record.")
        !(e <: Alazar.AlazarFFTBits) && error("Takes an AlazarFFTBits type.")
        r = new(a,b,c,d,e)
        r.m = FFTRecordMode(r.sam_per_rec, r.sam_per_fft,
                            r.total_recs, r.output_eltype)
        r
    end
end
FFTHardwareResponse{S<:Alazar.AlazarFFTBits}(a,b,c,d,e::Type{S}) =
    FFTHardwareResponse{SharedArray{S,2}}(a,b,c,d,e)

"""
Response type for measuring with NPT record mode, then using Julia's FFTW to
return the FFT. Slower than doing it with the FPGA, but ultimately necessary if
we want to use both channels as inputs to the FFT.
"""
type IQSoftwareResponse{T} <: RecordResponse{T}
    ins::InstrumentAlazar
    sam_per_rec_per_ch::Int
    total_recs::Int

    m::AlazarMode

    IQSoftwareResponse(a,b,c) = begin
        b <= 0 && error("Need at least one sample.")
        c <= 0 && error("Need at least one record.")
        r = new(a,b,c)
        r.m = NPTRecordMode(r.sam_per_rec_per_ch * inspect(r.ins, ChannelCount),
                            r.total_recs)
        r
    end
end
IQSoftwareResponse(a::InstrumentAlazar, sam_per_rec_per_ch, total_recs) =
    IQSoftwareResponse{SharedArray{Float32,2}}(a, sam_per_rec_per_ch, total_recs)

type AlternatingRealImagResponse{T} <: FFTResponse{T}
    ins::InstrumentAlazar
    sam_per_rec::Int
    sam_per_fft::Int
    total_recs::Int

    m::AlazarMode
    mIm::AlazarMode

    AlternatingRealImagResponse(a,b,c,d) = begin
        b <= 0 && error("Need at least one sample.")
        c == 0 && error("FFT length (samples) too short.")
        !ispow2(c) && error("FFT length (samples) not a power of 2.")
        d <= 0 && error("Need at least one record.")
        r = new(a,b,c,d)
        r.m = FFTRecordMode(r.sam_per_rec, r.sam_per_fft,
                              1, Alazar.S32Real)
        r.mIm = FFTRecordMode(r.sam_per_rec, r.sam_per_fft,
                              1, Alazar.S32Imag)
        r
    end
end
