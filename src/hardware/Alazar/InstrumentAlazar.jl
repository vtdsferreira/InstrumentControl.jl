"""
Julia interface to the AlazarTech SDK.
Adapted from the C and Python APIs by Andrew Keller (andrew.keller.09@gmail.com)

This module provides a thin wrapper on top of the AlazarTech C
API. All the exported methods directly map to underlying C
functions. Please see the ATS-SDK Guide for detailed specification of
these functions. In addition, this module provides a few classes for
convenience.

Types

InstrumentAlazar: Represents a digitizer. Abstract type.
AlazarATS9360: Concrete type.

DMABuffer: Holds a memory buffer suitable for data transfer with digitizers.
"""

module AlazarModule

using Alazar
import Base: read
importall PainterQB
include("../../Metaprogramming.jl")

# Play nice with Instruments
export AlazarAux, AlazarDataPacking, AlazarChannel

export AlazarMode
export StreamMode, RecordMode
export ContinuousStream, TriggeredStream
export NPTRecord, TraditionalRecord, FFTRecord
export inf_records

export InstrumentAlazar
export AlazarATS9360

export DSPModule

export abort_async_read, abortcapture
export before_async_read, boardkind, boardhandle, boards_in_system, busy
export configure_aux_io, configure_lsb, configurerecordaverage
export forcetrigger, forcetriggerenable, getchannelinfo
export inputcontrol, num_systems, post_async_buffer, read, read_ex
export resettimestamp, set_bw_limit, set_captureclock, set_externalclocklevel
export set_externaltrigger, set_led, set_parameter, set_parameter_ul
export set_recordcount, set_recordsize, set_triggerdelay_samples
export set_triggeroperation, set_triggertimeout_s, set_triggertimeout_ticks
export sleep_ins, startcapture, triggered, wait_async_buffer

export set_samplerate, set_clockslope, set_aux_softwaretriggerenabled
export set_acquisitionlength, set_datapacking, set_acquisitionchannel, acquisitionlength

export samplesperbuffer, samplesperrecord, recordsperbuffer, buffersperacquisition, recordsperacquisition
export channelcount, bytespersample
export bufferarray, buffercount, buffersize, adma, samplerate

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

"""
Type to link a `dsp_module_handle` with the `InstrumentAlazar` it came from.
"""
type DSPModule
    ins::InstrumentAlazar
    handle::dsp_module_handle
end

abstract AlazarAux         <: InstrumentProperty
abstract AlazarDataPacking <: InstrumentProperty
abstract AlazarChannel     <: InstrumentProperty

subtypesArray = [
    (:ChannelA                          , AlazarChannel),
    (:ChannelB                          , AlazarChannel),
    (:BothChannels                      , AlazarChannel),

    (:AuxOutputTrigger                  , AlazarAux),
    (:AuxInputTriggerEnable             , AlazarAux),
    (:AuxOutputPacer                    , AlazarAux),
    (:AuxDigitalInput                   , AlazarAux),
    (:AuxDigitalOutput                  , AlazarAux),

    (:DefaultPacking                    , AlazarDataPacking),
    (:Pack8Bits                         , AlazarDataPacking),
    (:Pack12Bits                        , AlazarDataPacking)

]::Array{Tuple{Symbol,DataType},1}

# Create all the concrete types we need using the generate_properties function.
for ((subtypeSymb,supertype) in subtypesArray)
    generate_properties(subtypeSymb, supertype)
end

