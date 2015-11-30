### Tektronix AWG5014C
module AWG5014CModule

## Import packages
import VISA

## Import our modules
importall PainterQB                 # All the stuff in InstrumentDefs, etc.
include("../Metaprogramming.jl")

## Exports
export AWG5014C

export allWaveforms

export AWG5014CData

export Normalization, SequencerType, WaveformType

export Amplitude
export AnalogOutputDelay
export ChannelOutput
export DCOutput
export DCOutputLevel
export ExtInputAddsToOutput
export ExtOscDividerRate
export MarkerDelay
export OutputFilterFrequency
export RefOscFrequency
export RefOscMultiplier
export RepRate
export RepRateHeld
export SCPIVersion
export SequencerEventJumpTarget
export SequencerGOTOTarget
export SequencerGOTOState
export SequencerInfiniteLoop
export SequencerLength
export SequencerLoopCount
export SequencerPosition
export TriggerLevel
export TriggerTimer
export WavelistLength
export VoltageOffset

export runapplication, applicationstate, validate
export load_awg_settings, save_awg_settings
export clearwaveforms, deletewaveform, newwaveform
export normalizewaveform, resamplewaveform
export waveformexists, waveformispredefined
export waveformlength, waveformname, waveformtimestamp, waveformtype
export pullfrom_awg, pushto_awg

export @allch

# We also export from the generate_properties statement.

const allWaveforms      = ASCIIString("ALL")

# Maximum number of bytes that may be sent using WLIS:WAV:DATA
const byteLimit         = 65e7

# IntWaveform values.
const minimumValue      = 0x0000
const offsetValue       = 0x1fff
const offsetPlusPPOver2 = 0x3ffe
const maximumValue      = 0x3fff

type AWG5014C <: InstrumentVISA
    vi::(VISA.ViSession)
    writeTerminator::ASCIIString
    model::AbstractString
    # wavelistArray::Array{ASCIIString,1}

    AWG5014C(x) = begin
        ins = new()
        ins.vi = x
        ins.writeTerminator = "\n"
        ins.model = "AWG5014C"
        VISA.viSetAttribute(ins.vi, VISA.VI_ATTR_TERMCHAR_EN, UInt64(1))
        ins
    end

    AWG5014C() = new()
end

type AWG5014CData
    data::Array{Float32,1}
    marker1::Array{Bool,1}
    marker2::Array{Bool,1}
end

const noError = 0
exceptions    = Dict(
         0   => "No error.",
        -222 => "Out of range.",
        -224 => "Not a power of 2.",
        -330 => "Diagnostic error.",
        -340 => "Calibration error.")

InstrumentException(ins::AWG5014C, r) = InstrumentException(ins, r, exceptions[r])

abstract Normalization     <: InstrumentProperty
abstract SequencerType     <: InstrumentProperty
abstract WaveformType      <: InstrumentProperty

subtypesArray = [

    (:NotNormalized,        Normalization),
    (:FullScale,            Normalization),
    (:PreservingOffset,     Normalization),

    (:HardwareSequencer,    SequencerType),
    (:SoftwareSequencer,    SequencerType),

    (:IntWaveform,          WaveformType),
    (:RealWaveform,         WaveformType),

]::Array{Tuple{Symbol,DataType},1}

# Create all the concrete types we need using the generate_properties function.
for ((subtypeSymb,supertype) in subtypesArray)
    generate_properties(subtypeSymb, supertype)
end

