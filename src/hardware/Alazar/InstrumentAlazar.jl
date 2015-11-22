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

importall PainterQB
include("../../Metaprogramming.jl")

# Machine specific
const maxThroughputGBs = 175e7 #18e8

# Play nice with Instruments
export   AlazarAux, AlazarDataPacking, AlazarChannel
abstract AlazarAux         <: InstrumentCode
abstract AlazarDataPacking <: InstrumentCode
abstract AlazarChannel     <: InstrumentCode

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

# Create all the concrete types we need using the createCodeType function.
for ((subtypeSymb,supertype) in subtypesArray)
    createCodeType(subtypeSymb, supertype)
end

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
export InstrumentAlazar

"""
Type to link a `dsp_module_handle` with the `InstrumentAlazar` it came from.
"""
type DSPModule
    ins::InstrumentAlazar
    handle::dsp_module_handle
end
export DSPModule

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

export abort_async_read, abortcapture, before_async_read, boards_in_system
export busy_ins, configure_aux_io, configure_lsb, configurerecordaverage
export forcetrigger, forcetriggerenable, getchannelinfo, inputcontrol
export num_systems, post_async_buffer, read_ins, read_ex_ins, resettimestamp
export set_bw_limit, setcaptureclock, setexternalclocklevel, setexternaltrigger
export set_led, setparameter, setparameter_ul, setrecordcount, setrecordsize
export settriggerdelay_samples, settriggeroperation, settriggertimeout_s
export settriggertimeout_ticks, sleep_ins, startcapture, triggered
export wait_async_buffer

@eh abort_async_read(a::InstrumentAlazar) = AlazarAbortAsyncRead(a.handle)
#@doc "Cancels any asynchronous acquisition running on a board." abort_async_read

@eh abortcapture(a::InstrumentAlazar) = AlazarAbortCapture(a.handle)
#@doc "Abort an acquisition to on-board memory." abortcapture

@eh before_async_read(a::InstrumentAlazar, channels, transferOffset,
        samplesPerRecord, recordsPerBuffer, recordsPerAcquisition, flags) =
    AlazarBeforeAsyncRead(a.handle, channels, transferOffset,
        samplesPerRecord, recordsPerBuffer, recordsPerAcquisition, flags)
#@doc "Prepares the board for an asynchronous acquisition." before_async_read

@eh boards_in_system(sid::Integer) = AlazarBoardsInSystemBySystemID(sid)
#@doc "Queries the number of boards in the system?" boards_in_system

busy_ins(a::InstrumentAlazar) = AlazarBusy(a.handle) > 0 ? true : false
#@doc "Determine if an acquisition to on-board memory is in progress." busy_ins

@eh configure_aux_io(a::InstrumentAlazar, mode, parameter) =
    AlazarConfigureAuxIO(a.handle, mode, parameter)
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

@eh read_ins(a::InstrumentAlazar, channelId, buffer, elementSize,
        record, transferOffset, transferLength) =
    AlazarRead(a.handle, channelId, buffer, elementSize,
        record, transferOffset, transferLength)
#@doc "Read all or part of a record from on-board memory." read