responses = Dict(
    :Coupling           => Dict(Alazar.AC_COUPLING              => :AC,
                                Alazar.DC_COUPLING              => :DC),

    :TriggerSlope       => Dict(Alazar.TRIGGER_SLOPE_POSITIVE   => :RisingTrigger,
                                Alazar.TRIGGER_SLOPE_NEGATIVE   => :FallingTrigger),

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

    :AlazarChannel      => Dict(Alazar.CHANNEL_A                    => :ChannelA,
                                Alazar.CHANNEL_B                    => :ChannelB,
                                Alazar.CHANNEL_A | Alazar.CHANNEL_B => :BothChannels),

    :AlazarAux          => Dict(Alazar.AUX_OUT_TRIGGER       =>  :AuxOutputTrigger,
                                Alazar.AUX_IN_TRIGGER_ENABLE =>  :AuxInputTriggerEnable,
                                Alazar.AUX_OUT_PACER         =>  :AuxOutputPacer,
                                Alazar.AUX_IN_AUXILIARY      =>  :AuxDigitalInput,
                                Alazar.AUX_OUT_SERIAL_DATA   =>  :AuxDigitalOutput),

    :AlazarDataPacking  => Dict(Alazar.PACK_DEFAULT            => :DefaultPacking,
                                Alazar.PACK_8_BITS_PER_SAMPLE  => :Pack8Bits,
                                Alazar.PACK_12_BITS_PER_SAMPLE => :Pack12Bits)

)

generate_handlers(InstrumentAlazar, responses)

Rate1GSps{T<:InstrumentAlazar}(insType::Type{T}) = Rate1000MSps(insType)
#Rate1GSps{T<:InstrumentAlazar}(insType::Type{T}, code) = Rate1000MSps(insType,code)

# sampleRate(rate::DataType) = begin
#     @assert rate <: InstrumentSampleRate "$rate <: InstrumentSampleRate"
#     sampleRate(rate())
# end
samplerate{T<:Rate1kSps}(::Type{T})    = 1e3 |> U32
samplerate{T<:Rate2kSps}(::Type{T})    = 2e3 |> U32
samplerate{T<:Rate5kSps}(::Type{T})    = 5e3 |> U32
samplerate{T<:Rate10kSps}(::Type{T})   = 1e4 |> U32
samplerate{T<:Rate20kSps}(::Type{T})   = 2e4 |> U32
samplerate{T<:Rate50kSps}(::Type{T})   = 5e4 |> U32
samplerate{T<:Rate100kSps}(::Type{T})  = 1e5 |> U32
samplerate{T<:Rate200kSps}(::Type{T})  = 2e5 |> U32
samplerate{T<:Rate500kSps}(::Type{T})  = 5e5 |> U32
samplerate{T<:Rate1MSps}(::Type{T})    = 1e6 |> U32
samplerate{T<:Rate2MSps}(::Type{T})    = 2e6 |> U32
samplerate{T<:Rate5MSps}(::Type{T})    = 5e6 |> U32
samplerate{T<:Rate10MSps}(::Type{T})   = 1e7 |> U32
samplerate{T<:Rate20MSps}(::Type{T})   = 2e7 |> U32
samplerate{T<:Rate50MSps}(::Type{T})   = 5e7 |> U32
samplerate{T<:Rate100MSps}(::Type{T})  = 1e8 |> U32
samplerate{T<:Rate200MSps}(::Type{T})  = 2e8 |> U32
samplerate{T<:Rate500MSps}(::Type{T})  = 5e8 |> U32
samplerate{T<:Rate800MSps}(::Type{T})  = 8e8 |> U32
samplerate{T<:Rate1000MSps}(::Type{T}) = 1e9 |> U32
samplerate{T<:Rate1200MSps}(::Type{T}) = 12e8 |> U32
samplerate{T<:Rate1500MSps}(::Type{T}) = 15e8 |> U32
samplerate{T<:Rate1800MSps}(::Type{T}) = 18e8 |> U32


abstract AlazarMode
abstract StreamMode <: AlazarMode
abstract RecordMode <: AlazarMode

const inf_records = U32(0x7FFFFFFF)

type ContinuousStream <: StreamMode
    total_acq_time_s::AbstractFloat
end

type TriggeredStream <: StreamMode
    total_acq_time_s::AbstractFloat
end

type NPTRecord <: RecordMode
    sam_per_rec::Integer
    total_recs::Integer
end

type TraditionalRecord <: RecordMode
    pre_sam_per_rec::Integer
    post_sam_per_rec::Integer
    total_recs::Integer
end

type FFTRecord <: RecordMode
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

@eh abort_async_read(a::InstrumentAlazar) = AlazarAbortAsyncRead(a.handle)
#@doc "Cancels any asynchronous acquisition running on a board." abort_async_read

@eh abortcapture(a::InstrumentAlazar) = AlazarAbortCapture(a.handle)
#@doc "Abort an acquisition to on-board memory." abortcapture