abstract Amplitude                <: InstrumentProperty
abstract AnalogOutputDelay        <: InstrumentProperty
abstract ChannelOutput            <: InstrumentProperty
abstract DCOutput                 <: InstrumentProperty
abstract DCOutputLevel            <: InstrumentProperty
abstract ExtInputAddsToOutput     <: InstrumentProperty
abstract ExtOscDividerRate        <: InstrumentProperty
abstract MarkerDelay              <: InstrumentProperty
abstract OutputFilterFrequency    <: InstrumentProperty
abstract RefOscFrequency          <: InstrumentProperty
abstract RefOscMultiplier         <: InstrumentProperty
abstract RepRate                  <: InstrumentProperty
abstract RepRateHeld              <: InstrumentProperty
abstract SCPIVersion              <: InstrumentProperty
abstract SequencerEventJumpTarget <: InstrumentProperty
abstract SequencerGOTOTarget      <: InstrumentProperty
abstract SequencerGOTOState       <: InstrumentProperty
abstract SequencerInfiniteLoop    <: InstrumentProperty
abstract SequencerLength          <: InstrumentProperty
abstract SequencerLoopCount       <: InstrumentProperty
abstract SequencerPosition        <: InstrumentProperty
abstract TriggerLevel             <: InstrumentProperty
abstract TriggerTimer             <: InstrumentProperty
abstract WavelistLength           <: InstrumentProperty
abstract VoltageOffset            <: InstrumentProperty

responses = Dict(

    :Normalization    => Dict("NONE"  => :NotNormalized,
                              "FSC"   => :NormalizedFullScale,
                              "ZREF"  => :NormalizedPreservingOffset),

    :SequencerType    => Dict("HARD"  => :HardwareSequencer,
                              "SOFT"  => :SoftwareSequencer),

    :WaveformType     => Dict("INT"   => :IntWaveform,
                              "REAL"  => :RealWaveform),

########

    :ClockSlope       => Dict("POS"   => :RisingClock,
                              "NEG"   => :FallingClock),

    :ClockSource      => Dict("INT"   => :InternalClock,
                              "EXT"   => :ExternalClock),

    :EventImpedance   => Dict(  50.0  => :Event50Ohms,
                              1000.0  => :Event1kOhms),

    :EventSlope       => Dict("POS"   => :RisingEvent,
                              "NEG"   => :FallingEvent),

    :EventTiming      => Dict("SYNC"  => :EventSynchronous,
                              "ASYN"  => :EventAsynchronous),

    :OscillatorSource => Dict("INT"   => :InternalOscillator,
                              "EXT"   => :ExternalOscillator),

    :Trigger          => Dict("TRIG"  => :Triggered,
                              "CONT"  => :Continuous,
                              "GAT"   => :Gated,
                              "SEQ"   => :Sequence),

    :TriggerImpedance => Dict(  50.0  => :Trigger50Ohms,
                              1000.0  => :Trigger1kOhms),

    :TriggerSlope     => Dict("POS"   => :RisingTrigger,
                              "NEG"   => :FallingTrigger),

    :TriggerSource    => Dict("INT"   => :InternalTrigger,
                              "EXT"   => :ExternalTrigger),

)

generate_handlers(AWG5014C,responses)

