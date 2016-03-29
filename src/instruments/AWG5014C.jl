### Tektronix AWG5014C
module AWG5014CModule

## Import packages
import VISA

## Import our modules
importall PainterQB                 # All the stuff in InstrumentDefs, etc.
metadata = insjson(joinpath(Pkg.dir("PainterQB"),"deps/AWG5014C.json"))
include(joinpath(Pkg.dir("PainterQB"),"src/meta/Metaprogramming.jl"))

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
export EventImpedance
export EventSlope
export EventTiming
export ExtInputAddsToOutput
export ExtOscDividerRate
export MarkerDelay
export OutputFilterFrequency
export RefOscFrequency
export RefOscMultiplier
export RepRate
export RepRateHeld
export SequencerEventJumpTarget
export SequencerGOTOTarget
export SequencerGOTOState
export SequencerInfiniteLoop
export SequencerLength
export SequencerLoopCount
export SequencerPosition
export TriggerMode
export TriggerTimer
export WaitingForTrigger
export Waveform
export WavelistLength
export VoltageOffset

export runapplication, applicationstate, validate
export load_awg_settings, save_awg_settings
export clearwaveforms, deletewaveform, newwaveform
export normalizewaveform, resamplewaveform
export waveformexists, waveformispredefined
export waveform, waveformlength, waveformtimestamp, waveformtype
export pullfrom_awg, pushto_awg

export @allch

# We also export from the generate_properties statement.

const allWaveforms      = ASCIIString("ALL")

# Maximum number of bytes that may be sent using WLIS:WAV:DATA
"Maximum number of bytes that may be sent using the SCPI command WLIS:WAV:DATA."
const byteLimit         = 65e7

# IntWaveform values.
"""
Constant used for synthesizing/interpreting waveforms of integer type.
This represents the minimum value.
"""
const minimumValue      = 0x0000

"""
Constant used for synthesizing/interpreting waveforms of integer type.
This represents zero for a waveform.
"""
const offsetValue       = 0x1fff

"""
Constant used for synthesizing/interpreting waveforms of integer type.
This represents zero plus Vpp/2.
"""
const offsetPlusPPOver2 = 0x3ffe

"""
Constant used for synthesizing/interpreting waveforms of integer type.
This represents the maximum value (register size?).
"""
const maximumValue      = 0x3fff

"Concrete type representing an AWG5014C."
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

"Type for storing waveform data (including markers) in Float32 format."
type AWG5014CData
    data::Array{Float32,1}
    marker1::Array{Bool,1}
    marker2::Array{Bool,1}
end

"Internal AWG code meaning no errors."
const noError = 0

"Exception dictionary mapping signed integers to error strings."
exceptions    = Dict(
         0   => "No error.",
        -222 => "Out of range.",
        -224 => "Not a power of 2.",
        -330 => "Diagnostic error.",
        -340 => "Calibration error.")

InstrumentException(ins::AWG5014C, r) = InstrumentException(ins, r, exceptions[r])

"Event input impedance may be 50 Ohm or 1 kOhm."
abstract EventImpedance    <: InstrumentProperty

"Event may fire on a rising or falling slope."
abstract EventSlope        <: InstrumentProperty

"Events may occur synchronously or asynchronously."
abstract EventTiming       <: InstrumentProperty

abstract Normalization     <: InstrumentProperty

"Sequencer may be hardware or software."
abstract SequencerType     <: InstrumentProperty

"Trigger engine may be triggered, continuously firing, gated, or sequenced."
abstract TriggerMode       <: InstrumentProperty

"Waveform type may be integer or real."
abstract WaveformType      <: InstrumentProperty

returntype(::Type{Bool}) = (Int, Bool)
returntype(::Type{Real}) = (Float64, Float64)
returntype(::Type{Integer}) = (Int, Int)
fmt(v::Bool) = string(Int(v))
fmt(v) = string(v)

code(ins::AWG5014C, ::Type{Normalization}, ::Type{Val{:None}}) = "NONE"
code(ins::AWG5014C, ::Type{Normalization}, ::Type{Val{:FullScale}}) = "FSC"
code(ins::AWG5014C, ::Type{Normalization}, ::Type{Val{:PreserveOffset}}) = "ZREF"

code(ins::AWG5014C, ::Type{WaveformType}, ::Type{Val{:IntWaveform}})  = "INT"
code(ins::AWG5014C, ::Type{WaveformType}, ::Type{Val{:RealWaveform}}) = "REAL"