@eh read_ex_ins(a::InstrumentAlazar, channelId, buffer, elementSize,
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

@eh setcaptureclock(a::InstrumentAlazar, source, rate, edge, decimation) =
    AlazarSetCaptureClock(a.handle, source, rate, edge, decimation) #int(source), int(rate), int(edge)
#@doc "Configures the board's acquisition clock." setcaptureclock

@eh setexternalclocklevel(a::InstrumentAlazar, level_percent) =
    AlazarSetExternalClockLevel(a.handle, level_percent)
#@doc "Set the external clock comparator level." setexternalclocklevel

@eh setexternaltrigger(a::InstrumentAlazar, coupling, range) =
    AlazarSetExternalTrigger(a.handle, coupling, range)
#@doc "Configure the external trigger." setexternaltrigger

@eh set_led(a::InstrumentAlazar, ledState) = AlazarSetLED(a.handle, ledState)
#@doc "Control LED on a board's mounting bracket." set_led

@eh setparameter(a::InstrumentAlazar, channelId, parameterId, value) =
    AlazarSetParameter(a.handle, channelId, parameterId, value)
#@doc "Set a device parameter as a signed long value." setparameter

@eh setparameter_ul(a::InstrumentAlazar, channelId, parameterId, value) =
    AlazarSetParameterUL(a.handle, channelId, parameterId, value)
#@doc "Set a device parameter as a U32 value." setparameter_ul

@eh setrecordcount(a::InstrumentAlazar, count) =
    AlazarSetRecordCount(a.handle, count)
#@doc "Configure the record count for single ported acquisitions." setrecordcount

@eh setrecordsize(a::InstrumentAlazar, preTriggerSamples, postTriggerSamples) =
    AlazarSetRecordSize(a.handle, preTriggerSamples, postTriggerSamples)
#@doc "Configures the acquisition records size." setrecordsize

@eh settriggerdelay_samples(a::InstrumentAlazar, delay_samples) =
    AlazarSetTriggerDelay(a.handle, delay_samples)
#@doc "Configures the trigger delay in samples." settriggerdelay_samples

@eh settriggeroperation(a::InstrumentAlazar, operation,
        engine1, source1, slope1, level1, engine2, source2, slope2, level2) =
    AlazarSetTriggerOperation(a.handle, operation,
        engine1, source1, slope1, level1, engine2, source2, slope2, level2)
#@doc "Set trigger operation." settriggeroperation

@eh settriggertimeout_ticks(a::InstrumentAlazar, timeout_clocks) =
    AlazarSetTriggerTimeOut(a.handle, timeout_clocks)
#@doc "Configures the trigger timeout in ticks (10 us units). Fractional ticks get rounded up. 0 means wait forever." settriggertimeout_ticks

function settriggertimeout_s(a::InstrumentAlazar, timeout_s)
    settriggertimeout_ticks(a, U32(ceil(timeout_s * 1.e5)))
    a.triggerTimeoutTicks = U32(ceil(timeout_s * 1.e5))
end
#@doc "Configures the trigger timeout in seconds, rounded up to the nearest 10 us. 0 means wait forever." settriggertimeout_s

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

export AlazarATS9360
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

    acquisitionLength::Float64
    acquisitionChannel::U32
    channelCount::U32

    packingA::Clong
    packingB::Clong

    bufferArray::Array{DMABuffer{UInt16},1}

    dspModules::Array{DSPModule,1}

    # defaults
    inputControlDefaults(a::AlazarATS9360) = begin
        invoke(inputcontrol,(InstrumentAlazar,Any,Any,Any,Any), a,
            Alazar.CHANNEL_A, Alazar.DC_COUPLING,
            Alazar.INPUT_RANGE_PM_400_MV, Alazar.IMPEDANCE_50_OHM)
        invoke(inputcontrol,(InstrumentAlazar,Any,Any,Any,Any), a,
            Alazar.CHANNEL_B, Alazar.DC_COUPLING,
            Alazar.INPUT_RANGE_PM_400_MV, Alazar.IMPEDANCE_50_OHM)
        # There are no internal variables in the AlazarATS9360 type because these are
        # the only possible options for this particular instrument!
    end

    captureClockDefaults(a::AlazarATS9360) = begin
        setcaptureclock(a, Alazar.INTERNAL_CLOCK, Alazar.SAMPLE_RATE_1000MSPS,
            Alazar.CLOCK_EDGE_RISING, 0)
        a.clockSource = Alazar.INTERNAL_CLOCK
        a.sampleRate = Alazar.SAMPLE_RATE_1000MSPS
        a.clockSlope = Alazar.CLOCK_EDGE_RISING
        a.decimation = U32(0)
    end

    triggerOperationDefaults(a::AlazarATS9360) = begin
        settriggeroperation(a,
                            Alazar.TRIG_ENGINE_OP_J,
                            Alazar.TRIG_ENGINE_J,
                            Alazar.TRIG_CHAN_A,
                            Alazar.TRIGGER_SLOPE_POSITIVE,
                            150,
                            Alazar.TRIG_ENGINE_K,
                            Alazar.TRIG_DISABLE,
                            Alazar.TRIGGER_SLOPE_POSITIVE,
                            128)
        a.triggerOperation = Alazar.TRIG_ENGINE_OP_J
        a.triggerJChannel  = Alazar.TRIG_CHAN_A
        a.triggerJSlope    = Alazar.TRIGGER_SLOPE_POSITIVE
        a.triggerJLevel    = U32(150)
        a.triggerKChannel  = Alazar.TRIG_DISABLE
        a.triggerKSlope    = Alazar.TRIGGER_SLOPE_POSITIVE
        a.triggerKLevel    = U32(128)
    end

    externalTriggerDefaults(a::AlazarATS9360) = begin
        setexternaltrigger(a, Alazar.DC_COUPLING, Alazar.ETR_5V)
        a.coupling = Alazar.DC_COUPLING
        a.triggerRange = Alazar.ETR_5V
    end

    triggerDelayDefaults(a::AlazarATS9360) = begin
        settriggerdelay_samples(a, U32(0))
        a.triggerDelaySamples = U32(0)
    end

    triggerTimeoutDefaults(a::AlazarATS9360) = settriggertimeout_ticks(a, U32(0))

    auxIODefaults(a::AlazarATS9360) = configure_aux_io(a, Alazar.AUX_OUT_TRIGGER, U32(0))

    # packingDefaults(a::AlazarATS9360) = setDataPacking(a,BothChannels,DefaultPacking)

    acquisitionDefaults(a::AlazarATS9360) = begin
        setacquisitionlength(a,1.0) #1s
        setacquisitionchannel(a,BothChannels)
    end

    populateDSP(a::AlazarATS9360) = begin
        dspModuleHandles = dsp_getmodulehandles(a)
        a.dspModules = map(x->DSPModule(a,x),dspModuleHandles)
    end

    AlazarATS9360() = AlazarATS9360(1,1)
    AlazarATS9360(a,b) = begin
        handle = ccall((:AlazarGetBoardBySystemID,ats),Culong,(Culong,Culong),convert(Culong,a),convert(Culong,b))
        if (handle == 0)
            error("Board $a.$b not found.")
        end
        btype = ccall((:AlazarGetBoardKind,ats),Culong,(Culong,),handle)
        if (btype != Alazar.ATS9360)
            error("Board at $a.$b is not an ATS9360.")
        end
        at = new()
        at.systemId = a
        at.boardId = b
        at.handle = handle
        at.bufferArray = Array{DMABuffer{UInt16},1}()
        inputControlDefaults(at)
        captureClockDefaults(at)
        triggerOperationDefaults(at)
        externalTriggerDefaults(at)
        triggerDelayDefaults(at)
        triggerTimeoutDefaults(at)
        auxIODefaults(at)
        #packingDefaults(at)
        acquisitionDefaults(at)
        populateDSP(at)
        return at
    end
end

Base.show(io::IO, ins::InstrumentAlazar) = begin
    println(io, "ATS9360:")
    println(io, "  SystemId $(ins.systemId)")
    println(io, "  BoardId $(ins.boardId)")
    println(io, "  acquisition length $(ins.acquisitionLength)")
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

    :SampleRate         => Dict(Alazar.SAMPLE_RATE_1KSPS        =>  :Rate1kSps,
                                Alazar.SAMPLE_RATE_2KSPS        =>  :Rate2kSps,
                                Alazar.SAMPLE_RATE_5KSPS        =>  :Rate5kSps,
                                Alazar.SAMPLE_RATE_10KSPS       =>  :Rate10kSps,
                                Alazar.SAMPLE_RATE_20KSPS       =>  :Rate20kSps,
                                Alazar.SAMPLE_RATE_50KSPS       =>  :Rate50kSps,
                                Alazar.SAMPLE_RATE_100KSPS      =>  :Rate100kSps,
                                Alazar.SAMPLE_RATE_200KSPS      =>  :Rate200kSps,
                                Alazar.SAMPLE_RATE_500KSPS      =>  :Rate500kSps,
                                Alazar.SAMPLE_RATE_1MSPS        =>  :Rate1MSps,
                                Alazar.SAMPLE_RATE_2MSPS        =>  :Rate2MSps,
                                Alazar.SAMPLE_RATE_5MSPS        =>  :Rate5MSps,
                                Alazar.SAMPLE_RATE_10MSPS       =>  :Rate10MSps,
                                Alazar.SAMPLE_RATE_20MSPS       =>  :Rate20MSps,
                                Alazar.SAMPLE_RATE_50MSPS       =>  :Rate50MSps,
                                Alazar.SAMPLE_RATE_100MSPS      =>  :Rate100MSps,
                                Alazar.SAMPLE_RATE_200MSPS      =>  :Rate200MSps,
                                Alazar.SAMPLE_RATE_500MSPS      =>  :Rate500MSps,
                                Alazar.SAMPLE_RATE_800MSPS      =>  :Rate800MSps,
                                Alazar.SAMPLE_RATE_1000MSPS     =>  :Rate1000MSps,
                                Alazar.SAMPLE_RATE_1200MSPS     =>  :Rate1200MSps,
                                Alazar.SAMPLE_RATE_1500MSPS     =>  :Rate1500MSps,
                                Alazar.SAMPLE_RATE_1800MSPS     =>  :Rate1800MSps),

    :AlazarChannel      => Dict(Alazar.CHANNEL_A                    =>  :ChannelA,
                                Alazar.CHANNEL_B                    =>  :ChannelB,
                                Alazar.CHANNEL_A | Alazar.CHANNEL_B =>  :BothChannels),

    :AlazarAux          => Dict(Alazar.AUX_OUT_TRIGGER       =>  :AuxOutputTrigger,
                                Alazar.AUX_IN_TRIGGER_ENABLE =>  :AuxInputTriggerEnable,
                                Alazar.AUX_OUT_PACER         =>  :AuxOutputPacer,
                                Alazar.AUX_IN_AUXILIARY      =>  :AuxDigitalInput,
                                Alazar.AUX_OUT_SERIAL_DATA   =>  :AuxDigitalOutput),

    :AlazarDataPacking  => Dict(Alazar.PACK_DEFAULT            => :DefaultPacking,
                                Alazar.PACK_8_BITS_PER_SAMPLE  => :Pack8Bits,
                                Alazar.PACK_12_BITS_PER_SAMPLE => :Pack12Bits)

)