commands = [
    ("AWGC:CLOC:SOUR",      ClockSource), #reference clock source
    ("EVEN:IMP",            EventImpedance),
    ("EVEN:POL",            EventSlope),
    ("EVEN:JTIM",           EventTiming),
    ("SOUR:ROSC:SOUR",      OscillatorSource),
    ("AWGC:RMOD",           Trigger), # run mode
    ("TRIG:IMP",            TriggerImpedance), # event impedance
    ("TRIG:POL",            TriggerSlope),
    ("TRIG:SOUR",           TriggerSource),

    ("TRIG:LEV",            TriggerLevel,              AbstractFloat),
    ("TRIG:TIM",            TriggerTimer,              AbstractFloat),
    ("AWGC:CLOC:DRAT",      ExtOscDividerRate,         Int), # needs error handling?
    ("AWGC:DC:STAT",        DCOutput,                  Bool),
    ("AWGC:DC#:VOLT:OFFS",  DCOutputLevel,             AbstractFloat),
    ("AWGC:RRAT:HOLD",      RepRateHeld,               Bool),
    ("AWGC:RRAT",           RepRate,                   AbstractFloat),
    ("SEQ:LENG",            SequencerLength,           Int),
    ("AWGC:SEQ:POS?",       SequencerPosition,         Int),             ###
    ("SEQ:ELEM#:GOTO:IND",  SequencerGOTOTarget,       Int),
    ("OUTP#:FILT:FREQ",     OutputFilterFrequency,     AbstractFloat),
    ("SEQ:ELEM#:GOTO:STAT", SequencerGOTOState,        Bool),
    ("SEQ:ELEM#:JTAR:IND",  SequencerEventJumpTarget,  Int),
    ("SEQ:ELEM#:LOOP:COUN", SequencerLoopCount,        Int),
    ("SEQ:ELEM#:LOOP:INF",  SequencerInfiniteLoop,     Bool),
    ("SOUR#:COMB:FEED",     ExtInputAddsToOutput,      ASCIIString),    ### ???
    ("SOUR#:DELAY",         AnalogOutputDelay,         AbstractFloat),
#    ("SOUR#:DELAY:POIN",   AnalogOutputDelayPoints,   Int),
    ("SOUR#:MARK#:DEL",     MarkerDelay,               AbstractFloat),
    ("SOUR:ROSC:FREQ",      RefOscFrequency,           AbstractFloat),
    ("SOUR:ROSC:MULT",      RefOscMultiplier,          Int),
    ("SYST:VERS?",          SCPIVersion,               ASCIIString),
    ("AWGC:CONF:CNUM?",     ChannelCount,              Int),
    ("OUTP#:STAT",          ChannelOutput,             Bool),
    ("WLIST:SIZE?",         WavelistLength,            Int),
    ("SOUR#:VOLT:OFFS",     VoltageOffset,             AbstractFloat),  #-2.25 to 2.25V
]

for args in commands
    generate_inspect(AWG5014C,args...)
    args[1][end] != '?' && generate_configure(AWG5014C,args...)
end

function configure(ins::AWG5014C, ::Type{Output}, on::Bool)
    on ? write(ins, "AWGC:RUN") : write(ins, "AWGC:STOP")
end

function inspect(ins::AWG5014C, ::Type{Output})
    parse(ask(ins,"AWGC:RSTATE?")) > 0 ? true : false
end

function inspect(ins::AWG5014C, ::Type{WaitingForTrigger})
    parse(ask(ins,"AWGC:RSTATE?")) == 1 ? true : false
end
#
# sfd = Dict(
#     "calibrate"                         => ["*CAL?",                    InstrumentException],
#     "options"                           => ["*OPT?",                    ASCIIString],
#     "runstate"                          => ["AWGC:RSTATE?",             State],
#
#     # The following two methods may return true if the window *cannot* be displayed.
#     # They return the correct result (false) if the window can be displayed, but is not displayed.
#     "sequencewindowdisplayed"           => ["DISP:WIND1:STAT",          Bool],
#     "waveformwindowdisplayed"           => ["DISP:WIND2:STAT",          Bool],
#     "event_force"                       => ["EVEN",                     NoArgs],
#     "event_level"                       => ["EVEN:LEV",                 AbstractFloat],
#     "sequencer_forcejump"               => ["SEQ:JUMP",                 NoArgs],
#     "waveformloadedinchannel"           => ["SOUR#:FUNC:USER",          ASCIIString],
# )
#
# for (fnName in keys(sfd))
#     createStateFunction(AWG5014C,fnName,sfd[fnName][1],sfd[fnName][2])
# end

# And now, the functions we decided to write by hand...

"""
Macro for performing an operation on every channel,
provided the channel is the last argument of the function to be called.

Example: `@allch setWaveform(awg,"*Sine10")`
"""
macro allch(x::Expr)
    myargs = []

    for ch in 1:4
        n = copy(x)
        push!(n.args,Int(ch))
        push!(myargs,n)
    end

    # esc forces evaluation of the expression in the macro's calling environment.
    esc(Expr(:block,myargs...))
end