function WaveformType(ins::AWG5014C, s::AbstractString)
    s == "INT" ? :IntWaveform : :RealWaveform
end

"""
Amplitude for a given channel.
"""
abstract Amplitude                <: InstrumentProperty{Float64}

"""
Analog output delay for a given channel.
The effect of this command can be seen only in non-sequence mode.
"""
abstract AnalogOutputDelay        <: InstrumentProperty{Float64}

"""
Boolean state of the output for a given channel.
"""
abstract ChannelOutput            <: InstrumentProperty

"""
Boolean state of the DC output for a given channel (bottom-right of AWG).
"""
abstract DCOutput                 <: InstrumentProperty

"""
DC output level for a given channel.
"""
abstract DCOutputLevel            <: InstrumentProperty{Float64}

"""
Add the signal from an external input to the given channel output.
"""
abstract ExtInputAddsToOutput     <: InstrumentProperty

"""
Divider rate of the external oscillator; must be a power of 2 (1 ok).
"""
abstract ExtOscDividerRate        <: InstrumentProperty{Int}

"""
Marker delay for a given channel and marker. Marker can be 1 or 2.
"""
abstract MarkerDelay              <: InstrumentProperty{Float64}

"""
Low-pass filter frequency for the output. INF = 9.9e37
"""
abstract OutputFilterFrequency    <: InstrumentProperty{Float64}

"""
Reference oscillator frequency.

Valid values are 10 MHz, 20 MHz and 100 MHz. Used when:

- Clock Source is Internal
- Reference Input is External
- External Reference Type is Fixed.
"""
abstract RefOscFrequency          <: InstrumentProperty{Float64}

"""
Reference oscillator multiplier.

Used when:
- Clock Source is Internal
- Reference Source is External
- External Reference Type is Variable.
"""
abstract RefOscMultiplier         <: InstrumentProperty{Int}

"""
Repetition rate (frequency of waveform). Changing this will change the
sampling rate.
"""
abstract RepRate                  <: InstrumentProperty{Float64}

"""
Boolean hold state of the repetition rate. If held, the repetition rate will
not change when the size of the waveform changes.
"""
abstract RepRateHeld              <: InstrumentProperty

"""
Target index for the sequencer event jump operation.
Note that this will take effect only when
SEQuence:ELEMent[n]:JTARget:TYPE is set to INDex.
"""
abstract SequencerEventJumpTarget <: InstrumentProperty{Int}

"""
Target index for the GOTO command of the sequencer.
"""
abstract SequencerGOTOTarget      <: InstrumentProperty{Int}

"Boolean GOTO state of the sequencer."
abstract SequencerGOTOState       <: InstrumentProperty

"Boolean state of infinite loop on a sequencer element."
abstract SequencerInfiniteLoop    <: InstrumentProperty

"Length of the sequence. Can be destructive to existing sequences."
abstract SequencerLength          <: InstrumentProperty{Int}

"Loop count of the sequencer, from 1 to 65536. Ignored if infinite loop."
abstract SequencerLoopCount       <: InstrumentProperty{Int}

"Current sequencer position."
abstract SequencerPosition        <: InstrumentProperty{Int}

"Internal trigger rate."
abstract TriggerTimer             <: InstrumentProperty{Float64}

"When inspected, will report if the instrument is waiting for a trigger."
abstract WaitingForTrigger        <: InstrumentProperty

"Name of a waveform loaded into a given channel."
abstract Waveform                 <: InstrumentProperty

"The number of waveforms stored in the AWG."
abstract WavelistLength           <: InstrumentProperty{Int}

"Offset voltage for a given channel."
abstract VoltageOffset            <: InstrumentProperty{Float64}

returntype(::Type{Bool}) = (Int, Bool)
returntype(::Type{Real}) = (Float64, Float64)
returntype(::Type{Integer}) = (Int, Int)
fmt(v::Bool) = string(Int(v))
fmt(v) = string(v)

generate_all(AWG5014C)

"Configure the global analog output state of the AWG."
function configure(ins::AWG5014C, ::Type{Output}, on::Bool)
    on ? write(ins, "AWGC:RUN") : write(ins, "AWGC:STOP")
end

"Inspect the global analog output state of the AWG."
function inspect(ins::AWG5014C, ::Type{Output})
    parse(ask(ins,"AWGC:RSTATE?")) > 0 ? true : false
end

"Inspect whether or not the instrument is waiting for a trigger."
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

