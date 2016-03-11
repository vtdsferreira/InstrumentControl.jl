include(joinpath(Pkg.dir("PainterQB"),"src/meta/Metaprogramming.jl"))

export AlazarAux
export AlazarChannel
export AlazarDataPacking
export AlazarLSB
export AlazarTimestampReset
export AlazarTriggerEngine
export AlazarTriggerRange

export AuxSoftwareTriggerEnable
export BitsPerSample
export BytesPerSample
export BufferAlignment
export ChannelCount
export LED
export MaxBufferBytes
export MinFFTSamples
export MaxFFTSamples
export MinSamplesPerRecord
export PretriggerAlignment
export RecordCount
export SampleMemoryPerChannel
export Sleep
export TriggerDelaySamples
export TriggerTimeoutS
export TriggerTimeoutTicks

export Rate1GSps

"An InstrumentProperty specific to AlazarTech digitizers."
abstract AlazarProperty{T}    <: InstrumentProperty{T}

abstract AlazarAux            <: AlazarProperty
abstract AlazarChannel        <: AlazarProperty
abstract AlazarDataPacking    <: AlazarProperty
abstract AlazarLSB            <: AlazarProperty
abstract AlazarOutputTTLLevel <: AlazarProperty
abstract AlazarTimestampReset <: AlazarProperty
abstract AlazarTriggerEngine  <: AlazarProperty
abstract AlazarTriggerRange   <: AlazarProperty

subtypesArray = [

    (:AuxOutputTrigger,          AlazarAux),
    (:AuxInputTriggerEnable,     AlazarAux),
    (:AuxOutputPacer,            AlazarAux),
    (:AuxDigitalInput,           AlazarAux),
    (:AuxDigitalOutput,          AlazarAux),

    (:ChannelA,                  AlazarChannel),
    (:ChannelB,                  AlazarChannel),
    (:BothChannels,              AlazarChannel),

    (:DefaultPacking,            AlazarDataPacking),
    (:Pack8Bits,                 AlazarDataPacking),
    (:Pack12Bits,                AlazarDataPacking),

    (:LSBDefault,                AlazarLSB),
    (:LSBExtTrigger,             AlazarLSB),
    (:LSBAuxIn0,                 AlazarLSB),
    (:LSBAuxIn1,                 AlazarLSB),

    (:TTLHigh,                   AlazarOutputTTLLevel),
    (:TTLLow,                    AlazarOutputTTLLevel),

    (:TimestampResetOnce,        AlazarTimestampReset),
    (:TimestampResetAlways,      AlazarTimestampReset),

    (:TriggerOnJ,                AlazarTriggerEngine),
    (:TriggerOnK,                AlazarTriggerEngine),
    (:TriggerOnJOrK,             AlazarTriggerEngine),
    (:TriggerOnJAndK,            AlazarTriggerEngine),
    (:TriggerOnJXorK,            AlazarTriggerEngine),
    (:TriggerOnJAndNotK,         AlazarTriggerEngine),
    (:TriggerOnNotJAndK,         AlazarTriggerEngine),

    (:ExternalTrigger5V,         AlazarTriggerRange),
    (:ExternalTriggerTTL,        AlazarTriggerRange),
    (:ExternalTrigger2V5,        AlazarTriggerRange),

    (:Rate1kSps,                 SampleRate),
    (:Rate2kSps,                 SampleRate),
    (:Rate5kSps,                 SampleRate),
    (:Rate10kSps,                SampleRate),
    (:Rate20kSps,                SampleRate),
    (:Rate50kSps,                SampleRate),
    (:Rate100kSps,               SampleRate),
    (:Rate200kSps,               SampleRate),
    (:Rate500kSps,               SampleRate),
    (:Rate1MSps,                 SampleRate),
    (:Rate2MSps,                 SampleRate),
    (:Rate5MSps,                 SampleRate),
    (:Rate10MSps,                SampleRate),
    (:Rate20MSps,                SampleRate),
    (:Rate50MSps,                SampleRate),
    (:Rate100MSps,               SampleRate),
    (:Rate200MSps,               SampleRate),
    (:Rate500MSps,               SampleRate),
    (:Rate800MSps,               SampleRate),
    (:Rate1000MSps,              SampleRate),
    (:Rate1200MSps,              SampleRate),
    (:Rate1500MSps,              SampleRate),
    (:Rate1800MSps,              SampleRate),
    (:RateUser,                  SampleRate),

    (:ChannelATrigger,           TriggerSource),
    (:ChannelBTrigger,           TriggerSource),
    (:DisableTrigger,            TriggerSource)

]::Array{Tuple{Symbol,DataType},1}