function before_async_read(a::InstrumentAlazar, m::AlazarMode)

    r = AlazarBeforeAsyncRead(a.handle,
                              a.acquisitionChannel,
                              -pretriggersamples(m),
                              samplesperrecord(a,m),
                              recordsperbuffer(a,m),
                              recordsperacquisition(a,m),
                              adma(m))
    if r != alazar_no_error
        throw(InstrumentException(a,r))
    end

end
#@doc "Prepares the board for an asynchronous acquisition." before_async_read

function boardhandle(sysid::Integer,boardid::Integer)
    r = AlazarGetBoardBySystemID(sysid,boardid)
    r == C_NULL && error("Not found: system ID $sysid, board ID $boardid")
    r
end

boardkind(handle::U32) = AlazarGetBoardKind(handle)

@eh boards_in_system(sid::Integer) = AlazarBoardsInSystemBySystemID(sid)
#@doc "Queries the number of boards in the system?" boards_in_system

busy_ins(a::InstrumentAlazar) = AlazarBusy(a.handle) > 0 ? true : false
#@doc "Determine if an acquisition to on-board memory is in progress." busy_ins

function configure_aux_io(a::InstrumentAlazar, mode, parameter)
    r = AlazarConfigureAuxIO(a.handle, mode, parameter)
    if r != alazar_no_error
        throw(InstrumentException(a,r))
    else
        a.auxIOMode = mode
        a.auxParam = parameter
    end
    r
end

#@doc "Configures the auxiliary output." configure_aux_io

@eh configure_lsb(a::InstrumentAlazar, valueLSB0, valueLSB1) =
    AlazarConfigureLSB(a.handle, valueLSB0, valueLSB1)
#@doc "Change unused bits to digital outputs." configure_lsb

@eh configurerecordaverage(a::InstrumentAlazar, mode, samplesPerRecord,
        recordsPerAverage, options) =
    AlazarConfigureRecordAverage(a.handle, mode, samplesPerRecord,
        recordsPerAverage, options)
#@doc "Co-add ADC samples into accumulator record." configurerecordaverage

@eh forcetrigger(a::InstrumentAlazar) = AlazarForceTrigger(a.handle)
#@doc "Generate a software trigger event." forcetrigger

@eh forcetriggerenable(a::InstrumentAlazar) = AlazarForceTriggerEnable(a.handle)
#@doc "Generate a software trigger enable event." forcetriggerenable

"Get the on-board memory in samples per channel and sample size in bits per sample."
getchannelinfo(a::InstrumentAlazar) = begin
    memorysize_samples = Array{U32}(1)
    memorysize_samples[1] = U32(0)
    bitspersample = Array{U8}(1)
    bitspersample[1] = U8(0)
    r = AlazarGetChannelInfo(a.handle, memorysize_samples, bitspersample)
    if (r != alazar_no_error)
        throw(InstrumentException(a,r))
    end
    return (memorysize_samples[1], bitspersample[1])
end

@eh inputcontrol(a::InstrumentAlazar, channel, coupling, inputRange, impedance) =
    AlazarInputControl(a.handle, channel, coupling, inputRange, impedance)
#@doc "Configures one input channel on a board." inputcontrol

num_systems() = AlazarNumOfSystems()
#@doc "Returns the number of board systems installed." num_systems

@eh post_async_buffer(a::InstrumentAlazar, buffer, bufferLength) =
    AlazarPostAsyncBuffer(a.handle, buffer, bufferLength)
#@doc "Posts a DMA buffer to a board." post_async_buffer

@eh read(a::InstrumentAlazar, channelId, buffer, elementSize,
        record, transferOffset, transferLength) =
    AlazarRead(a.handle, channelId, buffer, elementSize,
        record, transferOffset, transferLength)
#@doc "Read all or part of a record from on-board memory." read

@eh read_ex(a::InstrumentAlazar, channelId, buffer, elementSize,
        record, transferOffset, transferLength) =
    AlazarReadEx(a.handle, channelId, buffer, elementSize,
        record, transferOffset, transferLength)
#@doc "Read all or part of a record from on-board memory." read_ex_ins

