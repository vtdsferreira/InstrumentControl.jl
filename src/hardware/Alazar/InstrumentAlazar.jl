"""
Julia interface to the AlazarTech SDK.

Adapted from the C and Python APIs by Andrew Keller (andrew.keller.09@gmail.com)

Please see the ATS-SDK Guide for detailed specification of any functions
from the Alazar API.

Remember that a "sample" refers to a single channel.
One channel, one sample --> one value; Two channels, one sample --> two values.
You need to alloc memory for two values if you are measuring both channels.

Types:

InstrumentAlazar: Represents a digitizer. Abstract type.

AlazarATS9360: Concrete type.

AlazarATS9440: Abstract for now; accidentally wrote a method I didn't need

DSPModule: Concrete type representing a DSP module on a particular digitizer.

"""

module AlazarModule

using Alazar
importall PainterQB
include("../../Metaprogramming.jl")

# Play nice with Instruments
export AlazarAux
export AlazarChannel
export AlazarDataPacking
export AlazarLSB
export AlazarTimestampReset
export AlazarTriggerRange

export AuxSoftwareTriggerEnabled
export BitsPerSample
export BytesPerSample
export BufferCount
export BufferSize
export DefaultBufferCount
export DefaultBufferSize
export LED
export MaxBufferSize
export MinSamplesPerRecord
export RecordCount
export SampleMemoryPerChannel
export Sleep
export TriggerDelaySamples
export TriggerTimeoutS
export TriggerTimeoutTicks

export Bit
export Byte
export Sample
export Buffer
export Record
export Acquisition

export AlazarMode
export StreamMode, RecordMode
export ContinuousStreamMode, TriggeredStreamMode
export NPTRecordMode, TraditionalRecordMode, FFTRecordMode
export inf_records

export InstrumentAlazar
export AlazarATS9360

export DSPModule

export abort, before_async_read
export startcapture, wait_async_buffer, post_async_buffer

export busy
export forcetrigger, forcetriggerenable
export inputcontrol, set_parameter, set_parameter_ul
export set_triggeroperation, triggered

export inspect_per
export adma
# export bufferarray

"""
The InstrumentAlazar types represent an AlazarTech device on the local
system. It can be used to control configuration parameters, to
start acquisitions and to retrieve the acquired data.

Args:

  systemId (int): The board system identifier of the target
  board. Defaults to 1, which is suitable when there is only one
  board in the system.

  boardId (int): The target's board identifier in it's
  system. Defaults to 1, which is suitable when there is only one
  board in the system.

"""
abstract InstrumentAlazar <: Instrument
abstract AlazarProperty <: InstrumentProperty

"""
Type to link a `dsp_module_handle` with the `InstrumentAlazar` it came from.
"""
type DSPModule
    ins::InstrumentAlazar
    handle::dsp_module_handle
end

abstract AlazarAux            <: AlazarProperty
abstract AlazarChannel        <: AlazarProperty
abstract AlazarDataPacking    <: AlazarProperty
abstract AlazarLSB            <: AlazarProperty
abstract AlazarTimestampReset <: AlazarProperty
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

    (:TimestampResetOnce,        AlazarTimestampReset),
    (:TimestampResetAlways,      AlazarTimestampReset),

    (:ExtTrigger5V,              AlazarTriggerRange),
    (:ExtTriggerTTL,             AlazarTriggerRange),
    (:ExtTrigger2V5,             AlazarTriggerRange)

]::Array{Tuple{Symbol,DataType},1}

# Create all the concrete types we need using the generate_properties function.
for ((subtypeSymb,supertype) in subtypesArray)
    generate_properties(subtypeSymb, supertype)
end