"Get the output phase in degrees for a given channel."
function inspect(ins::AWG5014C, ::Type{Phase}, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    parse(ask(ins,string("SOUR",ch,":PHAS?")))
end

"Set the output phase in degrees for a given channel."
function configure(ins::AWG5014C, ::Type{Phase}, phase::Real, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    ph = phase+180.
    ph = mod(ph,360.)
    ph -= 180.
    parse(ask(ins,string("SOUR",ch,":PHAS ",phase)))
end
#
# "Get the output phase in radians for a given channel."
# function phase_rad(ins::AWG5014C, ch::Integer)
#     phaseDegrees(ins,ch) * π / 180.
# end
#
# "Set the output phase in radians for a given channel."
# function set_phase_rad(ins::AWG5014C, phase::Real, ch::Integer)
#     setPhaseDegrees(ins, phase*180./π, ch)
# end

# Set the waveform by name for a given channel.
function configure(ins::AWG5014C, ::Type{WaveformName}, name::ASCIIString, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    write(ins,string("SOUR",ch,":WAV ",quoted(name)))
end

function inspect(ins::AWG5014C, ::Type{WaveformName}, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    unquoted(ask(ins,string("SOUR",ch,":WAV?")))
end

# Set Vpp for a given channel between 0.05 V and 2 V.
function configure(ins::AWG5014C, ::Type{Amplitude}, ampl::Real, ch::Integer)
    @assert (0.05 <= ampl <= 2) "Amplitude out of range."
    @assert (1 <= ch <= 4) "Channel out of range."
    write(ins,string("SOUR",ch,":VOLT ",ampl))
end

# Vpp for a given channel.
function inspect(ins::AWG5014C, ::Type{Amplitude}, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    parse(ask(ins,string("SOUR",ch,":VOLT?")))
end

"Set the sample rate in Hz between 10 MHz and 10 GHz. Output rate = sample rate / number of points."
function configure(ins::AWG5014C, ::Type{SampleRate}, rate::Real)
    @assert (10e6 <= rate <= 10e9) "Sample rate out of range."
    write(ins,string("SOUR:FREQ ",rate))
end

"Get the sample rate in Hz. Output rate = sample rate / number of points."
function inspect(ins::AWG5014C, ::Type{SampleRate})
    parse(ask(ins,"SOUR:FREQ?"))
end

"Current sequencer type"
function inspect(ins::AWG5014C, ::Type{SequencerType})
    SequencerType(ins,ask(ins,"AWGC:SEQ:TYPE?"))
end

"Run an application, e.g. SerialXpress"
function runapplication(ins::AWG5014C, app::ASCIIString)
    write(ins,"AWGC:APPL:RUN \""+app+"\"")
end

function applicationstate(ins::AWG5014C, app::ASCIIString)
    ask(ins,"AWGC:APPL:STAT? \""+app+"\"") == 0 ? StopState(ins) : RunState(ins)
end

function load_awg_settings(ins::AWG5014C,filePath::ASCIIString)
    write(ins,string("AWGC:SRES \"",filePath,"\""))
end

function save_awg_settings(ins::AWG5014C,filePath::ASCIIString)
    write(ins,string("AWGC:SSAV \"",filePath,"\""))
end

function clearwaveforms(ins::AWG5014C)
    write(ins,"SOUR1:FUNC:USER \"\"")
    write(ins,"SOUR2:FUNC:USER \"\"")
    write(ins,"SOUR3:FUNC:USER \"\"")
    write(ins,"SOUR4:FUNC:USER \"\"")
end

function deletewaveform(ins::AWG5014C, name::ASCIIString)
    write(ins, "WLIS:WAV:DEL "*quoted(name))
end

function newwaveform{T<:WaveformType}(ins::AWG5014C, name::ASCIIString, numPoints::Integer, wvtype::Type{T})
    wvtype == WaveformType ? error("Specify IntWaveform or RealWaveform.") : nothing
    write(ins, "WLIS:WAV:NEW "*quoted(name)*","*string(numPoints)*","*code((wvtype)(ins)))
end

function normalizewaveform{T<:Normalization}(ins::AWG5014C, name::ASCIIString, norm::Type{T})
    write(ins, "WLIS:WAV:NORM "*quoted(name)*","*code(norm(ins)))
end

function resamplewaveform(ins::AWG5014C, name::ASCIIString, points::Integer)
    write(ins, "WLIS:WAV:RESA "*quoted(name)*","*string(points))
end

function waveformexists(ins::AWG5014C, name::ASCIIString)
    for (i = 1:wavelistlength(ins))
        if (name == waveformname(ins,i))
            return true
        end
    end

    return false
end

function waveformispredefined(ins::AWG5014C, name::ASCIIString)
    Bool(parse(ask(ins,"WLIST:WAV:PRED? "*quoted(name))))
end

function waveformlength(ins::AWG5014C, name::ASCIIString)
    parse(ask(ins, "WLIST:WAV:LENG? "*quoted(name)))
end

"Uses Julia style indexing (begins at 1) to retrieve the name of a waveform."
function waveformname(ins::AWG5014C, num::Integer)
    strip(ask(ins, "WLIST:NAME? "*string(num-1)),'"')
end

function waveformtimestamp(ins::AWG5014C, name::ASCIIString)
    unquoted(ask(ins,"WLIS:WAV:TST? "*quoted(name)))
end

"Returns the type of the waveform. The AWG hardware ultimately uses an `IntWaveform` but `RealWaveform` is more convenient."
function waveformtype(ins::AWG5014C, name::ASCIIString)
    WaveformType(ins, ask(ins,"WLIS:WAV:TYPE? "*quoted(name)))
end

"Push data to the AWG, performing checks and generating errors as appropriate."
function pushto_awg{T<:WaveformType}(ins::AWG5014C, name::ASCIIString, awgData::AWG5014CData, wvType::Type{T}, resampleOk::Bool=false)

    # First validate the awgData
    validate(awgData, wvType)

    # If the waveform does not exist, create it
    if (!waveformexists(ins,name))
        newwaveform(ins,name,length(awgData.data),wvType)
    else
        # Otherwise, do some checks.
        # First, is it predefined?
        if (waveformispredefined(ins,name))
            error("Cannot overwrite predefined waveform.")
        end

        # Is the type different than requested?
        # We are unable to modify an existing waveform's type, so the best thing to do is bail.
        if !(waveformtype(ins,name) <: wvType)
            error("Existing waveform type differs. If you insist on this type, you need to delete the waveform first, with possible consequences for sequencing.")
        end

        # Is the waveform the wrong length?
        if (length(awgData.data) != waveformlength(ins,name))
            if (resampleOk)
                resamplewaveform(awg,name,length(awgData.data))
            else
                error("Existing waveform length differs. Pass `true` as the final argument to override; adjust sample rate if needed.")
            end
        end
    end

    pushlowlevel(ins,name,awgData,wvType)

end

"Takes care of the dirty work in pushing the data to the AWG."
function pushlowlevel{T<:RealWaveform}(ins::AWG5014C, name::ASCIIString, awgData::AWG5014CData, wvType::Type{T})
    buf = IOBuffer()
    for (i in 1:length(awgData.data))
        # AWG wants little endian data
        write(buf, htol(awgData.data[i]))
        # Write marker bits
        write(buf, UInt8(awgData.marker1[i]) << 6 | UInt8(awgData.marker2[i]) << 7)
    end
    binblockwrite(ins, "WLIST:WAV:DATA "*quoted(name)*",",takebuf_array(buf))
end

function pushlowlevel{T<:IntWaveform}(ins::AWG5014C, name::ASCIIString, awgData::AWG5014CData, wvType::Type{T})
    buf = IOBuffer()
    for (i in 1:length(awgData.data))
        value = (awgData.data)[i]
        value = (value+1.0)/2.0         # now it is in the range [0.0, 1.0]
        value = UInt16(round(value*offsetPlusPPOver2))  # now it is in the valid integer range
        value = value | (UInt16(awgData.marker1[i]) << 14)  # set marker bit 1
        value = value | (UInt16(awgData.marker2[i]) << 15)  # set marker bit 2 too
        write(buf, htol(value))    # make sure we send little endian
    end
    binblockwrite(ins, "WLIST:WAV:DATA "*quoted(name)*",",takebuf_array(buf))
end

"Validates data to be pushed to the AWG to check for internal consistency and appropriate range."
function validate(awgData::AWG5014CData, wvType::Type{WaveformType})
    # Length checks
    if (length(awgData.data) != length(awgData.marker1) != length(awgData.marker2))
        error("Data and marker lengths are not the same.")
    end

    nb = nbytes(wvType)
    if (length(awgData.data) * nb > byteLimit)
        if (length(awgData.data) * 2 <= byteLimit)
            error("Too many bytes for a `RealWaveform`. However, an `IntWaveform` would work.")
        else
            error("Too many bytes to send. You may be able to use another protocol (not implemented).")
        end
    end

    # Integrity checks
    if ((cummax(awgData.data))[end] > 1.0 || (cummin(awgData.data))[end] < -1.0)
        error("Data should be within range [-1.0, 1.0]")
    end
end

nbytes(::RealWaveform)      = 5
nbytes(wvType::IntWaveform) = 2

"Pull data from the AWG, performing checks and generating errors as appropriate."
function pullfrom_awg(ins::AWG5014C, name::ASCIIString)

    if (!waveformexists(ins,name))
        error("Waveform does not exist.")
    end

    typ = waveformtype(ins, name)
    pulllowlevel(ins,name,typ)

end

"Takes care of the dirty work in pulling data from the AWG."
function pulllowlevel{T<:RealWaveform}(ins::AWG5014C, name::ASCIIString, ::Type{T})

    len = waveformlength(ins, name)

    write(ins,"WLIST:WAV:DATA? "*quoted(name))
    io = binblockreadavailable(ins)

    samples = Int(floor((io.size-(io.ptr-1))/5.))

    amp =  Vector{Float32}(samples)
    marker1 = Vector{Bool}(samples)
    marker2 = Vector{Bool}(samples)

    for (i=1:samples)
        amp[i] = ltoh(read(io,Float32))
        markers = read(io,UInt8)
        marker1[i] = Bool((markers >> 6) & UInt8(1))
        marker2[i] = Bool((markers >> 7) & UInt8(1))
    end

    AWG5014CData(amp,marker1,marker2)
end

function pulllowlevel{T<:IntWaveform}(ins::AWG5014C, name::ASCIIString, ::Type{T})

    len = waveformlength(ins, name)

    write(ins,"WLIST:WAV:DATA? "*quoted(name))
    io = binblockreadavailable(ins)

    # Handle pesky terminators.
    #
    # The logic here is that the binblock *may* end in \r, \n, or \r\n.
    # This seems to depend on the communication protocol, e.g. INSTR vs SOCKET.
    #
    # So we just assume an extra byte is a terminator, but explicitly check if
    # we have two extra bytes, in which case we throw that out.

    pointer = io.ptr
    seek(io,io.size-2)
    finalTwo = ltoh(read(io,UInt16))
    seek(io,pointer-1)
    samples = Int(floor((io.size-(io.ptr-1))/2.))

    if (finalTwo == 0x0a0d) # this just means the last two characters were \r\n
        samples -= 1
    end

    amp =  Vector{Float32}(samples)
    marker1 = Vector{Bool}(samples)
    marker2 = Vector{Bool}(samples)

    for (i=1:samples)
        sample = ltoh(read(io,UInt16))
        marker1[i] = Bool((sample >> 14) & UInt16(1))
        marker2[i] = Bool((sample >> 15) & UInt16(1))
        sample = sample & maximumValue
        amp[i] = Float32((sample/offsetPlusPPOver2)*2.0 - 1.0)
    end

    AWG5014CData(amp,marker1,marker2)
end

end