Example: `@allch configure(awg,Waveform,"*Sine10")`
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
function inspect(ins::AWG5014C, ::Type{OutputPhase}, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    parse(ask(ins,string("SOUR",ch,":PHAS?")))
end

"Set the output phase in degrees for a given channel."
function configure(ins::AWG5014C, ::Type{OutputPhase}, phase::Real, ch::Integer)
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

"Configure the waveform by name for a given channel."
function configure(ins::AWG5014C, ::Type{Waveform}, name::ASCIIString, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    write(ins,string("SOUR",ch,":WAV ",quoted(name)))
end

"Inspect the waveform name for a given channel."
function inspect(ins::AWG5014C, ::Type{Waveform}, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    unquoted(ask(ins,string("SOUR",ch,":WAV?")))
end

# Set Vpp for a given channel between 0.05 V and 2 V.
"Configure Vpp for a given channel, between 0.05 V and 2 V."
function configure(ins::AWG5014C, ::Type{Amplitude}, ampl::Real, ch::Integer)
    @assert (0.05 <= ampl <= 2) "Amplitude out of range."
    @assert (1 <= ch <= 4) "Channel out of range."
    write(ins,string("SOUR",ch,":VOLT ",ampl))
end

"Inspect Vpp for a given channel."
function inspect(ins::AWG5014C, ::Type{Amplitude}, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    parse(ask(ins,string("SOUR",ch,":VOLT?")))
end

"""
Configure the sample rate in Hz between 10 MHz and 10 GHz.
Output rate = sample rate / number of points.
"""
function configure(ins::AWG5014C, ::Type{SampleRate}, rate::Real)
    @assert (10e6 <= rate <= 10e9) "Sample rate out of range."
    write(ins,string("SOUR:FREQ ",rate))
end

"Get the sample rate in Hz. Output rate = sample rate / number of points."
function inspect(ins::AWG5014C, ::Type{SampleRate})
    parse(ask(ins,"SOUR:FREQ?"))
end

function runapplication(ins::AWG5014C, app::ASCIIString)
    write(ins,"AWGC:APPL:RUN \""+app+"\"")
end

"Run an application, e.g. SerialXpress"
runapplication

function applicationstate(ins::AWG5014C, app::ASCIIString)
    ask(ins,"AWGC:APPL:STAT? \""+app+"\"") == 0 ? false : true
end

"Is an application running?"
applicationstate

function load_awg_settings(ins::AWG5014C,filePath::ASCIIString)
    write(ins,string("AWGC:SRES \"",filePath,"\""))
end

"Load an AWG settings file."
load_awg_settings

function save_awg_settings(ins::AWG5014C,filePath::ASCIIString)
    write(ins,string("AWGC:SSAV \"",filePath,"\""))
end

"Save an AWG settings file."
save_awg_settings

function clearwaveforms(ins::AWG5014C)
    write(ins,"SOUR1:FUNC:USER \"\"")
    write(ins,"SOUR2:FUNC:USER \"\"")
    write(ins,"SOUR3:FUNC:USER \"\"")
    write(ins,"SOUR4:FUNC:USER \"\"")
end

"Clear waveforms from all channels."
clearwaveforms

function deletewaveform(ins::AWG5014C, name::ASCIIString)
    write(ins, "WLIS:WAV:DEL "*quoted(name))
end

"Delete a waveform by name."
deletewaveform

function newwaveform(ins::AWG5014C, name::ASCIIString, numPoints::Integer, wvtype::Symbol)
    write(ins, "WLIS:WAV:NEW #,#,#",quoted(name),
        string(numPoints), code(ins, WaveformType, Val{wvtype}))
    nothing
end

"Create a new waveform by name, number of points, and waveform type."
newwaveform

function normalizewaveform(ins::AWG5014C, name::ASCIIString, norm::Symbol)
    write(ins, "WLIS:WAV:NORM "*quoted(name)*","*code(ins, Normalization, Val{norm}))
end

"Normalize a waveform."
normalizewaveform

function resamplewaveform(ins::AWG5014C, name::ASCIIString, points::Integer)
    write(ins, "WLIS:WAV:RESA "*quoted(name)*","*string(points))
end

"Resample a waveform."
resamplewaveform

function waveformexists(ins::AWG5014C, name::ASCIIString)
    for (i = 1:inspect(ins,WavelistLength))
        if (name == waveform(ins,i))
            return true
        end
    end

    return false
end

"Does a waveform identified by `name` exist?"
waveformexists

function waveformispredefined(ins::AWG5014C, name::ASCIIString)
    Bool(parse(ask(ins,"WLIST:WAV:PRED? "*quoted(name))))
end

"Returns whether or not a waveform is predefined (comes with instrument)."
waveformispredefined

function waveformlength(ins::AWG5014C, name::ASCIIString)
    parse(ask(ins, "WLIST:WAV:LENG? "*quoted(name)))
end

"Returns the length of a waveform."
waveformlength

function waveform(ins::AWG5014C, num::Integer)
    strip(ask(ins, "WLIST:NAME? "*string(num-1)),'"')
end

"""
Uses Julia style indexing (begins at 1) to retrieve the name of a waveform
from the waveform list.
"""
waveform

function waveformtimestamp(ins::AWG5014C, name::ASCIIString)
    unquoted(ask(ins,"WLIS:WAV:TST? "*quoted(name)))
end

"Return the timestamp for when a waveform was last updated."
waveformtimestamp

function waveformtype(ins::AWG5014C, name::ASCIIString)
    WaveformType(ins, ask(ins,"WLIS:WAV:TYPE? "*quoted(name)))
end

"""
Returns the type of the waveform. The AWG hardware
ultimately uses an `IntWaveform` but `RealWaveform` is more convenient.
"""
waveformtype

function pushto_awg(ins::AWG5014C, name::ASCIIString,
        awgData::AWG5014CData, wvType::Symbol, resampleOk::Bool=false)

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
        if !(waveformtype(ins,name) == wvType)
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

    pushlowlevel(ins,name,awgData,Val{wvType})

end

"Push waveform data to the AWG, performing checks and generating errors as appropriate."
pushto_awg

function pushlowlevel(ins::AWG5014C, name::ASCIIString,
        awgData::AWG5014CData, wvType::Type{Val{:RealWaveform}})
    buf = IOBuffer()
    for (i in 1:length(awgData.data))
        # AWG wants little endian data
        write(buf, htol(awgData.data[i]))
        # Write marker bits
        write(buf, UInt8(awgData.marker1[i]) << 6 | UInt8(awgData.marker2[i]) << 7)
    end
    binblockwrite(ins, "WLIST:WAV:DATA "*quoted(name)*",",takebuf_array(buf))
end

function pushlowlevel(ins::AWG5014C, name::ASCIIString,
        awgData::AWG5014CData, wvType::Type{Val{:IntWaveform}})
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

"Takes care of the dirty work in pushing the data to the AWG."
pushlowlevel

function validate(awgData::AWG5014CData, wvType::Symbol)
    # Length checks
    if (length(awgData.data) != length(awgData.marker1) != length(awgData.marker2))
        error("Data and marker lengths are not the same.")
    end

    nb = nbytes(Val{wvType})
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

"Validates data to be pushed to the AWG to check for internal consistency
and appropriate range."
validate

nbytes(::Type{Val{:RealWaveform}}) = 5
nbytes(::Type{Val{:IntWaveform}})  = 2

"Returns the number of bytes per sample for a a given waveform type."
nbytes

function pullfrom_awg(ins::AWG5014C, name::ASCIIString)

    if (!waveformexists(ins,name))
        error("Waveform does not exist.")
    end

    typ = waveformtype(ins, name)
    pulllowlevel(ins,name,Val{typ})

end

"Pull data from the AWG, performing checks and generating errors as appropriate."
pullfrom_awg

function pulllowlevel(ins::AWG5014C, name::ASCIIString, ::Type{Val{:RealWaveform}})

    len = waveformlength(ins, name)

    write(ins,"WLIST:WAV:DATA? "*quoted(name))
    io = binblockreadavailable(ins)

    samples = Int(floor((io.size-(io.ptr-1))/5.))

    amp =  Vector{Float32}(samples)
    marker1 = Vector{Bool}(samples)
    marker2 = Vector{Bool}(samples)

    for i=1:samples
        amp[i] = ltoh(read(io,Float32))
        markers = read(io,UInt8)
        marker1[i] = Bool((markers >> 6) & UInt8(1))
        marker2[i] = Bool((markers >> 7) & UInt8(1))
    end

    AWG5014CData(amp,marker1,marker2)
end

function pulllowlevel(ins::AWG5014C, name::ASCIIString, ::Type{Val{:IntWaveform}})

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

"Takes care of the dirty work in pulling data from the AWG."
pulllowlevel

end
