export AlazarAux
export AlazarChannel
export AlazarDataPacking
export AlazarLSB
export AlazarTimestampReset

export AuxSoftwareTriggerEnable
export BitsPerSample
export BytesPerSample
export BufferAlignment
export ChannelCount
export Coupling
export LED
export MaxBufferBytes
export MinFFTSamples
export MaxFFTSamples
export MinSamplesPerRecord
export PretriggerAlignment
export RecordCount
export SampleMemoryPerChannel
export Sleep
export TriggerCoupling
export TriggerEngine
export TriggerDelaySamples
export TriggerRange
export TriggerTimeoutS
export TriggerTimeoutTicks

"An InstrumentProperty specific to AlazarTech digitizers."
abstract AlazarProperty       <: InstrumentProperty

abstract AlazarAux            <: AlazarProperty
abstract AlazarChannel        <: AlazarProperty
abstract AlazarDataPacking    <: AlazarProperty
abstract AlazarLSB            <: AlazarProperty
abstract AlazarOutputTTLLevel <: AlazarProperty
abstract AlazarTimestampReset <: AlazarProperty

subtypesArray = [

    (:LSBDefault,                AlazarLSB),
    (:LSBExtTrigger,             AlazarLSB),
    (:LSBAuxIn0,                 AlazarLSB),
    (:LSBAuxIn1,                 AlazarLSB),

    (:TTLHigh,                   AlazarOutputTTLLevel),
    (:TTLLow,                    AlazarOutputTTLLevel),

]::Array{Tuple{Symbol,DataType},1}

# Create all the concrete types we need using the generate_properties function.
# for ((subtypeSymb,supertype) in subtypesArray)
#     generate_properties(subtypeSymb, supertype)
# end

responses = Dict(
    :AlazarOutputTTLLevel => Dict(U32(0) => :TTLLow,
                                  U32(1) => :TTLHigh),
)

# generate_handlers(InstrumentAlazar, responses)

abstract AuxSoftwareTriggerEnable  <: AlazarProperty
abstract BitsPerSample             <: AlazarProperty
abstract BytesPerSample            <: AlazarProperty
abstract BufferAlignment           <: AlazarProperty
abstract ChannelCount              <: AlazarProperty
abstract Coupling                  <: AlazarProperty
abstract LED                       <: AlazarProperty
abstract MinSamplesPerRecord       <: AlazarProperty
abstract MaxBufferBytes            <: AlazarProperty
abstract MinFFTSamples             <: AlazarProperty
abstract MaxFFTSamples             <: AlazarProperty
abstract PretriggerAlignment       <: AlazarProperty
abstract RecordCount               <: AlazarProperty
abstract SampleMemoryPerChannel    <: AlazarProperty
abstract Sleep                     <: AlazarProperty
abstract TriggerCoupling           <: AlazarProperty
abstract TriggerDelaySamples       <: AlazarProperty
abstract TriggerEngine             <: AlazarProperty
abstract TriggerRange              <: AlazarProperty
abstract TriggerTimeoutS           <: AlazarProperty
abstract TriggerTimeoutTicks       <: AlazarProperty

function symbol_to_aux_mode(s)
    if s == :AuxOutputTrigger
        Alazar.AUX_OUT_TRIGGER
    elseif s == :AuxInputTriggerEnable
        Alazar.AUX_IN_TRIGGER_ENABLE
    elseif s == :AuxOutputPacer
        Alazar.AUX_OUT_PACER
    elseif s == :AuxDigitalInput
        Alazar.AUX_IN_AUXILIARY
    elseif s == :AuxDigitalOutput
        Alazar.AUX_OUT_SERIAL_DATA
    else
        error("Unexpected symbol.")
    end
end

function symbol_to_channel_code(s)
    if s == :ChannelA
        Alazar.CHANNEL_A
    elseif s == :ChannelB
        Alazar.CHANNEL_B
    elseif s == :BothChannels
        Alazar.CHANNEL_A | Alazar.CHANNEL_B
    else
        error("Unexpected symbol.")
    end
end

function symbol_to_clock_slope(s)
    if s == :Rising
        Alazar.CLOCK_EDGE_RISING
    elseif s == :Falling
        Alazar.CLOCK_EDGE_FALLING
    else
        error("Unexpected symbol.")
    end
end

function symbol_to_clock_source(s)
    if s == :Internal
        Alazar.INTERNAL_CLOCK
    elseif s == :External
        Alazar.EXTERNAL_CLOCK_10MHz_REF
    else
        error("Unexpected symbol.")
    end
end

function symbol_to_coupling(s)
    if s == :DC
        Alazar.DC_COUPLING
    elseif s == :AC
        Alazar.AC_COUPLING
    else
        error("Unexpected symbol.")
    end
end

function symbol_to_pack(p)
    if p == :DefaultPacking
        Alazar.PACK_DEFAULT
    elseif p == :Pack8Bits
        Alazar.PACK_8_BITS_PER_SAMPLE
    elseif p == :Pack12Bits
        Alazar.PACK_12_BITS_PER_SAMPLE
    else
        error("Unexpected symbol.")
    end
end

function symbol_to_ext_trig_range(s)
    if s == :Range5V
        Alazar.ETR_5V
    elseif s == :Range2_5V
        Alazar.ETR_2V5
    elseif s == :RangeTTL
        Alazar.ETR_TTL
    else
        error("Unexpected symbol.")
    end
end

