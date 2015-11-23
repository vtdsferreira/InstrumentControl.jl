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

export WaveformType, Normalization

export runapplication, applicationstate, validate
export hardwaresequencertype, load_awg_settings, save_awg_settings, clearwaveforms
export deleteuserwaveform, waveformispredefined, waveformtimestamp, waveformtype
export waveformname, waveformlength, pullfrom_awg, pushto_awg, newwaveform
export set_amplitude_vpp, amplitude_vpp, samplerate, set_samplerate
export waveform, set_waveform, set_voltageoffset, voltageoffset
export phase_deg, set_phase_deg, set_phase_rad, set_phase_rad
export @allch

# We also export from the createCodeType statement.

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
    # wavelistArray::Array{ASCIIString,1}

    AWG5014C(x) = begin
        ins = new()
        ins.vi = x
        ins.writeTerminator = "\n"
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

abstract WaveformType  <: InstrumentCode
abstract Normalization <: InstrumentCode

subtypesArray = [
    (:IntWaveform,          WaveformType),
    (:RealWaveform,         WaveformType),

    (:NotNormalized,        Normalization),
    (:FullScale,            Normalization),
    (:PreservingOffset,     Normalization)
]::Array{Tuple{Symbol,DataType},1}

# Create all the concrete types we need using the createCodeType function.
for ((subtypeSymb,supertype) in subtypesArray)
    createCodeType(subtypeSymb, supertype)
end

responses = Dict(
    :State            => Dict(0       => :Stop,
                              2       => :Run,
                              1       => :Wait),

    :Timing           => Dict("SYNC"  => :Synchronous,
                              "ASYNC" => :Asynchronous),

    :TriggerSlope     => Dict("POS"   => :RisingTrigger,
                              "NEG"   => :FallingTrigger),

    :ClockSlope       => Dict("POS"   => :RisingClock,
                              "NEG"   => :FallingClock),

    :EventSlope       => Dict("POS"   => :RisingEvent,
                              "NEG"   => :FallingEvent),

    :Trigger          => Dict("TRIG"  => :Triggered,
                              "CONT"  => :Continuous,
                              "GAT"   => :Gated,
                              "SEQ"   => :Sequence),

    :ClockSource      => Dict("INT"   => :InternalClock,
                              "EXT"   => :ExternalClock),

    :OscillatorSource => Dict("INT"   => :InternalOscillator,
                              "EXT"   => :ExternalOscillator),

    :TriggerSource    => Dict("INT"   => :InternalTrigger,
                              "EXT"   => :ExternalTrigger),

    :Impedance        => Dict(  50.0  => :Ohm50,
                              1000.0  => :Ohm1k),

    :Lock             => Dict(0       => :Local,
                              1       => :Remote),

    :WaveformType     => Dict("INT"  => :IntWaveform,
                              "REAL" => :RealWaveform),

    :Normalization    => Dict("NONE" => :NotNormalized,
                              "FSC"  => :NormalizedFullScale,
                              "ZREF" => :NormalizedPreservingOffset)
)

generateResponseHandlers(AWG5014C,responses)

# Needed because otherwise we need to qualify the run(awg) command with the module name.
import Main.run