@eh resettimestamp(a::InstrumentAlazar, option) =
    AlazarResetTimeStamp(a.handle, option)
#@doc "Control record timestamp counter reset." resettimestamp

@eh set_bw_limit(a::InstrumentAlazar, channel, enable) =
    AlazarSetBWLimit(a.handle, channel, enable)
#@doc "Activates or deactivates the low-pass filter on a given channel." set_bw_limit

function set_captureclock(a::InstrumentAlazar, source, rate, edge, decimation)
    r = AlazarSetCaptureClock(a.handle, source, rate, edge, decimation)
    if r != alazar_no_error
        throw(InstrumentException(a,r))
    else
        a.clockSource = source
        a.sampleRate = rate
        a.clockSlope = edge
        a.decimation = decimation
    end
    r
end
#@doc "Configures the board's acquisition clock." set_captureclock

@eh set_externalclocklevel(a::InstrumentAlazar, level_percent) =
    AlazarSetExternalClockLevel(a.handle, level_percent)
#@doc "Set the external clock comparator level." set_externalclocklevel

function set_externaltrigger(a::InstrumentAlazar, coupling, range)
    r = AlazarSetExternalTrigger(a.handle, coupling, range)
    if r != alazar_no_error
        throw(InstrumentException(a,r))
    else
        a.coupling = coupling
        a.triggerRange = range
    end
    r
end
#@doc "Configure the external trigger." set_externaltrigger

@eh set_led(a::InstrumentAlazar, ledState) = AlazarSetLED(a.handle, ledState)
#@doc "Control LED on a board's mounting bracket." set_led

@eh set_parameter(a::InstrumentAlazar, channelId, parameterId, value) =
    AlazarSetParameter(a.handle, channelId, parameterId, value)
#@doc "Set a device parameter as a signed long value." set_parameter

@eh set_parameter_ul(a::InstrumentAlazar, channelId, parameterId, value) =
    AlazarSetParameterUL(a.handle, channelId, parameterId, value)
#@doc "Set a device parameter as a U32 value." set_parameter_ul

@eh set_recordcount(a::InstrumentAlazar, count) =
    AlazarSetRecordCount(a.handle, count)
#@doc "Configure the record count for single ported acquisitions." set_recordcount

function set_recordsize(a::InstrumentAlazar, m::RecordMode)

    nearest = max(cld(m.sam_per_rec,128)*128,256)
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
    r
end

function set_recordsize(a::InstrumentAlazar, m::TraditionalRecord)

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
    r
end

# In streaming mode we don't need to do anything.
function set_recordsize(a::InstrumentAlazar, m::StreamMode)
    nothing
end
#@doc "Configures the acquisition records size." set_recordsize

function set_triggerdelay_samples(a::InstrumentAlazar, delay_samples)
    r = AlazarSetTriggerDelay(a.handle, delay_samples)
    if r != alazar_no_error
        throw(InstrumentException(a,r))
    else
        a.triggerDelaySamples = delay_samples
    end
    r
end
#@doc "Configures the trigger delay in samples." set_triggerdelay_samples

function set_triggeroperation(a::InstrumentAlazar, args...)
    if length(args) != 7
        error("Need 7 arguments beside the instrument: operation, source1, ",
            "slope1, level1, source2, slope2, level2.")
    end
    r = AlazarSetTriggerOperation(a.handle, args[1], Alazar.TRIG_ENGINE_J,
            args[2:4]..., Alazar.TRIG_ENGINE_K, args[5:7]...)
    if r != alazar_no_error
        throw(InstrumentException(a,r))
    else
        (a.triggerOperation,
            a.triggerJChannel, a.triggerJSlope, a.triggerJLevel,
            a.triggerKChannel, a.triggerKSlope, a.triggerKLevel) = (args...)
    end
    r
end
#@doc "Set trigger operation." set_triggeroperation

function set_triggertimeout_ticks(a::InstrumentAlazar, ticks)
    r = AlazarSetTriggerTimeOut(a.handle, ticks)
    if r != alazar_no_error
        throw(InstrumentException(a,r))
    else
        a.triggerTimeoutTicks = ticks
    end
    r