# Create all the concrete types we need using the generate_properties function.
for ((subtypeSymb,supertype) in subtypesArray)
    generate_properties(subtypeSymb, supertype)
end

"Type alias for `Rate1000MSps`."
typealias Rate1GSps Rate1000MSps

responses = Dict(
    :Coupling       => Dict(Alazar.AC_COUPLING              => :AC,
                            Alazar.DC_COUPLING              => :DC),

    :ClockSlope     => Dict(Alazar.CLOCK_EDGE_RISING        => :RisingClock,
                            Alazar.CLOCK_EDGE_FALLING       => :FallingClock),

    :ClockSource    => Dict(Alazar.INTERNAL_CLOCK           => :InternalClock,
                            Alazar.EXTERNAL_CLOCK_10MHz_REF => :ExternalClock),

    :SampleRate     => Dict(Alazar.SAMPLE_RATE_1KSPS        => :Rate1kSps,
                            Alazar.SAMPLE_RATE_2KSPS        => :Rate2kSps,
                            Alazar.SAMPLE_RATE_5KSPS        => :Rate5kSps,
                            Alazar.SAMPLE_RATE_10KSPS       => :Rate10kSps,
                            Alazar.SAMPLE_RATE_20KSPS       => :Rate20kSps,
                            Alazar.SAMPLE_RATE_50KSPS       => :Rate50kSps,
                            Alazar.SAMPLE_RATE_100KSPS      => :Rate100kSps,
                            Alazar.SAMPLE_RATE_200KSPS      => :Rate200kSps,
                            Alazar.SAMPLE_RATE_500KSPS      => :Rate500kSps,
                            Alazar.SAMPLE_RATE_1MSPS        => :Rate1MSps,
                            Alazar.SAMPLE_RATE_2MSPS        => :Rate2MSps,
                            Alazar.SAMPLE_RATE_5MSPS        => :Rate5MSps,
                            Alazar.SAMPLE_RATE_10MSPS       => :Rate10MSps,
                            Alazar.SAMPLE_RATE_20MSPS       => :Rate20MSps,
                            Alazar.SAMPLE_RATE_50MSPS       => :Rate50MSps,
                            Alazar.SAMPLE_RATE_100MSPS      => :Rate100MSps,
                            Alazar.SAMPLE_RATE_200MSPS      => :Rate200MSps,
                            Alazar.SAMPLE_RATE_500MSPS      => :Rate500MSps,
                            Alazar.SAMPLE_RATE_800MSPS      => :Rate800MSps,
                            Alazar.SAMPLE_RATE_1000MSPS     => :Rate1000MSps,
                            Alazar.SAMPLE_RATE_1200MSPS     => :Rate1200MSps,
                            Alazar.SAMPLE_RATE_1500MSPS     => :Rate1500MSps,
                            Alazar.SAMPLE_RATE_1800MSPS     => :Rate1800MSps),

    :TriggerSlope   => Dict(Alazar.TRIGGER_SLOPE_POSITIVE   => :RisingTrigger,
                            Alazar.TRIGGER_SLOPE_NEGATIVE   => :FallingTrigger),

    :TriggerSource  => Dict(Alazar.TRIG_EXTERNAL            => :ExternalTrigger,
                            Alazar.TRIG_DISABLE             => :DisableTrigger,
                            Alazar.TRIG_CHAN_A              => :ChannelATrigger,
                            Alazar.TRIG_CHAN_B              => :ChannelBTrigger),

    :AlazarAux      => Dict(Alazar.AUX_OUT_TRIGGER       =>  :AuxOutputTrigger,
                            Alazar.AUX_IN_TRIGGER_ENABLE =>  :AuxInputTriggerEnable,
                            Alazar.AUX_OUT_PACER         =>  :AuxOutputPacer,
                            Alazar.AUX_IN_AUXILIARY      =>  :AuxDigitalInput,
                            Alazar.AUX_OUT_SERIAL_DATA   =>  :AuxDigitalOutput),

    :AlazarChannel => Dict(Alazar.CHANNEL_A                    => :ChannelA,
                           Alazar.CHANNEL_B                    => :ChannelB,
                           Alazar.CHANNEL_A | Alazar.CHANNEL_B => :BothChannels),

    :AlazarDataPacking =>
            Dict(Alazar.PACK_DEFAULT            => :DefaultPacking,
                 Alazar.PACK_8_BITS_PER_SAMPLE  => :Pack8Bits,
                 Alazar.PACK_12_BITS_PER_SAMPLE => :Pack12Bits),

    :AlazarOutputTTLLevel => Dict(U32(0) => :TTLLow,
                                  U32(1) => :TTLHigh),

    :AlazarTimestampReset =>
            Dict(Alazar.TIMESTAMP_RESET_ALWAYS         => :TimestampResetAlways,
                 Alazar.TIMESTAMP_RESET_FIRSTTIME_ONLY => :TimestampResetOnce),

    :AlazarTriggerEngine =>
            Dict(Alazar.TRIG_ENGINE_OP_J           => :TriggerOnJ,
                 Alazar.TRIG_ENGINE_OP_K           => :TriggerOnK,
                 Alazar.TRIG_ENGINE_OP_J_OR_K      => :TriggerOnJOrK,
                 Alazar.TRIG_ENGINE_OP_J_AND_K     => :TriggerOnJAndK,
                 Alazar.TRIG_ENGINE_OP_J_XOR_K     => :TriggerOnJXorK,
                 Alazar.TRIG_ENGINE_OP_J_AND_NOT_K => :TriggerOnJAndNotK,
                 Alazar.TRIG_ENGINE_OP_NOT_J_AND_K => :TriggerOnNotJAndK),

    :AlazarTriggerRange => Dict(Alazar.ETR_5V   => :ExternalTrigger5V,
                                Alazar.ETR_2V5  => :ExternalTrigger2V5,
                                Alazar.ETR_TTL  => :ExternalTriggerTTL),
)