sfd = Dict(
    "calibrate"                         => ["*CAL?",                    InstrumentException],
    "options"                           => ["*OPT?",                    ASCIIString],
    "externaloscillator_dividerrate"    => ["AWGC:CLOC:DRAT",           Int],    # IMPLEMENT ERROR HANDLING
    "referenceclocksource"              => ["AWGC:CLOC:SOUR",           ClockSource],
    "num_availablechannels"             => ["AWGC:CONF:CNUM?",          Int],
    "dcstate"                           => ["AWGC:DC:STAT",             Bool],
    "dcoutputlevel"                     => ["AWGC:DC#:VOLT:OFFS",       AbstractFloat],
    "repetitionrate"                    => ["AWGC:RRAT",                AbstractFloat],
    "repetitionrateheld"                => ["AWGC:RRAT:HOLD",           Bool],
    "runstate"                          => ["AWGC:RSTATE?",             State],
    "runmode"                           => ["AWGC:RMOD",                Trigger],
    "run"                               => ["AWGC:RUN",                 NoArgs],
    "stop"                              => ["AWGC:STOP",                NoArgs],
    "sequencer_position"                => ["AWGC:SEQ:POS?",            Int],
    # The following two methods may return AWGYes() if the window *cannot* be displayed.
    # They return the correct result (AWGNo()) if the window can be displayed, but is not displayed.
    "sequencewindowdisplayed"           => ["DISP:WIND1:STAT",          Bool],
    "waveformwindowdisplayed"           => ["DISP:WIND2:STAT",          Bool],
    "event_force"                       => ["EVEN",                     NoArgs],
    "event_impedance"                   => ["EVEN:IMP",                 Impedance],
    "event_jumptiming"                  => ["EVEN:JTIM",                Timing],
    "event_level"                       => ["EVEN:LEV",                 AbstractFloat],
    "event_slope"                       => ["EVEN:POL",                 EventSlope],
    "output_filterfrequency"            => ["OUTP#:FILT:FREQ",          AbstractFloat],
    "output_on_ch"                      => ["OUTP#:STAT",               Bool],
    "sequencer_gototarget"              => ["SEQ:ELEM#:GOTO:IND",       Int],
    "sequencer_gotostate"               => ["SEQ:ELEM#:GOTO:STAT",      Bool],
    "sequencer_eventjumptarget"         => ["SEQ:ELEM#:JTAR:IND",       Int],
    "sequencer_loopcount"               => ["SEQ:ELEM#:LOOP:COUN",      Int],
    "sequencer_infiniteloop"            => ["SEQ:ELEM#:LOOP:INF",       Bool],
    "sequencer_length"                  => ["SEQ:LENG",                 Int],
    "sequencer_forcejump"               => ["SEQ:JUMP",                 NoArgs],
    "externalinputaddstooutput"         => ["SOUR#:COMB:FEED",          ASCIIString],
    "analogoutputdelay_s"               => ["SOUR#:DELAY",              AbstractFloat],
    "analogoutputdelay_points"          => ["SOUR#:DELAY:POIN",         AbstractFloat],
    "waveformloadedinchannel"           => ["SOUR#:FUNC:USER",          ASCIIString],
    "marker_delay"                      => ["SOUR#:MARK#:DEL",          AbstractFloat],
    "referenceoscillator_frequency"     => ["SOUR:ROSC:FREQ",           AbstractFloat],
    "referenceoscillator_multiplier"    => ["SOUR:ROSC:MULT",           Int],
    "referenceoscillator_source"        => ["SOUR:ROSC:SOUR",           OscillatorSource],
    "systemDate"                        => ["SYST:DATE",                Int],
    "panelLocked"                       => ["SYST:KLOC",                Lock],
    "systemTime"                        => ["SYST:TIME",                Int],
    "scpiversion"                       => ["SYST:VERS?",               ASCIIString],
    "trigger_impedance"                 => ["TRIG:IMP",                 Impedance],
    "trigger_level"                     => ["TRIG:LEV",                 AbstractFloat],
    "trigger_slope"                     => ["TRIG:POL",                 TriggerSlope],
    "trigger_timer"                     => ["TRIG:TIM",                 AbstractFloat],
    "trigger_source"                    => ["TRIG:SOUR",                TriggerSource],
    "wavelistlength"                    => ["WLIST:SIZE?",              Int]
)

for (fnName in keys(sfd))
    createStateFunction(AWG5014C,fnName,sfd[fnName][1],sfd[fnName][2])