end
#@doc "Configures the trigger timeout in ticks (10 us units). Fractional ticks get rounded up. 0 means wait forever." set_triggertimeout_ticks

function set_triggertimeout_s(a::InstrumentAlazar, timeout_s)
    set_triggertimeout_ticks(a, ceil(timeout_s * 1.e5))
end
#@doc "Configures the trigger timeout in seconds, rounded up to the nearest 10 us. 0 means wait forever." set_triggertimeout_s

@eh sleep_ins(a::InstrumentAlazar, sleepState) =
    AlazarSleepDevice(a.handle, sleepState)
#@doc "Control power to ADC devices" sleep_ins

@eh startcapture(a::InstrumentAlazar) = AlazarStartCapture(a.handle)
#@doc "Starts the acquisition." startcapture

@eh triggered(a::InstrumentAlazar) = AlazarTriggered(a.handle)
#@doc "Determine if a board has triggered during the current acquisition." triggered

@eh wait_async_buffer(a::InstrumentAlazar, buffer, timeout_ms) =
    AlazarWaitAsyncBufferComplete(a.handle, buffer, timeout_ms)
#@doc "Blocks until the board confirms that buffer is filled with data." wait_async_buffer

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

#    acquisitionLength::Float64
    acquisitionChannel::U32
    channelCount::U32

    packingA::Clong
    packingB::Clong

    # bufferArray::Array{DMABuffer{UInt16},1}

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

    # packingDefaults(a::AlazarATS9360) = setDataPacking(a,BothChannels,DefaultPacking)

    dsp_populate(a::AlazarATS9360) = begin
        dspModuleHandles = dsp_getmodulehandles(a)
        a.dspModules = map(x->DSPModule(a,x),dspModuleHandles)
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
        # at.bufferArray = Array{DMABuffer{UInt16},1}()
        inputcontrol_defaults(at)
        set_captureclock(at, Alazar.INTERNAL_CLOCK, Alazar.SAMPLE_RATE_1000MSPS,
            Alazar.CLOCK_EDGE_RISING, 0)
        set_triggeroperation(at,
                            Alazar.TRIG_ENGINE_OP_J,
                            Alazar.TRIG_CHAN_A,
                            Alazar.TRIGGER_SLOPE_POSITIVE,
                            150,
                            Alazar.TRIG_DISABLE,
                            Alazar.TRIGGER_SLOPE_POSITIVE,
                            128)
        set_externaltrigger(at, Alazar.DC_COUPLING, Alazar.ETR_5V)
        set_triggerdelay_samples(at, U32(0))
        set_triggertimeout_ticks(at, U32(0))
        configure_aux_io(at, Alazar.AUX_OUT_TRIGGER, U32(0))
        #packingDefaults(at)
#        set_acquisitionlength(at,1.0) #1s
        set_acquisitionchannel(at,BothChannels)
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

function samplerate(a::AlazarATS9360)
    a.sampleRate > 0x80 ? a.sampleRate :
        samplerate(SampleRate(a,a.sampleRate))::U32
end

function input_control(a::AlazarATS9360, x...)
    warning("This function has been no-op'd since there are no choices for the ATS9360.")
end

# Set by data type
function set_samplerate{T<:SampleRate}(a::AlazarATS9360, rate::Type{T})
    val = rate(a) |> code
    r = set_captureclock(a, Alazar.INTERNAL_CLOCK, val, a.clockSlope, 0)
    a.clockSource = Alazar.INTERNAL_CLOCK
    a.sampleRate = val
    a.decimation = 0
    r
end

function set_samplerate(a::AlazarATS9360, rate::Real)
    actualRate = U32(fld(rate,1e6)*1e6)
    if (rate != actualRate)
        warning("Rate must be in increments of 1 MHz. Setting ",actualRate," Hz")
    end
    r = set_captureclock(a, EXTERNAL_CLOCK_10MHz_REF, actualRate, a.clockSlope, 1)
    a.clockSource = EXTERNAL_CLOCK_10MHz_REF
    a.sampleRate = actualRate
    a.decimation = 1
    r
end