generateResponseHandlers(AlazarATS9360, responses)

Rate1GSps(ins::AlazarATS9360) = Rate1000MSps(ins::AlazarATS9360)
Rate1GSps(ins::AlazarATS9360, state) = Rate1000MSps(ins,state)

# sampleRate(rate::DataType) = begin
#     @assert rate <: InstrumentSampleRate "$rate <: InstrumentSampleRate"
#     sampleRate(rate())
# end
export samplerate
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

function samplerate(a::AlazarATS9360)
    a.sampleRate > 0x80 ? a.sampleRate :
        samplerate(SampleRate(AlazarATS9360,a.sampleRate))::U32
end

export setsamplerate, setclockslope, set_aux_softwaretriggerenabled
export setacquisitionlength, setdatapacking, setacquisitionchannel
export acquisitionlength, samplesperbuffer, channelcount, bytesperbuffer
export samplesperacquisition, bytespersample, buffercount

function input_control(a::AlazarATS9360, x...)
    warning("This function has been no-op'd since there are no choices for the ATS9360.")
end

# Set by data type
function setsamplerate{T<:SampleRate}(a::AlazarATS9360, rate::Type{T})
    val = rate(AlazarATS9360) |> state
    r = setcaptureclock(a, Alazar.INTERNAL_CLOCK, val, a.clockSlope, 0)
    a.clockSource = Alazar.INTERNAL_CLOCK
    a.sampleRate = val
    a.decimation = 0
    r