function symbol_to_trig_engine(s)
    if s == :TriggerOnJ
        Alazar.TRIG_ENGINE_OP_J
    elseif s == :TriggerOnK
        Alazar.TRIG_ENGINE_OP_K
    elseif s == :TriggerOnJOrK
        Alazar.TRIG_ENGINE_OP_J_OR_K
    elseif s == :TriggerOnJAndK
        Alazar.TRIG_ENGINE_OP_J_AND_K
    elseif s == :TriggerOnJXorK
        Alazar.TRIG_ENGINE_OP_J_XOR_K
    elseif s == :TriggerOnJAndNotK
        Alazar.TRIG_ENGINE_OP_J_AND_NOT_K
    elseif s == :TriggerOnNotJAndK
        Alazar.TRIG_ENGINE_OP_NOT_J_AND_K
    else
        error("Unexpected symbol.")
    end
end

function symbol_to_trig_slope(s)
    if s == :Rising
        Alazar.TRIGGER_SLOPE_POSITIVE
    elseif s == :Falling
        Alazar.TRIGGER_SLOPE_NEGATIVE
    else
        error("Unexpected symbol.")
    end
end

function symbol_to_trig_source(s)
    if s == :External
        Alazar.TRIG_EXTERNAL
    elseif s == :Disabled
        Alazar.TRIG_DISABLE
    elseif s == :ChannelA
        Alazar.TRIG_CHAN_A
    elseif s == :ChannelB
        Alazar.TRIG_CHAN_B
    else
        error("Unexpected symbol.")
    end
end

function symbol_to_ts_reset(s)
    if s == :Once
        Alazar.TIMESTAMP_RESET_FIRSTTIME_ONLY
    elseif s == :Always
        Alazar.TIMESTAMP_RESET_ALWAYS
    else
        error("Unexpected symbol.")
    end
end

function clock_code_to_rate(s)
    if s == Alazar.SAMPLE_RATE_1KSPS
        1e3
    elseif s == Alazar.SAMPLE_RATE_2KSPS
        2e3
    elseif s == Alazar.SAMPLE_RATE_5KSPS
        5e3
    elseif s == Alazar.SAMPLE_RATE_10KSPS
        1e4
    elseif s == Alazar.SAMPLE_RATE_20KSPS
        2e4
    elseif s == Alazar.SAMPLE_RATE_50KSPS
        5e4
    elseif s == Alazar.SAMPLE_RATE_100KSPS
        1e5
    elseif s == Alazar.SAMPLE_RATE_200KSPS
        2e5
    elseif s == Alazar.SAMPLE_RATE_500KSPS
        5e5
    elseif s == Alazar.SAMPLE_RATE_1MSPS
        1e6
    elseif s == Alazar.SAMPLE_RATE_2MSPS
        2e6
    elseif s == Alazar.SAMPLE_RATE_5MSPS
        5e6
    elseif s == Alazar.SAMPLE_RATE_10MSPS
        1e7
    elseif s == Alazar.SAMPLE_RATE_20MSPS
        2e7
    elseif s == Alazar.SAMPLE_RATE_50MSPS
        5e7
    elseif s == Alazar.SAMPLE_RATE_100MSPS
        1e8
    elseif s == Alazar.SAMPLE_RATE_200MSPS
        2e8
    elseif s == Alazar.SAMPLE_RATE_500MSPS
        5e8
    elseif s == Alazar.SAMPLE_RATE_800MSPS
        8e8
    elseif s == Alazar.SAMPLE_RATE_1000MSPS
        1e9
    elseif s == Alazar.SAMPLE_RATE_1200MSPS
        12e8
    elseif s == Alazar.SAMPLE_RATE_1500MSPS
        15e8
    elseif s == Alazar.SAMPLE_RATE_1800MSPS
        18e8
    end
end

function symbol_to_clock_code(s::Symbol)
    if s == :Rate1kSps
        Alazar.SAMPLE_RATE_1KSPS
    elseif s == :Rate2kSps
        Alazar.SAMPLE_RATE_2KSPS
    elseif s == :Rate5kSps
        Alazar.SAMPLE_RATE_5KSPS
    elseif s == :Rate10kSps
        Alazar.SAMPLE_RATE_10KSPS
    elseif s == :Rate20kSps
        Alazar.SAMPLE_RATE_20KSPS
    elseif s == :Rate50kSps
        Alazar.SAMPLE_RATE_50KSPS
    elseif s == :Rate100kSps
        Alazar.SAMPLE_RATE_100KSPS
    elseif s == :Rate200kSps
        Alazar.SAMPLE_RATE_200KSPS
    elseif s == :Rate500kSps
        Alazar.SAMPLE_RATE_500KSPS
    elseif s == :Rate1MSps
        Alazar.SAMPLE_RATE_1MSPS
    elseif s == :Rate2MSps
        Alazar.SAMPLE_RATE_2MSPS
    elseif s == :Rate5MSps
        Alazar.SAMPLE_RATE_5MSPS
    elseif s == :Rate10MSps
        Alazar.SAMPLE_RATE_10MSPS
    elseif s == :Rate20MSps
        Alazar.SAMPLE_RATE_20MSPS
    elseif s == :Rate50MSps
        Alazar.SAMPLE_RATE_50MSPS
    elseif s == :Rate100MSps
        Alazar.SAMPLE_RATE_100MSPS
    elseif s == :Rate200MSps
        Alazar.SAMPLE_RATE_200MSPS
    elseif s == :Rate500MSps
        Alazar.SAMPLE_RATE_500MSPS
    elseif s == :Rate800MSps
        Alazar.SAMPLE_RATE_800MSPS
    elseif s == :Rate1000MSps || s == :Rate1GSps
        Alazar.SAMPLE_RATE_1000MSPS
    elseif s == :Rate1200MSps
        Alazar.SAMPLE_RATE_1200MSPS
    elseif s == :Rate1500MSps
        Alazar.SAMPLE_RATE_1500MSPS
    elseif s == :Rate1800MSps
        Alazar.SAMPLE_RATE_1800MSPS
    end
end