function set_clockslope{T<:ClockSlope}(a::AlazarATS9360, slope::Type{T})
    val = slope(a) |> code
    r = set_captureclock(a, a.clockSource, a.sampleRate, val, a.decimation)
    a.clockSlope = val
    r
end

function configure_aux_io{S<:AuxOutputTrigger,T<:AuxDigitalInput}(
        a::AlazarATS9360, aux::Union{Type{S},Type{T}})
    val = aux(a) |> code
    r = configure_aux_io(a, val, U32(0))
    a.auxIOMode = val
    a.auxParam = U32(0)
    r
end #of module

function configure_aux_io{T<:AuxInputTriggerEnable}(
        a::AlazarATS9360, aux::Type{T}, trigSlope::U32)
    val = aux(a) |> code
    r = configure_aux_io(a, val, trigSlope)
    a.auxIOMode = val
    a.auxParam = trigSlope
    r
end

function configure_aux_io{S<:AuxInputTriggerEnable, T<:TriggerSlope}(
        a::AlazarATS9360, aux::Type{S}, trigSlope::Type{T})
    val = aux(a) |> code
    val2 = trigSlope(AlazarATS9360) |> code
    r = configure_aux_io(a, val, val2)
    a.auxIOMode = val
    a.auxParam = val2
    r
end

function configure_aux_io{T<:AuxOutputPacer}(
        a::AlazarATS9360, aux::Type{T}, divider::Integer)
    val = aux(a) |> code
    r = configure_aux_io(a, val, U32(divider))
    a.auxIOMode = val
    a.auxParam = divider
    r
end

function configure_aux_io{T<:AuxDigitalOutput}(
        a::AlazarATS9360, aux::Type{T}, level::Integer)
    val = aux(a) |> code
    r = configure_aux_io(a, val, U32(level))
    a.auxIOMode = val
    a.auxParam = level
    r
end

function set_aux_softwaretriggerenabled(a::AlazarATS9360, b::Bool)
    if true
        r = configure_aux_io(a, a.auxIOMode, a.auxParam | Alazar.AUX_OUT_TRIGGER_ENABLE)
        a.auxParam = a.auxParam | Alazar.AUX_OUT_TRIGGER_ENABLE
    else
        r = configure_aux_io(a, a.auxIOMode, a.auxParam & ~Alazar.AUX_OUT_TRIGGER_ENABLE)
        a.auxParam = a.auxParam & ~Alazar.AUX_OUT_TRIGGER_ENABLE
    end
    r
end

# function set_acquisitionlength(a::AlazarATS9360, l::Real)
#     a.acquisitionLength = convert(Float64,l)
# end
#
# acquisitionlength(a::AlazarATS9360) = a.acquisitionLength

# In the following, a "sample" defines to a value from a single channel.
# You need to have memory for two samples if you are measuring both channels.

# Bytes per sample is set by digitizer hardware.
# It can be determined using getchannelinfo but we bypass for our ATS9360.
bytespersample(a::InstrumentAlazar) = cld(getchannelinfo(a)[2], 8)
bytespersample(a::AlazarATS9360)    = 2

# Ideal buffer size in bytes. Should be fixed to optimize performance for a
# given Alazar digitizer (and possibly motherboard?). The way we do things,
# it should also be divisible by channelcount and bytespersample.

buffer_defaults(a::AlazarATS9360) = begin
    a.bufferSize = U32(409600*2*2)
    a.bufferCount = U32(4)
end
buffersize(a::AlazarATS9360) = a.bufferSize
buffercount(a::AlazarATS9360) = a.bufferCount

function bufferarray(a::InstrumentAlazar, n_buf::Integer, size_buf::Integer)
    buf_array = Array{Alazar.DMABuffer{UInt16},1}()

    for (buf_index = 1:n_buf)
        push!(buf_array,Alazar.DMABuffer(bytespersample(a),size_buf))
    end

    buf_array
end

pretriggersamples(m::TraditionalRecord) = m.pre_sam_per_rec
pretriggersamples(m::AlazarMode) = 0

# Since records/buffer is always 1 in stream mode, we fix samples/record:
samplesperrecord(a::InstrumentAlazar, ::StreamMode) =
    U32(buffersize(a) / (channelcount(a) * bytespersample(a)))