end

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
function phase_deg(ins::AWG5014C, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    parse(query_ins(ins,string("SOUR",ch,":PHAS?")))
end

"Set the output phase in degrees for a given channel."
function set_phase_deg(ins::AWG5014C, phase::Real, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    ph = phase+180.
    ph = mod(ph,360.)
    ph -= 180.
    parse(query_ins(ins,string("SOUR",ch,":PHAS ",phase)))
end

"Get the output phase in radians for a given channel."
function phase_rad(ins::AWG5014C, ch::Integer)
    phaseDegrees(ins,ch) * π / 180.
end

"Set the output phase in radians for a given channel."
function set_phase_rad(ins::AWG5014C, phase::Real, ch::Integer)
    setPhaseDegrees(ins, phase*180./π, ch)
end

"Get the voltage offset for a given channel."
function voltageoffset(ins::AWG5014C, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    parse(query_ins(ins,string("SOUR",ch,":VOLT:OFFS?")))
end

"Set the voltage offset between -2.25 V and 2.25 V for a given channel."
function set_voltageoffset(ins::AWG5014C, voff::Real, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    @assert (-2.25 <= voff <= 2.25) "Offset out of range."
    write_ins(ins,string("SOUR",ch,":VOLT:OFFS ",voff))
end

"Get the waveform name for a given channel."
function waveform(ins::AWG5014C, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    query_ins(ins,string("SOUR",ch,":WAV?"))
end

"Set the waveform by name for a given channel."
function set_waveform(ins::AWG5014C, name::ASCIIString, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    write_ins(ins,string("SOUR",ch,":WAV ",quoted(name)))
end

"Set Vpp for a given channel between 0.05 V and 2 V."
function set_amplitude_vpp(ins::AWG5014C, ampl::Real, ch::Integer)
    @assert (0.05 <= ampl <= 2) "Amplitude out of range."
    @assert (1 <= ch <= 4) "Channel out of range."
    write_ins(ins,string("SOUR",ch,":VOLT ",ampl))
end

"Get Vpp for a given channel."
function amplitude_vpp(ins::AWG5014C, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    parse(query_ins(ins,string("SOUR",ch,":VOLT?")))
end

"Set the sample rate in Hz between 10 MHz and 10 GHz. Output rate = sample rate / number of points."
function set_samplerate(ins::AWG5014C, rate::Real)
    @assert (10e6 <= rate <= 10e9) "Sample rate out of range."
    write_ins(ins,string("SOUR:FREQ ",rate))
end

"Get the sample rate in Hz. Output rate = sample rate / number of points."
function samplerate(ins::AWG5014C)
    parse(query_ins(ins,"SOUR:FREQ?"))
end

"Run an application, e.g. SerialXpress"
function runapplication(ins::AWG5014C, app::ASCIIString)
    write_ins(ins,"AWGC:APPL:RUN \""+app+"\"")
end

function applicationstate(ins::AWG5014C, app::ASCIIString)
    query_ins(ins,"AWGC:APPL:STAT? \""+app+"\"") == 0 ? StopState(ins) : RunState(ins)
end

function hardwaresequencertype(ins::AWG5014C)
    chomp(query_ins(ins,"AWGC:SEQ:TYPE?")) == "HARD" ? true : false
end

function load_awg_settings(ins::AWG5014C,filePath::ASCIIString)
    write_ins(ins,string("AWGC:SRES \"",filePath,"\""))
end

function save_awg_settings(ins::AWG5014C,filePath::ASCIIString)
    write_ins(ins,string("AWGC:SSAV \"",filePath,"\""))
end

function clearwaveforms(ins::AWG5014C)
    write_ins(ins,"SOUR1:FUNC:USER \"\"")
    write_ins(ins,"SOUR2:FUNC:USER \"\"")
    write_ins(ins,"SOUR3:FUNC:USER \"\"")
    write_ins(ins,"SOUR4:FUNC:USER \"\"")
end

function deletewaveform(ins::AWG5014C, name::ASCIIString)
    write_ins(ins, "WLIS:WAV:DEL "*quoted(name))
end

function newwaveform{T<:WaveformType}(ins::AWG5014C, name::ASCIIString, numPoints::Integer, wvtype::Type{T})
    write_ins(ins, "WLIS:WAV:NEW "*quoted(name)*","*string(numPoints)*","*state((wvtype)(AWG5014C)))
end

function resamplewaveform(ins::AWG5014C, name::ASCIIString, points::Integer)
    write_ins(ins, "WLIS:WAV:RESA "*quoted(name)*","*string(points))
end

function normalizewaveform{T<:Normalization}(ins::AWG5014C, name::ASCIIString, norm::Type{T})
    write_ins(ins, "WLIS:WAV:NORM "*quoted(name)*","*state(norm(AWG5014C)))
end

"Uses Julia style indexing (begins at 1) to retrieve the name of a waveform."
function waveformname(ins::AWG5014C, num::Integer)
    strip(query_ins(ins, "WLIST:NAME? "*string(num-1)),'"')
end

function waveformlength(ins::AWG5014C, name::ASCIIString)
    parse(query_ins(ins, "WLIST:WAV:LENG? "*quoted(name)))
end

function waveformispredefined(ins::AWG5014C, name::ASCIIString)
    Bool(parse(query_ins(ins,"WLIST:WAV:PRED? "*quoted(name))))
end

function waveformexists(ins::AWG5014C, name::ASCIIString)
    for (i = 1:wavelistlength(ins))
        if (name == waveformname(ins,i))
            return true
        end
    end

    return false
end

function waveformtimestamp(ins::AWG5014C, name::ASCIIString)
    strip(query_ins(ins,"WLIS:WAV:TST? "*quoted(name)),"\"")
end

"Returns the type of the waveform. The AWG hardware ultimately uses an `IntWaveform` but `RealWaveform` is more convenient."
function waveformtype(ins::AWG5014C, name::ASCIIString)
    WaveformType(AWG5014C, query_ins(ins,"WLIS:WAV:TYPE? "*quoted(name)))
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
    binblockwrite_ins(ins, "WLIST:WAV:DATA "*quoted(name)*",",takebuf_array(buf))
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
    binblockwrite_ins(ins, "WLIST:WAV:DATA "*quoted(name)*",",takebuf_array(buf))
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

    len = waveformLength(ins, name)

    write_ins(ins,"WLIST:WAV:DATA? "*quoted(name))
    io = binblockreadavailable_ins(ins)

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

    write_ins(ins,"WLIST:WAV:DATA? "*quoted(name))
    io = binblockreadavailable_ins(ins)

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