responses = Dict(
    :Coupling           => Dict(Alazar.AC_COUPLING              => :AC,
                                Alazar.DC_COUPLING              => :DC),

    :ClockSlope         => Dict(Alazar.CLOCK_EDGE_RISING        => :RisingClock,
                                Alazar.CLOCK_EDGE_FALLING       => :FallingClock),

    :ClockSource        => Dict(Alazar.INTERNAL_CLOCK           => :InternalClock,
                                Alazar.EXTERNAL_CLOCK_10MHz_REF => :ExternalClock),

    :SampleRate         => Dict(Alazar.SAMPLE_RATE_1KSPS        => :Rate1kSps,
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

    :TriggerSlope       => Dict(Alazar.TRIGGER_SLOPE_POSITIVE   => :RisingTrigger,
                                Alazar.TRIGGER_SLOPE_NEGATIVE   => :FallingTrigger),

    :AlazarAux          => Dict(Alazar.AUX_OUT_TRIGGER       =>  :AuxOutputTrigger,
                                Alazar.AUX_IN_TRIGGER_ENABLE =>  :AuxInputTriggerEnable,
                                Alazar.AUX_OUT_PACER         =>  :AuxOutputPacer,
                                Alazar.AUX_IN_AUXILIARY      =>  :AuxDigitalInput,
                                Alazar.AUX_OUT_SERIAL_DATA   =>  :AuxDigitalOutput),

    :AlazarChannel      => Dict(Alazar.CHANNEL_A                    => :ChannelA,
                                Alazar.CHANNEL_B                    => :ChannelB,
                                Alazar.CHANNEL_A | Alazar.CHANNEL_B => :BothChannels),

    :AlazarDataPacking  => Dict(Alazar.PACK_DEFAULT            => :DefaultPacking,
                                Alazar.PACK_8_BITS_PER_SAMPLE  => :Pack8Bits,
                                Alazar.PACK_12_BITS_PER_SAMPLE => :Pack12Bits),

    :AlazarTimestampReset => Dict(Alazar.TIMESTAMP_RESET_ALWAYS  => :TimestampResetAlways,
                                  Alazar.TIMESTAMP_RESET_FIRSTTIME_ONLY => :TimestampResetOnce),

    :AlazarTriggerRange => Dict(Alazar.ETR_5V   => :ExternalTrigger5V,
                                Alazar.ETR_2V5  => :ExternalTrigger2V5,
                                Alazar.ETR_TTL  => :ExternalTriggerTTL)

)

generate_handlers(InstrumentAlazar, responses)

Rate1GSps{T<:InstrumentAlazar}(insType::Type{T}) = Rate1000MSps(insType)

abstract AuxSoftwareTriggerEnabled <: AlazarProperty
abstract BitsPerSample             <: AlazarProperty
abstract BytesPerSample            <: AlazarProperty
abstract BufferCount               <: AlazarProperty
abstract BufferSize                <: AlazarProperty
abstract DefaultBufferCount        <: AlazarProperty
abstract DefaultBufferSize         <: AlazarProperty
abstract LED                       <: AlazarProperty
abstract MaxBufferSize             <: AlazarProperty
abstract MinSamplesPerRecord       <: AlazarProperty
abstract RecordCount               <: AlazarProperty
abstract SampleMemoryPerChannel    <: AlazarProperty
abstract Sleep                     <: AlazarProperty
abstract TriggerDelaySamples       <: AlazarProperty
abstract TriggerTimeoutS           <: AlazarProperty
abstract TriggerTimeoutTicks       <: AlazarProperty

abstract PerProperty

abstract Bit         <: PerProperty
abstract Byte        <: PerProperty
abstract Sample      <: PerProperty
abstract Buffer      <: PerProperty
abstract Record      <: PerProperty
abstract Acquisition <: PerProperty

# sampleRate(rate::DataType) = begin
#     @assert rate <: InstrumentSampleRate "$rate <: InstrumentSampleRate"
#     sampleRate(rate())
# end
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


abstract AlazarMode
abstract StreamMode <: AlazarMode
abstract RecordMode <: AlazarMode

const inf_records = U32(0x7FFFFFFF)

type ContinuousStreamMode <: StreamMode
    total_samples::Integer
end

type TriggeredStreamMode <: StreamMode
    total_samples::Integer
end

type NPTRecordMode <: RecordMode
    sam_per_rec::Integer
    total_recs::Integer
end

type TraditionalRecordMode <: RecordMode
    pre_sam_per_rec::Integer
    post_sam_per_rec::Integer
    total_recs::Integer
end

type FFTRecordMode <: RecordMode
    sam_per_rec::AbstractFloat
    total_recs::Int
end

"Create descriptive exceptions."
InstrumentException(ins::InstrumentAlazar, r) =
    InstrumentException(ins, r, alazar_exception(r))

"Error intercept macro. Takes a function definition and brackets the RHS with some checking."
macro eh(expr)
    quote
        $(esc(expr.args[1])) = begin
            r = $(esc(expr.args[2]))
            if (r != alazar_no_error)
                throw(InstrumentException($(esc(expr.args[1].args[2].args[1])),r))
            end
            r
        end
    end
end

macro eh2(expr)
    quote
        r = $(esc(expr))
        r != alazar_no_error && throw(InstrumentException(esc(a),r))
        r
    end
end

abort(a::InstrumentAlazar, async::Bool=true) = begin
    if async
        r = @eh2 AlazarAbortAsyncRead(a.handle)
    else
        r = @eh2 AlazarAbortCapture(a.handle)
    end
    r
end

function before_async_read(a::InstrumentAlazar, m::AlazarMode)

    r = @eh2 AlazarBeforeAsyncRead(a.handle,
                              a.acquisitionChannel,
                              -pretriggersamples(m),
                              inspect_per(a, m, Sample, Record),
                              inspect_per(a, m, Record, Buffer),
                              inspect_per(a, m, Record, Acquisition),
                              adma(m))
    r

end

function boardhandle(sysid::Integer,boardid::Integer)
    r = AlazarGetBoardBySystemID(sysid,boardid)
    r == C_NULL && error("Not found: system ID $sysid, board ID $boardid")
    r
end

boardkind(handle::U32) = AlazarGetBoardKind(handle)

busy(a::InstrumentAlazar) = AlazarBusy(a.handle) > 0 ? true : false
#@doc "Determine if an acquisition to on-board memory is in progress."

@eh forcetrigger(a::InstrumentAlazar) = AlazarForceTrigger(a.handle)
#@doc "Generate a software trigger event." forcetrigger

@eh forcetriggerenable(a::InstrumentAlazar) = AlazarForceTriggerEnable(a.handle)
#@doc "Generate a software trigger enable event." forcetriggerenable

@eh inputcontrol(a::InstrumentAlazar, channel, coupling, inputRange, impedance) =
    AlazarInputControl(a.handle, channel, coupling, inputRange, impedance)
#@doc "Configures one input channel on a board." inputcontrol

@eh post_async_buffer(a::InstrumentAlazar, buffer, bufferLength) =
    AlazarPostAsyncBuffer(a.handle, buffer, bufferLength)
#@doc "Posts a DMA buffer to a board." post_async_buffer

@eh set_parameter(a::InstrumentAlazar, channelId, parameterId, value) =
    AlazarSetParameter(a.handle, channelId, parameterId, value)

@eh set_parameter_ul(a::InstrumentAlazar, channelId, parameterId, value) =
    AlazarSetParameterUL(a.handle, channelId, parameterId, value)

function set_triggeroperation(a::InstrumentAlazar, args...)
    if length(args) != 7
        error("Need 7 arguments beside the instrument: operation, source1, ",
            "slope1, level1, source2, slope2, level2.")
    end
    r = @eh2 AlazarSetTriggerOperation(a.handle, args[1], Alazar.TRIG_ENGINE_J,
            args[2:4]..., Alazar.TRIG_ENGINE_K, args[5:7]...)
    (a.triggerOperation,
        a.triggerJChannel, a.triggerJSlope, a.triggerJLevel,
        a.triggerKChannel, a.triggerKSlope, a.triggerKLevel) = (args...)
    r
end
#@doc "Set trigger operation." set_triggeroperation

@eh startcapture(a::InstrumentAlazar) = AlazarStartCapture(a.handle)
@doc "Starts the acquisition." startcapture

@eh triggered(a::InstrumentAlazar) = AlazarTriggered(a.handle)
@doc "Determine if a board has triggered during the current acquisition." triggered

@eh wait_async_buffer(a::InstrumentAlazar, buffer, timeout_ms) =
    AlazarWaitAsyncBufferComplete(a.handle, buffer, timeout_ms)
@doc "Blocks until the board confirms that buffer is filled with data." wait_async_buffer

"""
ATS9360 is a concrete subtype of InstrumentAlazar.
"""
type AlazarATS9360 <: InstrumentAlazar

    systemId::Culong
    boardId::Culong
    handle::Culong

    clockSource::U32
    sampleRate::U32
    clockSlope::U32
    decimation::U32

    coupling::U32
    triggerRange::U32

    triggerOperation::U32
    triggerJChannel::U32
    triggerJSlope::U32
    triggerJLevel::U32
    triggerKChannel::U32
    triggerKSlope::U32
    triggerKLevel::U32

    triggerDelaySamples::U32
    triggerTimeoutTicks::U32

    auxIOMode::U32
    auxParam::U32

    acquisitionChannel::U32
    channelCount::U32

    packingA::Clong
    packingB::Clong

    dspModules::Array{DSPModule,1}

    preTriggerSamples::U32
    postTriggerSamples::U32

    bufferCount::U32
    bufferSize::U32

    # defaults
    inputcontrol_defaults(a::AlazarATS9360) = begin
        invoke(inputcontrol,(InstrumentAlazar,Any,Any,Any,Any), a,
            Alazar.CHANNEL_A, Alazar.DC_COUPLING,
            Alazar.INPUT_RANGE_PM_400_MV, Alazar.IMPEDANCE_50_OHM)
        invoke(inputcontrol,(InstrumentAlazar,Any,Any,Any,Any), a,
            Alazar.CHANNEL_B, Alazar.DC_COUPLING,
            Alazar.INPUT_RANGE_PM_400_MV, Alazar.IMPEDANCE_50_OHM)
        # There are no internal variables in the AlazarATS9360 type because these are
        # the only possible options for this particular instrument!
    end

    captureclock_defaults(a::AlazarATS9360) = begin
        a.clockSource = Alazar.INTERNAL_CLOCK
        a.sampleRate = Alazar.SAMPLE_RATE_1000MSPS
        a.clockSlope = Alazar.CLOCK_EDGE_RISING
        a.decimation = 0
        @eh2 AlazarSetCaptureClock(a.handle,
            a.clockSource, a.sampleRate, a.clockSlope, a.decimation)
    end

    externaltrigger_defaults(a::AlazarATS9360) = begin
        a.coupling = Alazar.DC_COUPLING
        a.triggerRange = Alazar.ETR_5V
        @eh2 AlazarSetExternalTrigger(a.handle, a.coupling, a.triggerRange)
    end

    dsp_populate(a::AlazarATS9360) = begin
        dspModuleHandles = dsp_getmodulehandles(a)
        a.dspModules = map(x->DSPModule(a,x),dspModuleHandles)
    end

    # Ideal buffer size in bytes. Should be fixed to optimize performance for a
    # given Alazar digitizer (and possibly motherboard?). The way we do things,
    # it should also be divisible by channelcount and bytespersample.
    buffer_defaults(a::AlazarATS9360) = begin
        a.bufferSize = inspect(a,DefaultBufferSize)
        a.bufferCount = inspect(a,DefaultBufferCount)
    end

    AlazarATS9360() = AlazarATS9360(1,1)
    AlazarATS9360(a,b) = begin
        handle = boardhandle(a,b)
        if (handle == 0)
            error("Board $a.$b not found.")
        end

        btype = boardkind(handle)
        if (btype != Alazar.ATS9360)
            error("Board at $a.$b is not an ATS9360.")
        end

        at = new()
        at.systemId = a
        at.boardId = b
        at.handle = handle

        inputcontrol_defaults(at)
        captureclock_defaults(at)
        set_triggeroperation(at,
                            Alazar.TRIG_ENGINE_OP_J,
                            Alazar.TRIG_CHAN_A,
                            Alazar.TRIGGER_SLOPE_POSITIVE,
                            150,
                            Alazar.TRIG_DISABLE,
                            Alazar.TRIGGER_SLOPE_POSITIVE,
                            128)
        externaltrigger_defaults(at)
        configure(at, TriggerDelaySamples, 0) #U32(0)
        configure(at, TriggerTimeoutTicks, 0) #U32(0)

        configure(at, AuxOutputTrigger)
        # configure(at, AlazarDataPacking, Pack12Bits, BothChannels)

        configure(at, BothChannels)
        pre_sam_per_rec = 0
        post_sam_per_rec = 0
        dsp_populate(at)
        buffer_defaults(at)
        return at
    end
end

Base.show(io::IO, ins::InstrumentAlazar) = begin
    println(io, "ATS9360:")
    println(io, "  SystemId $(ins.systemId)")
    println(io, "  BoardId $(ins.boardId)")
end

abstract AlazarATS9440 <: InstrumentAlazar
function configure{S<:AlazarLSB, T<:AlazarLSB}(a::AlazarATS9440,
        lsb0::Type{S}, lsb1::Type{T})
    (lsb1 == AlazarLSB || lsb0 == AlazarLSB) && error("Choose a subtype of AlazarLSB.")
    val0 = code(lsb0(a))
    val1 = code(lsb1(a))
    r = @eh2 AlazarConfigureLSB(a.handle, val0, val1)
    a.lsb0 = val0
    a.lsb1 = val1
    r
end

inspect(a::InstrumentAlazar, ::Type{SampleMemoryPerChannel}) = begin
    memorysize_samples = Array{U32}(1)
    memorysize_samples[1] = U32(0)

    bitspersample = Array{U8}(1)
    bitspersample[1] = U8(0)

    @eh2 AlazarGetChannelInfo(a.handle, memorysize_samples, bitspersample)

    return memorysize_samples[1]
end

function inspect_per{S<:PerProperty, T<:PerProperty}(
        a::InstrumentAlazar, ::Type{S}, ::Type{T})
    error("inspect_per not implemented for this pair.")
end

function inspect_per{S<:PerProperty, T<:PerProperty}(
        a::InstrumentAlazar, mode::AlazarMode, ::Type{S}, ::Type{T})
    error("inspect_per not implemented for this pair.")
end

inspect_per(a::InstrumentAlazar, ::Type{Bit}, ::Type{Sample}) = begin
    memorysize_samples = Array{U32}(1)
    memorysize_samples[1] = U32(0)

    bitspersample = Array{U8}(1)
    bitspersample[1] = U8(0)

    @eh2 AlazarGetChannelInfo(a.handle, memorysize_samples, bitspersample)

    return bitspersample[1]
end

# not supported by ATS310, 330, 850.
function configure{T<:AlazarTimestampReset}(a::InstrumentAlazar, t::Type{T})
    (t == AlazarTimestampReset) && error("Choose TimestampResetOnce or ...Always")
    option = code(t(a))
    @eh2 AlazarResetTimeStamp(a.handle, option)
end

function configure{T<:Coupling}(a::InstrumentAlazar, coupling::Type{T})
    coup = code(coupling(a))
    @eh2 AlazarSetExternalTrigger(a.handle, coup, a.triggerRange)
end

function configure{T<:AlazarTriggerRange}(a::InstrumentAlazar, range::Type{T}...)
    rang = code(range(a))
    @eh2 AlazarSetExternalTrigger(a.handle, a.coupling, rang)
end

@eh configure(a::InstrumentAlazar, ::Type{LED}, ledState::Bool) = AlazarSetLED(a.handle, ledState)

function inspect{T<:AlazarChannel}(a::InstrumentAlazar, ::Type{AlazarDataPacking}, ch::Type{T})
    ch == AlazarChannel && error("Specify a particular channel.")

    arr = Array{Clong}(1)
    arr[1] = Clong(0)

    r = @eh2 AlazarGetParameter(a.handle, code(ch(a)), Alazar.PACK_MODE, arr)
    AlazarDataPacking(a,arr[1])
end

configure(a::InstrumentAlazar, ::Type{RecordCount}, count) =
    @eh2 AlazarSetRecordCount(a.handle, count)

function configure(a::InstrumentAlazar, m::RecordMode)

    nearest = max(cld(m.sam_per_rec, 128) * 128, 256)
    if nearest != m.sam_per_rec
        m.sam_per_rec = nearest
        warning("Adjusted samples per record to $nearest.")
    end

    r = AlazarSetRecordSize(a.handle, 0, m.sam_per_rec)
    if r != alazar_no_error
        throw(InstrumentException(a,r))
    else
        a.preTriggerSamples = 0
        a.postTriggerSamples = m.sam_per_rec
    end

    before_async_read(a, m)
end

function configure(a::InstrumentAlazar, m::TraditionalRecordMode)

    pre_nearest  = cld(m.pre_sam_per_rec,  128) * 128
    post_nearest = cld(m.post_sam_per_rec, 128) * 128

    if pre_nearest != m.pre_sam_per_rec
        warning("Adjusted pretrigger samples per record to $pre_nearest.")
        m.pre_sam_per_rec = pre_nearest
    end
    if post_nearest != m.post_sam_per_rec
        warning("Adjusted pretrigger samples per record to $post_nearest.")
        m.post_sam_per_rec = post_nearest
    end

    r = AlazarSetRecordSize(a.handle, m.pre_sam_pre_rec, m.post_sam_per_rec)
    if r != alazar_no_error
        throw(InstrumentException(a,r))
    else
        a.preTriggerSamples = m.pre_sam_pre_rec
        a.postTriggerSamples = m.post_sam_per_rec
    end

    before_async_read(a, m)
end

# In streaming mode we don't need to do anything.
function configure(a::InstrumentAlazar, m::StreamMode)
    before_async_read(a,m)
end

function configure(a::InstrumentAlazar, ::Type{TriggerDelaySamples}, delay_samples)
    r = @eh2 AlazarSetTriggerDelay(a.handle, delay_samples)
    a.triggerDelaySamples = delay_samples
    r
end

function configure(a::InstrumentAlazar, ::Type{TriggerTimeoutTicks}, ticks)
    r = @eh2 AlazarSetTriggerTimeOut(a.handle, ticks)
    a.triggerTimeoutTicks = ticks
    r
end
#@doc "Configures the trigger timeout in ticks (10 us units). Fractional ticks get rounded up. 0 means wait forever." set_triggertimeout_ticks

function configure(a::InstrumentAlazar, ::Type{TriggerTimeoutS}, timeout_s)
    configure(a, TriggerTimeoutTicks, ceil(timeout_s * 1.e5))
end
#@doc "Configures the trigger timeout in seconds, rounded up to the nearest 10 us. 0 means wait forever." set_triggertimeout_s

@eh configure(a::InstrumentAlazar, ::Type{Sleep}, sleepState) =
    AlazarSleepDevice(a.handle, sleepState)

function inspect(a::AlazarATS9360, ::Type{SampleRate})
    a.sampleRate > 0x80 ? float(a.sampleRate) :
        float(samplerate(typeof(SampleRate(a,a.sampleRate))))
end

# Set by data type
function configure{T<:SampleRate}(a::AlazarATS9360, rate::Type{T})
    rate == SampleRate && error("Choose a sample rate.")

    val = rate(a) |> code

    r = @eh2 AlazarSetCaptureClock(a.handle, Alazar.INTERNAL_CLOCK, val, a.clockSlope, 0)

    a.clockSource = Alazar.INTERNAL_CLOCK
    a.sampleRate = val
    a.decimation = 0
    r
end

function configure(a::AlazarATS9360, ::Type{SampleRate}, rate::Real)

    actualRate = U32(fld(rate,1e6)*1e6)
    if (rate != actualRate)
        warning("Rate must be in increments of 1 MHz. Setting ",actualRate," Hz")
    end

    r = @eh2 AlazarSetCaptureClock(a.handle,
        Alazar.EXTERNAL_CLOCK_10MHz_REF, actualRate, a.clockSlope, 1)

    a.clockSource = Alazar.EXTERNAL_CLOCK_10MHz_REF
    a.sampleRate = actualRate
    a.decimation = 1
    r
end

function configure{T<:ClockSlope}(a::AlazarATS9360, slope::Type{T})
    slope == ClockSlope && error("Choose a clock slope.")

    val = slope(a) |> code

    r = @eh2 AlazarSetCaptureClock(a.handle, a.clockSource, a.sampleRate, val, a.decimation)

    a.clockSlope = val
    r
end

function configure{S<:Union{AuxOutputTrigger,AuxDigitalInput}}(
        a::AlazarATS9360, aux::Type{S})
    val = aux(a) |> code

    r = @eh2 AlazarConfigureAuxIO(a.handle, val, U32(0))
    a.auxIOMode = val
    a.auxParam = U32(0)

    r
end #of module

function configure{T<:AuxInputTriggerEnable}(
        a::AlazarATS9360, aux::Type{T}, trigSlope::U32)
    val = aux(a) |> code

    r = @eh2 AlazarConfigureAuxIO(a.handle, val, trigSlope)
    a.auxIOMode = val
    a.auxParam = trigSlope

    r
end

function configure{S<:AuxInputTriggerEnable, T<:TriggerSlope}(
        a::AlazarATS9360, aux::Type{S}, trigSlope::Type{T})
    val = aux(a) |> code
    val2 = trigSlope(a) |> code

    r = @eh2 AlazarConfigureAuxIO(a.handle, val, val2)
    a.auxIOMode = val
    a.auxParam = val2

    r
end

function configure{T<:AuxOutputPacer}(
        a::AlazarATS9360, aux::Type{T}, divider::Integer)
    val = aux(a) |> code

    r = @eh2 AlazarConfigureAuxIO(a.handle, val, U32(divider))
    a.auxIOMode = val
    a.auxParam = divider

    r
end

function configure{T<:AuxDigitalOutput}(
        a::AlazarATS9360, aux::Type{T}, level::Integer)
    val = aux(a) |> code

    r = @eh2 AlazarConfigureAuxIO(a.handle, val, U32(level))
    a.auxIOMode = val
    a.auxParam = level

    r
end

function configure(a::AlazarATS9360, ::Type{AuxSoftwareTriggerEnabled}, b::Bool)
    if b == true
        r = @eh2 AlazarConfigureAuxIO(a.handle, a.auxIOMode, a.auxParam | Alazar.AUX_OUT_TRIGGER_ENABLE)
        a.auxParam = a.auxParam | Alazar.AUX_OUT_TRIGGER_ENABLE
    else
        r = @eh2 AlazarConfigureAuxIO(a.handle, a.auxIOMode, a.auxParam & ~Alazar.AUX_OUT_TRIGGER_ENABLE)
        a.auxParam = a.auxParam & ~Alazar.AUX_OUT_TRIGGER_ENABLE
    end

    r
end

function configure{S<:AlazarDataPacking}(
        a::InstrumentAlazar, ::Type{AlazarDataPacking},
        pack::Type{S}, ch::Type{ChannelA})

    chcode = Alazar.CHANNEL_A

    pk = code((pack)(a))

    r = @eh2 AlazarSetParameter(a.handle, chcode, Alazar.PACK_MODE, pk)
    a.packingA = pk
    r
end

function configure{S<:AlazarDataPacking}(
        a::InstrumentAlazar, ::Type{AlazarDataPacking},
        pack::Type{S}, ch::Type{ChannelB})

    chcode = Alazar.CHANNEL_B

    pk = code((pack)(a))

    r = @eh2 AlazarSetParameter(a.handle, chcode, Alazar.PACK_MODE, pk)
    a.packingB = pk
    r
end

function configure{S<:AlazarDataPacking}(
        a::InstrumentAlazar, ::Type{AlazarDataPacking},
        pack::Type{S}, ch::Type{BothChannels})

    map((c)->configure(a,AlazarDataPacking,pack,c), (ChannelA, ChannelB))

end

function configure{T<:AlazarChannel}(a::AlazarATS9360, ch::Type{T})
    ch == AlazarChannel && error("You must choose a channel.")
    a.acquisitionChannel = U32((ch)(a) |> code)
    a.channelCount = 1
end

function configure{T<:BothChannels}(a::AlazarATS9360, ch::Type{T})
    a.acquisitionChannel = U32((ch)(a) |> code)
    a.channelCount = 2
end

function inspect(a::AlazarATS9360, ::Type{AlazarChannel})
    AlazarChannel(a,a.acquisitionChannel)
end

# Bytes per sample is set by digitizer hardware.
# We bypass for our ATS9360.
inspect_per(a::InstrumentAlazar, ::Type{Byte}, ::Type{Sample}) =
    Int(cld(inspect_per(a, Bit, Sample), 8))

inspect_per(a::InstrumentAlazar, ::Type{Sample}, ::Type{Byte}) =
    float(1.0 / inspect_per(a, Byte, Sample))

inspect_per(a::AlazarATS9360, ::Type{Byte}, ::Type{Sample}) = 2

inspect(a::InstrumentAlazar, ::Type{BufferSize})  = a.bufferSize
function configure(a::InstrumentAlazar, ::Type{BufferSize}, bufsize::Integer)
    a.bufferSize = U32(bufsize)
end
inspect(a::AlazarATS9360, ::Type{DefaultBufferSize}) = U32(409600*2*2)

inspect(a::InstrumentAlazar, ::Type{BufferCount}) = a.bufferCount
function configure(a::InstrumentAlazar, ::Type{BufferCount}, bufcount::Integer)
    a.bufferCount = U32(bufcount)
end
inspect(a::AlazarATS9360, ::Type{DefaultBufferCount}) = U32(4)

# function bufferarray(a::InstrumentAlazar, n_buf::Integer, size_buf::Integer)
#     buf_array = Array{Alazar.DMABuffer{UInt16},1}()
#
#     for (buf_index = 1:n_buf)
#         push!(buf_array, Alazar.DMABuffer(inspect_per(a, Byte, Sample), size_buf))
#     end
#
#     buf_array
# end

# Since records/buffer is always 1 in stream mode, we fix samples/record:
inspect_per(a::InstrumentAlazar, m::StreamMode,
        ::Type{Sample}, ::Type{Record}) =
    Int(inspect(a, BufferSize) /
        (inspect_per(a, Byte, Sample)))   # <-- removed channelcount

# For record mode, the number of samples per record must be specified.
inspect_per(a::AlazarATS9360, m::RecordMode, ::Type{Sample}, ::Type{Record}) =
    m.sam_per_rec

inspect_per(a::AlazarATS9360, m::TraditionalRecordMode,
    ::Type{Sample}, ::Type{Record}) = m.pre_sam_per_rec + m.post_sam_per_rec

# For any Alazar digitizer in stream mode, records per buffer should be 1.
inspect_per(a::InstrumentAlazar, m::StreamMode,
    ::Type{Record}, ::Type{Buffer}) = 1

# For record mode, the number of records per buffer is fixed based on the
# desired buffer size and samples per record.
inspect_per(a::AlazarATS9360, m::RecordMode, ::Type{Record}, ::Type{Buffer}) =
    Int(fld(inspect(a, BufferSize),
        inspect_per(a, m, Sample, Record) * inspect_per(a, Byte, Sample))) # <-- removed channel count

# Pretty straightforward...
inspect_per(a::InstrumentAlazar, m::AlazarMode, ::Type{Sample}, ::Type{Buffer}) =
    inspect_per(a, m, Sample, Record) * inspect_per(a, m, Record, Buffer)

# Parameter is ignored in stream mode for any Alazar digitizer.
inspect_per(::StreamMode, ::Type{Record}, ::Type{Acquisition}) = inf_records
inspect_per(a::InstrumentAlazar, m::StreamMode,
    ::Type{Record}, ::Type{Acquisition}) = inspect_per(m, Record, Acquisition)

# Pass 0x7FFFFFFF for indefinite acquisition count.
inspect_per(m::RecordMode, ::Type{Record}, ::Type{Acquisition}) = m.total_recs
inspect_per(a::InstrumentAlazar, m::RecordMode,
    ::Type{Record}, ::Type{Acquisition}) = inspect_per(m, Record, Acquisition)

inspect_per(a::AlazarATS9360, m::StreamMode, ::Type{Buffer}, ::Type{Acquisition}) =
    Int(cld(m.total_samples, inspect_per(a, m, Sample, Buffer)))
    # Int(cld(m.total_acq_time_s * inspect(a, SampleRate),
    #     inspect_per(a, m, Sample, Buffer)))

inspect_per(a::AlazarATS9360, m::RecordMode, ::Type{Buffer}, ::Type{Acquisition}) =
    Int(cld(m.total_recs, inspect_per(a, m, Record, Buffer)))

inspect(a::InstrumentAlazar, ::Type{ChannelCount}) = a.channelCount

adma(::ContinuousStreamMode)   = Alazar.ADMA_CONTINUOUS_MODE |
                                 Alazar.ADMA_FIFO_ONLY_STREAMING |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::TriggeredStreamMode)    = Alazar.ADMA_TRIGGERED_STREAMING |
                                 Alazar.ADMA_FIFO_ONLY_STREAMING |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::NPTRecordMode)          = Alazar.ADMA_NPT |
                                 Alazar.ADMA_FIFO_ONLY_STREAMING |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::FFTRecordMode)          = Alazar.ADMA_NPT |
                                 Alazar.ADMA_DSP |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::TraditionalRecordMode)  = Alazar.ADMA_TRADITIONAL_MODE |
                                 Alazar.ADMA_EXTERNAL_STARTCAPTURE   # other flags?

pretriggersamples(m::TraditionalRecordMode) = m.pre_sam_per_rec
pretriggersamples(m::AlazarMode) = 0

inspect(a::AlazarATS9360, ::Type{MinSamplesPerRecord}) = 256
inspect(a::AlazarATS9360, ::Type{MaxBufferSize}) = 64*1024*1024      # 64 MB

include("AlazarDSP.jl")

end