generate_handlers(InstrumentAlazar, responses)

Rate1GSps{T<:InstrumentAlazar}(insType::Type{T}) = Rate1000MSps(insType)

abstract AuxSoftwareTriggerEnable  <: AlazarProperty
abstract BitsPerSample             <: AlazarProperty
abstract BytesPerSample            <: AlazarProperty
abstract BufferAlignment           <: AlazarProperty
abstract ChannelCount              <: AlazarProperty
abstract LED                       <: AlazarProperty
abstract MinSamplesPerRecord       <: AlazarProperty
abstract MaxBufferBytes            <: AlazarProperty
abstract MinFFTSamples             <: AlazarProperty
abstract MaxFFTSamples             <: AlazarProperty
abstract PretriggerAlignment       <: AlazarProperty
abstract RecordCount               <: AlazarProperty
abstract SampleMemoryPerChannel    <: AlazarProperty
abstract Sleep                     <: AlazarProperty
abstract TriggerDelaySamples       <: AlazarProperty
abstract TriggerTimeoutS           <: AlazarProperty
abstract TriggerTimeoutTicks       <: AlazarProperty

samplerate{T<:Rate1kSps}(::Type{T})    = 1e3
samplerate{T<:Rate2kSps}(::Type{T})    = 2e3
samplerate{T<:Rate5kSps}(::Type{T})    = 5e3
samplerate{T<:Rate10kSps}(::Type{T})   = 1e4
samplerate{T<:Rate20kSps}(::Type{T})   = 2e4
samplerate{T<:Rate50kSps}(::Type{T})   = 5e4
samplerate{T<:Rate100kSps}(::Type{T})  = 1e5
samplerate{T<:Rate200kSps}(::Type{T})  = 2e5
samplerate{T<:Rate500kSps}(::Type{T})  = 5e5
samplerate{T<:Rate1MSps}(::Type{T})    = 1e6
samplerate{T<:Rate2MSps}(::Type{T})    = 2e6
samplerate{T<:Rate5MSps}(::Type{T})    = 5e6
samplerate{T<:Rate10MSps}(::Type{T})   = 1e7
samplerate{T<:Rate20MSps}(::Type{T})   = 2e7
samplerate{T<:Rate50MSps}(::Type{T})   = 5e7
samplerate{T<:Rate100MSps}(::Type{T})  = 1e8
samplerate{T<:Rate200MSps}(::Type{T})  = 2e8
samplerate{T<:Rate500MSps}(::Type{T})  = 5e8
samplerate{T<:Rate800MSps}(::Type{T})  = 8e8
samplerate{T<:Rate1000MSps}(::Type{T}) = 1e9
samplerate{T<:Rate1200MSps}(::Type{T}) = 12e8
samplerate{T<:Rate1500MSps}(::Type{T}) = 15e8
samplerate{T<:Rate1800MSps}(::Type{T}) = 18e8