# For record mode, the number of samples per record must be specified.
samplesperrecord(a::AlazarATS9360, m::RecordMode) = m.sam_per_rec
samplesperrecord(a::AlazarATS9360, m::TraditionalRecord) =
    m.pre_sam_per_rec + m.post_sam_per_rec

# For any Alazar digitizer in stream mode, records per buffer should be 1.
recordsperbuffer(a::InstrumentAlazar, m::StreamMode) = 1

# For record mode, the number of records per buffer is fixed based on the
# desired buffer size and samples per record.
recordsperbuffer(a::AlazarATS9360, m::RecordMode) =
    fld(buffersize(a),samplesperrecord(a,m)*bytespersample(a)*channelcount(a))

# Pretty straightforward...
samplesperbuffer(a::InstrumentAlazar, m::AlazarMode) =
    samplesperrecord(a,m) * recordsperbuffer(a,m)

# Parameter is ignored in stream mode for any Alazar digitizer.
recordsperacquisition(a::InstrumentAlazar, ::StreamMode) = inf_records

# Pass 0x7FFFFFFF for indefinite acquisition count.
recordsperacquisition(a::AlazarATS9360, m::RecordMode) = m.total_recs

channelcount(a::InstrumentAlazar) = a.channelCount

buffersperacquisition(a::AlazarATS9360, m::StreamMode) =
    Int(cld(m.total_acq_time_s*samplerate(a), samplesperbuffer(a,m)))

buffersperacquisition(a::AlazarATS9360, m::RecordMode) =
    cld(m.total_recs,recordsperbuffer(a,m))

adma(::ContinuousStream)   = Alazar.ADMA_CONTINUOUS_MODE |
                             Alazar.ADMA_FIFO_ONLY_STREAMING |
                             Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::TriggeredStream)   = Alazar.ADMA_TRIGGERED_STREAMING |
                             Alazar.ADMA_FIFO_ONLY_STREAMING |
                             Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::NPTRecord)         = Alazar.ADMA_NPT |
                             Alazar.ADMA_FIFO_ONLY_STREAMING |
                             Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::FFTRecord)          = Alazar.ADMA_NPT |
                             Alazar.ADMA_DSP |
                             Alazar.ADMA_EXTERNAL_STARTCAPTURE

adma(::TraditionalRecord)  = Alazar.ADMA_TRADITIONAL_MODE |
                             Alazar.ADMA_EXTERNAL_STARTCAPTURE # other flags?

# function set_datapacking(a::AlazarATS9360, ch::DataType, pack::DataType)
#     @assert ch <: AlazarChannel "$ch <: AlazarChannel"
#     setDataPacking(a, (ch)(a), (pack)(a))
# end
#
# function set_datapacking(a::AlazarATS9360, ch::ChannelA, pack::AlazarDataPacking)
#     setParameter(a, ch.state, PACK_MODE, Ref{Clong}(pack.state))
#     a.packingA = pack.state
# end
#
# function set_datapacking(a::AlazarATS9360, ch::ChannelB, pack::AlazarDataPacking)
#     setParameter(a, ch.state, PACK_MODE, Ref{Clong}(pack.state))
#     a.packingB = pack.state
# end
#
# function set_datapacking(a::AlazarATS9360, ch::BothChannels, pack::AlazarDataPacking)
#     setParameter(a, ChannelA(a).state, PACK_MODE, Ref{Clong}(pack.state))
#     a.packingA = pack.state
#     setParameter(a, ChannelB(a).state, PACK_MODE, Ref{Clong}(pack.state))
#     a.packingB = pack.state
# end

function set_acquisitionchannel{T<:AlazarChannel}(a::AlazarATS9360, ch::Type{T})
    a.acquisitionChannel = U32((ch)(a) |> code)
    a.channelCount = 1
end

function set_acquisitionchannel{T<:BothChannels}(a::AlazarATS9360, ch::Type{T})
    a.acquisitionChannel = U32((ch)(a) |> code)
    a.channelCount = 2
end

function acquisitionchannel(a::AlazarATS9360)
    AlazarChannel(a,a.acquisitionChannel)
end

include("AlazarDSP.jl")

end
