export AlazarMode
export StreamMode, RecordMode
export ContinuousStreamMode, TriggeredStreamMode
export NPTRecordMode, TraditionalRecordMode
export FFTRecordMode

# At some point we will no longer export these
export adma, pretriggersamples

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

    by_rec::U32
    buf_size::Int
    buf_count::Int

    FFTRecordMode(a,b,c,d) = new(a,b,c,d,0,0,0)
end

pretriggersamples(m::TraditionalRecordMode) = m.pre_sam_per_rec
pretriggersamples(m::AlazarMode) = 0

adma(::ContinuousStreamMode)   = Alazar.ADMA_CONTINUOUS_MODE |
                                 Alazar.ADMA_FIFO_ONLY_STREAMING |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::TriggeredStreamMode)    = Alazar.ADMA_TRIGGERED_STREAMING |
                                 Alazar.ADMA_FIFO_ONLY_STREAMING |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::NPTRecordMode)          = Alazar.ADMA_NPT |
                                 Alazar.ADMA_FIFO_ONLY_STREAMING |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::TraditionalRecordMode)  = Alazar.ADMA_TRADITIONAL_MODE |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE
                                 # other flags?

adma(::FFTRecordMode)          = Alazar.ADMA_NPT |
                                 Alazar.ADMA_DSP |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE
