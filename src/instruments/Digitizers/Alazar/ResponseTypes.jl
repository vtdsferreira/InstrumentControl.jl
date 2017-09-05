export ContinuousStreamResponse
export TriggeredStreamResponse
export NPTRecordResponse
export FFTHardwareResponse
export IQSoftwareResponse

"""
    abstract type AlazarResponse{S,T} <: Response
Abstract `Response` from an Alazar digitizer instrument. Subtypes should implement
`return_type` to specify the output array type if they rely on the generic method
`measure(::AlazarResponse)`.
"""
abstract type AlazarResponse{S,T} <: Response end
declared_bits(::AlazarResponse{S,T}) where {S,T} = T

"""
    abstract type StreamResponse{S,T} <: AlazarResponse{S,T}
Abstract time-domain streaming `Response` from an Alazar digitizer instrument.
"""
abstract type StreamResponse{S,T} <: AlazarResponse{S,T} end

"""
    abstract type RecordResponse{S,T} <: AlazarResponse{S,T}
Abstract time-domain record `Response` from an Alazar digitizer instrument.
"""
abstract type RecordResponse{S,T} <: AlazarResponse{S,T} end

"""
    abstract type FFTResponse{S,T} <: AlazarResponse{S,T}
Abstract FFT `Response` from an Alazar digitizer instrument.
"""
abstract type FFTResponse{S,T} <: AlazarResponse{S,T} end

"""
    mutable struct ContinuousStreamResponse{S,T} <: StreamResponse{S,T}
Response type implementing the "continuous streaming mode" of the Alazar API.

Usage example:
```
ats = AlazarATS9870()
samples_per_ch = 1024
res = ContinuousStreamResponse(ats, samples_per_ch)
measure(res)
```
"""
mutable struct ContinuousStreamResponse{S,T} <: StreamResponse{S,T}
    ins::S
    samples_per_ch::Int
    m::ContinuousStreamMode

    function ContinuousStreamResponse{S,T}(ins, samples_per_ch) where {S,T}
        @assert samples_per_ch > 0
        return new{S,T}(ins, samples_per_ch,
            ContinuousStreamMode(samples_per_ch * ins[ChannelCount]))
    end
end
ContinuousStreamResponse(a::InstrumentAlazar, samples_per_ch) =
    ContinuousStreamResponse{typeof(a), Int(bits_per_sample(a))}(a, samples_per_ch)
return_type(::ContinuousStreamResponse) = Vector{Float16}

"""
    mutable struct TriggeredStreamResponse{S,T} <: StreamResponse{S,T}
Response type implementing the "triggered streaming mode" of the Alazar API.

Usage example:
```
ats = AlazarATS9870()
samples_per_ch = 1024
res = TriggeredStreamResponse(ats, samples_per_ch)
measure(res)
```
"""
mutable struct TriggeredStreamResponse{S,T} <: StreamResponse{S,T}
    ins::S
    samples_per_ch::Int
    m::TriggeredStreamMode

    function TriggeredStreamResponse{S,T}(ins, samples_per_ch) where {S,T}
        @assert samples_per_ch > 0
        return new{S,T}(ins, samples_per_ch,
            TriggeredStreamMode(samples_per_ch * ins[ChannelCount]))
    end
end
TriggeredStreamResponse(a::InstrumentAlazar, samples_per_ch) =
    TriggeredStreamResponse{typeof(a), Int(bits_per_sample(a))}(a, samples_per_ch)
return_type(::TriggeredStreamResponse) = Vector{Float16}

"""
    mutable struct NPTRecordResponse{S,T} <: RecordResponse{S,T}
Response type implementing the "NPT record mode" of the Alazar API.

Usage example:
```
ats = AlazarATS9870()
samples_per_rec_per_ch = 1024
total_recs = 10
res = NPTRecordResponse(ats, sam_per_rec_per_ch, total_recs)
measure(res)
```
"""
mutable struct NPTRecordResponse{S,T} <: RecordResponse{S,T}
    ins::S
    sam_per_rec_per_ch::Int
    total_recs::Int
    m::NPTRecordMode

    function NPTRecordResponse{S,T}(ins, sam_per_rec_per_ch, total_recs) where {S,T}
        @assert sam_per_rec_per_ch > 0
        @assert total_recs > 0
        return new{S,T}(ins, sam_per_rec_per_ch, total_recs,
            NPTRecordMode(sam_per_rec_per_ch * ins[ChannelCount], total_recs))
    end
end
NPTRecordResponse(a::InstrumentAlazar, sam_per_rec_per_ch, total_recs) =
    NPTRecordResponse{typeof(a), Int(bits_per_sample(a))}(a, sam_per_rec_per_ch, total_recs)
return_type(::NPTRecordResponse) = Matrix{Float16}

"""
    mutable struct FFTHardwareResponse{S,T,U} <: FFTResponse{S,T}
Response type implementing the FPGA-based "FFT record mode" of the Alazar API. Not all
Alazar digitizers support this mode.

Usage example:
```
ats = AlazarATS9360()
samples_per_rec = 1024
sam_per_fft = 512
total_recs = 10
res = FFTHardwareResponse(ats, sam_per_rec, sam_per_fft, total_recs, Alazar.S32Real)
measure(res)
```
"""
mutable struct FFTHardwareResponse{S,T,U} <: FFTResponse{S,T}
    ins::S
    sam_per_rec::Int
    sam_per_fft::Int
    total_recs::Int
    m::FFTRecordMode{U}

    function (FFTHardwareResponse{S,T,U}(ins, sam_per_rec, sam_per_fft, total_recs)
            where {S,T,U<:Alazar.AlazarFFTBits})
        @assert sam_per_rec > 0
        @assert sam_per_fft > 0
        @assert ispow2(sam_per_fft)
        @assert total_recs > 0
        return new{S,T,U}(ins, sam_per_rec, sam_per_fft, total_recs,
            FFTRecordMode{U}(sam_per_rec, sam_per_fft, total_recs))
    end
end
(FFTHardwareResponse(a::InstrumentAlazar, sam_per_rec, sam_per_fft, total_recs, ::Type{S})
    where {S <: Alazar.AlazarFFTBits}) =
        FFTHardwareResponse{typeof(a), sizeof(S), S}(a, sam_per_rec, sam_per_fft, total_recs)
return_type(::FFTHardwareResponse{S,T,U}) where {S,T,U} = Matrix{U}

"""
    mutable struct IQSoftwareResponse{S,T} <: RecordResponse{S,T}
Response type for measuring with NPT record mode and mixing in software to find the phase
and amplitude of a component at frequency `f`. Slower than doing it in an FPGA, but
ultimately necessary if we want to use both channels as inputs to the FFT.

Usage example:
```
ats = AlazarATS9870()
samples_per_rec_per_ch = 1024
total_recs = 10
f = 100e6
res = IQSoftwareResponse(ats, samples_per_rec_per_ch, total_recs, f)
measure(res)
```
"""
mutable struct IQSoftwareResponse{S,T} <: RecordResponse{S,T}
    ins::S
    sam_per_rec_per_ch::Int
    total_recs::Int
    f::Float64
    m::NPTRecordMode

    function IQSoftwareResponse{S,T}(ins, sam_per_rec_per_ch, total_recs, f) where {S,T}
        @assert sam_per_rec_per_ch > 0
        @assert total_recs > 0
        return new{S,T}(ins, sam_per_rec_per_ch, total_recs, f,
            NPTRecordMode(sam_per_rec_per_ch * ins[ChannelCount], total_recs))
    end
end
IQSoftwareResponse(a::InstrumentAlazar, sam_per_rec_per_ch, total_recs, f) =
    IQSoftwareResponse{typeof(a), Int(bits_per_sample(a))}(a, sam_per_rec_per_ch, total_recs, f)