end

function setsamplerate(a::AlazarATS9360, rate::Real)
    actualRate = U32(fld(rate,1e6)*1e6)
    if (rate != actualRate)
        warning("Rate must be in increments of 1 MHz. Setting ",actualRate," Hz")
    end
    r = setcaptureclock(a, EXTERNAL_CLOCK_10MHz_REF, actualRate, a.clockSlope, 1)
    a.clockSource = EXTERNAL_CLOCK_10MHz_REF
    a.sampleRate = actualRate
    a.decimation = 1
    r
end

function setclockslope{T<:ClockSlope}(a::AlazarATS9360, slope::Type{T})
    val = slope(AlazarATS9360) |> state
    r = setcaptureclock(a, a.clockSource, a.sampleRate, val, a.decimation)
    a.clockSlope = val
    r
end

function configure_aux_io{S<:AuxOutputTrigger,T<:AuxDigitalInput}(
        a::AlazarATS9360, aux::Union{Type{S},Type{T}})
    val = aux(AlazarATS9360) |> state
    r = configure_aux_io(a, val, U32(0))
    a.auxIOMode = val
    a.auxParam = U32(0)
    r
end #of module

function configure_aux_io{T<:AuxInputTriggerEnable}(
        a::AlazarATS9360, aux::Type{T}, trigSlope::U32)
    val = aux(AlazarATS9360) |> state
    r = configure_aux_io(a, val, trigSlope)
    a.auxIOMode = val
    a.auxParam = trigSlope
    r
