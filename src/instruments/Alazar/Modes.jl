export AlazarMode
export StreamMode, RecordMode
export ContinuousStreamMode, TriggeredStreamMode
export NPTRecordMode, TraditionalRecordMode

# At some point we will no longer export these
export adma, pretriggersamples

abstract AlazarMode
abstract StreamMode <: AlazarMode
abstract RecordMode <: AlazarMode

type ContinuousStreamMode <: StreamMode
    total_samples::Int
end

type TriggeredStreamMode <: StreamMode
    total_samples::Int
end

type NPTRecordMode <: RecordMode
    sam_per_rec::Int
    total_recs::Int
end

type TraditionalRecordMode <: RecordMode
    pre_sam_per_rec::Int
    post_sam_per_rec::Int
    total_recs::Int
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