end

function configure_aux_io{S<:AuxInputTriggerEnable, T<:TriggerSlope}(
        a::AlazarATS9360, aux::Type{S}, trigSlope::Type{T})
    val = aux(AlazarATS9360) |> state
    val2 = trigSlope(AlazarATS9360) |> state
    r = configure_aux_io(a, val, val2)
    a.auxIOMode = val
    a.auxParam = val2
    r
end

function configure_aux_io{T<:AuxOutputPacer}(
        a::AlazarATS9360, aux::Type{T}, divider::Integer)
    val = aux(AlazarATS9360) |> state
    r = configure_aux_io(a, val, U32(divider))
    a.auxIOMode = val
    a.auxParam = divider
    r
end

function configure_aux_io{T<:AuxDigitalOutput}(
        a::AlazarATS9360, aux::Type{T}, level::Integer)
    val = aux(AlazarATS9360) |> state
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

function setacquisitionlength(a::AlazarATS9360, l::Real)
    a.acquisitionLength = convert(Float64,l)
end

acquisitionlength(a::AlazarATS9360) = a.acquisitionLength
bytespersample(a::InstrumentAlazar) = begin
    (a,b) = getchannelinfo(a)
    U32(fld((b + 7), 8))
end
samplesperbuffer(a::AlazarATS9360) = U32(409600)
channelcount(a::AlazarATS9360) = a.channelCount
bytesperbuffer(a::AlazarATS9360) = U32(bytespersample(a) * samplesperbuffer(a) * channelcount(a))
samplesperacquisition(a::AlazarATS9360) = Culonglong(floor(samplerate(a) * acquisitionlength(a) + 0.5))
buffercount(a::AlazarATS9360) = U32(4)

# function setDataPacking(a::AlazarATS9360, ch::DataType, pack::DataType)
#     @assert ch <: AlazarChannel "$ch <: AlazarChannel"
#     setDataPacking(a, (ch)(a), (pack)(a))
# end
#
# function setDataPacking(a::AlazarATS9360, ch::ChannelA, pack::AlazarDataPacking)
#     setParameter(a, ch.state, PACK_MODE, Ref{Clong}(pack.state))
#     a.packingA = pack.state
# end
#
# function setDataPacking(a::AlazarATS9360, ch::ChannelB, pack::AlazarDataPacking)
#     setParameter(a, ch.state, PACK_MODE, Ref{Clong}(pack.state))
#     a.packingB = pack.state
# end
#
# function setDataPacking(a::AlazarATS9360, ch::BothChannels, pack::AlazarDataPacking)
#     setParameter(a, ChannelA(a).state, PACK_MODE, Ref{Clong}(pack.state))
#     a.packingA = pack.state
#     setParameter(a, ChannelB(a).state, PACK_MODE, Ref{Clong}(pack.state))
#     a.packingB = pack.state
# end

function setacquisitionchannel{T<:AlazarChannel}(a::AlazarATS9360, ch::Type{T})
    a.acquisitionChannel = U32((ch)(AlazarATS9360) |> state)
    a.channelCount = 1
end

function setacquisitionchannel{T<:BothChannels}(a::AlazarATS9360, ch::Type{T})
    a.acquisitionChannel = U32((ch)(AlazarATS9360) |> state)
    a.channelCount = 2
end

function acquisitionchannel(a::AlazarATS9360)
    AlazarChannel(a,a.acquisitionChannel)
end

include("AlazarDSP.jl")

end
