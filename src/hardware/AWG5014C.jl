### Tektronix AWG5014C
export AWG5014C

export allWaveforms
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
        # wavelistArray = Array{ASCIIString,1}()
        # for (i = 1:wavelistLength(ins).state)
        #     push!(wavelistArray,wavelistName(ins,i-1))
        # end
        ins
    end

    AWG5014C() = new()
end

export AWG5014CString
type AWG5014CString <: BufferedInput
    ins::AWG5014C
    label::Label
    val::AbstractString
end

# export query, read
# query(ins::AWG5014C, msg::ASCIIString) = chomp(PyCall.pycall(ins.vi[:query],ASCIIString,msg))
# read(ins::AWG5014C) = chomp(PyCall.pycall(ins.vi[:read],ASCIIString))

export AWG5014CData
type AWG5014CData
    data::Array{Float32,1}
    marker1::Array{Bool,1}
    marker2::Array{Bool,1}
end

const noError = 0
exceptions    = Dict(
         0     => "No error.",
        -222 => "Out of range.",
        -224 => "Not a power of 2.",
        -330 => "Diagnostic error.",
        -340 => "Calibration error.")

InstrumentException(ins::AWG5014C, r) = InstrumentException(ins, r, exceptions[r])

responses = Dict(
    :InstrumentState            => Dict(0       => :Stop,
                                        2       => :Run,
                                        1       => :Wait),

    :InstrumentTiming           => Dict("SYNC"  => :Synchronous,
                                        "ASYNC" => :Asynchronous),

    :InstrumentTriggerSlope     => Dict("POS"   => :TriggerRising,
                                        "NEG"   => :TriggerFalling),

    :InstrumentClockSlope       => Dict("POS"   => :ClockRising,
                                        "NEG"   => :ClockFalling),

    :InstrumentEventSlope       => Dict("POS"   => :EventRising,
                                        "NEG"   => :EventFalling),

    :InstrumentTrigger          => Dict("TRIG"  => :Triggered,
                                        "CONT"  => :Continuous,
                                        "GAT"   => :Gated,
                                        "SEQ"   => :Sequence),

    :InstrumentClockSource      => Dict("INT"   => :InternalClock,
                                        "EXT"   => :ExternalClock),

    :InstrumentOscillatorSource => Dict("INT"   => :InternalOscillator,
                                        "EXT"   => :ExternalOscillator),

    :InstrumentTriggerSource    => Dict("INT"   => :InternalTrigger,
                                        "EXT"   => :ExternalTrigger),

    :InstrumentImpedance        => Dict(  50.0  => :Ohm50,
                                        1000.0  => :Ohm1k),

    :InstrumentLock             => Dict(0       => :Local,
                                        1       => :Remote)
)

generateResponseHandlers(AWG5014C,responses)

export AWG5014CWaveformType
abstract AWG5014CWaveformType <: InstrumentCode
abstract AWG5014CNormalization <: InstrumentCode

subtypesArray = [
    (:IntWaveform,          AWG5014CWaveformType),
    (:RealWaveform,         AWG5014CWaveformType),

    (:NotNormalized,        AWG5014CNormalization),
    (:FullScale,            AWG5014CNormalization),
    (:PreservingOffset,     AWG5014CNormalization)
]::Array{Tuple{Symbol,DataType},1}

# Create all the concrete types we need using the createCodeType function.
for ((subtypeSymb,supertype) in subtypesArray)
    PainterQB.createCodeType(subtypeSymb, supertype)
end

uniqueResponses = Dict(
    :AWG5014CWaveformType  => Dict("INT"  => :IntWaveform,
                                   "REAL" => :RealWaveform),

    :AWG5014CNormalization => Dict("NONE" => :NotNormalized,
                                   "FSC"  => :NormalizedFullScale,
                                   "ZREF" => :NormalizedPreservingOffset)
)
generateResponseHandlers(AWG5014C, uniqueResponses)

# Needed because otherwise we need to qualify the run(awg) command with the module name.
import Main.run

sfd = Dict(
    "calibrate"                         => ["*CAL?",                    InstrumentException],
    "options"                           => ["*OPT?",                    ASCIIString],
    "externalOscillatorDividerRate"     => ["AWGC:CLOC:DRAT",           Int64],    # IMPLEMENT ERROR HANDLING
    "referenceClockSource"              => ["AWGC:CLOC:SOUR",           InstrumentClockSource],
    "numberOfAvailableChannels"         => ["AWGC:CONF:CNUM?",          Int64],
    "dcState"                           => ["AWGC:DC:STAT",             Bool],
    "dcOutputLevel"                     => ["AWGC:DC#:VOLT:OFFS",       Float64],
    "repetitionRate"                    => ["AWGC:RRAT",                Float64],
    "repetitionRateHeld"                => ["AWGC:RRAT:HOLD",           Bool],
    "runState"                          => ["AWGC:RSTATE?",             InstrumentState],
    "runMode"                           => ["AWGC:RMOD",                InstrumentTrigger],
    "run"                               => ["AWGC:RUN",                 InstrumentNoArgs],
    "stop"                              => ["AWGC:STOP",                InstrumentNoArgs],
    "sequencerPosition"                 => ["AWGC:SEQ:POS?",            Int64],
    # The following two methods may return AWGYes() if the window *cannot* be displayed.
    # They return the correct result (AWGNo()) if the window can be displayed, but is not displayed.
    "sequenceWindowDisplayed"           => ["DISP:WIND1:STAT",          Bool],
    "waveformWindowDisplayed"           => ["DISP:WIND2:STAT",          Bool],
    "forceEvent"                        => ["EVEN",                     InstrumentNoArgs],
    "eventImpedance"                    => ["EVEN:IMP",                 InstrumentImpedance],
    "eventJumpTiming"                   => ["EVEN:JTIM",                InstrumentTiming],
    "eventLevel"                        => ["EVEN:LEV",                 Float64],
    "eventSlope"                        => ["EVEN:POL",                 InstrumentEventSlope],
    "outputFilterFrequency"             => ["OUTP#:FILT:FREQ",          Float64],
    "outputState"                       => ["OUTP#:STAT",               Bool],
    "sequencerGOTOTarget"               => ["SEQ:ELEM#:GOTO:IND",       Int64],
    "sequencerGOTOState"                => ["SEQ:ELEM#:GOTO:STAT",      Bool],
    "sequencerEventJumpTarget"          => ["SEQ:ELEM#:JTAR:IND",       Int64],
    "sequencerLoopCount"                => ["SEQ:ELEM#:LOOP:COUN",      Int64],
    "sequencerInfiniteLoop"             => ["SEQ:ELEM#:LOOP:INF",       Bool],
    "sequencerLength"                   => ["SEQ:LENG",                 Int64],
    "forceSequenceJump"                 => ["SEQ:JUMP",                 InstrumentNoArgs],
    "externalInputAddsToOutput"         => ["SOUR#:COMB:FEED",          ASCIIString],
    "analogOutputDelayInSeconds"        => ["SOUR#:DELAY",              Float64],
    "analogOutputDelayInPoints"         => ["SOUR#:DELAY:POIN",         Float64],
    "waveformLoadedInChannel"           => ["SOUR#:FUNC:USER",          ASCIIString],
    "markerDelay"                       => ["SOUR#:MARK#:DEL",          Float64],
    "referenceOscillatorFrequency"      => ["SOUR:ROSC:FREQ",           Float64],
    "referenceOscillatorMultiplier"     => ["SOUR:ROSC:MULT",           Int64],
    "referenceOscillatorSource"         => ["SOUR:ROSC:SOUR",           InstrumentOscillatorSource],
    "systemDate"                        => ["SYST:DATE",                Int64],
    "panelLocked"                       => ["SYST:KLOC",                InstrumentLock],
    "systemTime"                        => ["SYST:TIME",                Int64],
    "scpiVersion"                       => ["SYST:VERS?",               ASCIIString],
    "triggerImpedance"                  => ["TRIG:IMP",                 InstrumentImpedance],
    "triggerLevel"                      => ["TRIG:LEV",                 Float64],
    "triggerSlope"                      => ["TRIG:POL",                 InstrumentTriggerSlope],
    "triggerTimer"                      => ["TRIG:TIM",                 Float64],
    "triggerSource"                     => ["TRIG:SOUR",                InstrumentTriggerSource],
    "wavelistLength"                    => ["WLIST:SIZE?",              Int64]
)

for (fnName in keys(sfd))
    createStateFunction(AWG5014C,fnName,sfd[fnName][1],sfd[fnName][2])
end

# And now, the functions we decided to write by hand...

export runApplication, applicationState, validate
export hardwareSequencerType, loadAWGSettings, saveAWGSettings, clearWaveforms
export deleteUserWaveform, waveformIsPredefined, waveformTimestamp, waveformType
export waveformName, waveformLength, pullFromAWG, pushToAWG, newWaveform
export setAmplitudeVpp, amplitudeVpp, sampleRate, setSampleRate
export waveform, setWaveform, setVoltageOffset, voltageOffset
export phaseDegrees, setPhaseDegrees, phaseRadians, setPhaseRadians
export @allCh

"""
Macro for performing an operation on every channel,
provided the channel is the last argument of the function to be called.

Example: `@allCh setWaveform(awg,"*Sine10")`
"""
macro allCh(x::Expr)
    myargs = []

    for ch in 1:4
        n = copy(x)
        push!(n.args,Int64(ch))
        push!(myargs,n)
    end

    # esc forces evaluation of the expression in the macro's calling environment.
    esc(Expr(:block,myargs...))
end

"Get the output phase in degrees for a given channel."
function phaseDegrees(ins::AWG5014C, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    parse(query(ins,string("SOUR",ch,":PHAS?")))
end

"Set the output phase in degrees for a given channel."
function setPhaseDegrees(ins::AWG5014C, phase::Real, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    ph = phase+180.
    ph = mod(ph,360.)
    ph -= 180.
    parse(query(ins,string("SOUR",ch,":PHAS ",phase)))
end

"Get the output phase in radians for a given channel."
function phaseRadians(ins::AWG5014C, ch::Integer)
    phaseDegrees(ins,ch) * π / 180.
end

"Set the output phase in radians for a given channel."
function setPhaseRadians(ins::AWG5014C, phase::Real, ch::Integer)
    setPhaseDegrees(ins, phase*180./π, ch)
end

"Get the voltage offset for a given channel."
function voltageOffset(ins::AWG5014C, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    parse(query(ins,string("SOUR",ch,":VOLT:OFFS?")))
end

"Set the voltage offset between -2.25 V and 2.25 V for a given channel."
function setVoltageOffset(ins::AWG5014C, voff::Real, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    @assert (-2.25 <= voff <= 2.25) "Offset out of range."
    write(ins,string("SOUR",ch,":VOLT:OFFS ",voff))
end

"Get the waveform name for a given channel."
function waveform(ins::AWG5014C, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    query(ins,string("SOUR",ch,":WAV?"))
end

"Set the waveform by name for a given channel."
function setWaveform(ins::AWG5014C, name::ASCIIString, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    write(ins,string("SOUR",ch,":WAV ",quoted(name)))
end

"Set Vpp for a given channel between 0.05 V and 2 V."
function setAmplitudeVpp(ins::AWG5014C, ampl::Real, ch::Integer)
    @assert (0.05 <= ampl <= 2) "Amplitude out of range."
    @assert (1 <= ch <= 4) "Channel out of range."
    write(ins,string("SOUR",ch,":VOLT ",ampl))
end

"Get Vpp for a given channel."
function amplitudeVpp(ins::AWG5014C, ch::Integer)
    @assert (1 <= ch <= 4) "Channel out of range."
    parse(query(ins,string("SOUR",ch,":VOLT?")))
end

"Set the sample rate in Hz between 10 MHz and 10 GHz. Output rate = sample rate / number of points."
function setSampleRate(ins::AWG5014C, rate::Real)
    @assert (10e6 <= rate <= 10e9) "Sample rate out of range."
    write(ins,string("SOUR:FREQ ",rate))
end

"Get the sample rate in Hz. Output rate = sample rate / number of points."
function sampleRate(ins::AWG5014C)
    parse(query(ins,"SOUR:FREQ?"))
end

"Run an application, e.g. SerialXpress"
function runApplication(ins::AWG5014C, app::ASCIIString)
    write(ins,"AWGC:APPL:RUN \""+app+"\"")
end

function applicationState(ins::AWG5014C, app::ASCIIString)
    query(ins,"AWGC:APPL:STAT? \""+app+"\"") == 0 ? InstrumentStopState(ins) : InstrumentRunState(ins)
end

function hardwareSequencerType(ins::AWG5014C)
    chomp(query(ins,"AWGC:SEQ:TYPE?")) == "HARD" ? InstrumentYes(ins) : InstrumentNo(ins)
end

function loadAWGSettings(ins::AWG5014C,filePath::ASCIIString)
    write(ins,string("AWGC:SRES \"",filePath,"\""))
end

function saveAWGSettings(ins::AWG5014C,filePath::ASCIIString)
    write(ins,string("AWGC:SSAV \"",filePath,"\""))
end

function clearWaveforms(ins::AWG5014C)
    write(ins,"SOUR1:FUNC:USER \"\"")
    write(ins,"SOUR2:FUNC:USER \"\"")
    write(ins,"SOUR3:FUNC:USER \"\"")
    write(ins,"SOUR4:FUNC:USER \"\"")
end

function deleteWaveform(ins::AWG5014C, name::ASCIIString)
    write(ins, "WLIS:WAV:DEL "*quoted(name))
end

function newWaveform{T<:AWG5014CWaveformType}(ins::AWG5014C, name::ASCIIString, size::Integer, wvtype::Type{T})
    newWaveform(ins, name, size, wvtype(ins))
end

function newWaveform(ins::AWG5014C, name::ASCIIString, numPoints::Integer, wvtype::AWG5014CWaveformType)
    write(ins, "WLIS:WAV:NEW "*quoted(name)*","*string(numPoints)*","*wvtype.state)
end

function resampleWaveform(ins::AWG5014C, name::ASCIIString, points::Integer)
    write(ins, "WLIS:WAV:RESA "*quoted(name)*","*string(points))
end

function normalizeWaveform{T<:AWG5014CNormalization}(ins::AWG5014C, name::ASCIIString, norm::Type{T})
    normalizeWaveform(ins,name,norm(ins))
end

function normalizeWaveform(ins::AWG5014C, name::ASCIIString, norm::AWG5014CNormalization)
    write(ins, "WLIS:WAV:NORM "*quoted(name)*","*norm.state)
end

"Uses Julia style indexing (begins at 1) to retrieve the name of a waveform."
function waveformName(ins::AWG5014C, num::Integer)
    strip(query(ins, "WLIST:NAME? "*string(num-1)),'"')
end

function waveformLength(ins::AWG5014C, name::ASCIIString)
    parse(query(ins, "WLIST:WAV:LENG? "*quoted(name)))
end

function waveformIsPredefined(ins::AWG5014C, name::ASCIIString)
    Bool(parse(query(ins,"WLIST:WAV:PRED? "*quoted(name))))
end

function waveformExists(ins::AWG5014C, name::ASCIIString)
    for (i = 1:wavelistLength(ins))
        if (name == waveformName(ins,i))
            return true
        end
    end

    return false
end

function waveformTimestamp(ins::AWG5014C, name::ASCIIString)
    InstrumentASCIIString(ins, query(ins,"WLIS:WAV:TST? "*quoted(name)))
end

"Returns the type of the waveform. The AWG hardware ultimately uses an `IntWaveform` but `RealWaveform` is more convenient."
function waveformType(ins::AWG5014C, name::ASCIIString)
    AWG5014CWaveformType(ins, query(ins,"WLIS:WAV:TYPE? "*quoted(name)))
end

"Push data to the AWG, performing checks and generating errors as appropriate."
function pushToAWG{T<:AWG5014CWaveformType}(ins::AWG5014C, name::ASCIIString, awgData::AWG5014CData, wvType::Type{T}, resampleOk::Bool=false)
    pushToAWG(ins,name,awgData,wvType(ins),resampleOk)
end

function pushToAWG(ins::AWG5014C, name::ASCIIString, awgData::AWG5014CData, wvType::AWG5014CWaveformType, resampleOk::Bool=false)

    # First validate the awgData
    validate(awgData, wvType)

    # If the waveform does not exist, create it
    if (!waveformExists(ins,name))
        newWaveform(ins,name,length(awgData.data),wvType)
    else
        # Otherwise, do some checks.
        # First, is it predefined?
        if (waveformIsPredefined(ins,name))
            error("Cannot overwrite predefined waveform.")
        end

        # Is the type different than requested?
        # We are unable to modify an existing waveform's type, so the best thing to do is bail.
        if (typeof(waveformType(ins,name)) != typeof(wvType))
            error("Existing waveform type differs. If you insist on this type, you need to delete the waveform first, with possible consequences for sequencing.")
        end

        # Is the waveform the wrong length?
        if (length(awgData.data) != waveformLength(ins,name))
            if (resampleOk)
                resampleWaveform(awg,name,length(awgData.data))
            else
                error("Existing waveform length differs. Pass `true` as the final argument to override; adjust sample rate if needed.")
            end
        end
    end

    pushLowLevel(ins,name,awgData,typeof(wvType))

end

"Takes care of the dirty work in pushing the data to the AWG."
function pushLowLevel(ins::AWG5014C, name::ASCIIString, awgData::AWG5014CData, wvType::Type{RealWaveform{ASCIIString}})
    buf = IOBuffer()
    for (i in 1:length(awgData.data))
        # AWG wants little endian data
        Base.write(buf, htol(awgData.data[i]))
        # Write marker bits
        Base.write(buf, UInt8(awgData.marker1[i]) << 6 | UInt8(awgData.marker2[i]) << 7)
    end
    binBlockWrite(ins, "WLIST:WAV:DATA "*quoted(name)*",",takebuf_array(buf))
end

function pushLowLevel(ins::AWG5014C, name::ASCIIString, awgData::AWG5014CData, wvType::Type{IntWaveform{ASCIIString}})
    buf = IOBuffer()
    for (i in 1:length(awgData.data))
        value = (awgData.data)[i]
        value = (value+1.0)/2.0         # now it is in the range [0.0, 1.0]
        value = UInt16(round(value*offsetPlusPPOver2))  # now it is in the valid integer range
        value = value | (UInt16(awgData.marker1[i]) << 14)  # set marker bit 1
        value = value | (UInt16(awgData.marker2[i]) << 15)  # set marker bit 2 too
        Base.write(buf, htol(value))    # make sure we send little endian
    end
    binBlockWrite(ins, "WLIST:WAV:DATA "*quoted(name)*",",takebuf_array(buf))
end

"Validates data to be pushed to the AWG to check for internal consistency and appropriate range."
function validate(awgData::AWG5014CData, wvType::AWG5014CWaveformType)
    # Length checks
    if (length(awgData.data) != length(awgData.marker1) != length(awgData.marker2))
        error("Data and marker lengths are not the same.")
    end

    nb = nBytes(wvType)
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

function nBytes(wvType::RealWaveform)
    return 5
end

function nBytes(wvType::IntWaveform)
    return 2
end

"Pull data from the AWG, performing checks and generating errors as appropriate."
function pullFromAWG(ins::AWG5014C, name::ASCIIString)

    if (!waveformExists(ins,name))
        error("Waveform does not exist.")
    end

    typ = waveformType(ins, name)
    pullLowLevel(ins,name,typ)

end

"Takes care of the dirty work in pulling data from the AWG."
function pullLowLevel(ins::AWG5014C, name::ASCIIString, wvType::RealWaveform)

    len = waveformLength(ins, name)

    write(ins,"WLIST:WAV:DATA? "*quoted(name))
    io = binBlockReadAvailable(ins)

    samples = Int64(floor((io.size-(io.ptr-1))/5.))

    amp =  Vector{Float32}(samples)
    marker1 = Vector{Bool}(samples)
    marker2 = Vector{Bool}(samples)

    for (i=1:samples)
        amp[i] = ltoh(Base.read(io,Float32))
        markers = Base.read(io,UInt8)
        marker1[i] = Bool((markers >> 6) & UInt8(1))
        marker2[i] = Bool((markers >> 7) & UInt8(1))
    end

    AWG5014CData(amp,marker1,marker2)
end

function pullLowLevel(ins::AWG5014C, name::ASCIIString, wvType::IntWaveform)

    len = waveformLength(ins, name)

    write(ins,"WLIST:WAV:DATA? "*quoted(name))
    io = binBlockReadAvailable(ins)

    # Handle pesky terminators.
    #
    # The logic here is that the binblock *may* end in \r, \n, or \r\n.
    # This seems to depend on the communication protocol, e.g. INSTR vs SOCKET.
    #
    # So we just assume an extra byte is a terminator, but explicitly check if
    # we have two extra bytes, in which case we throw that out.

    pointer = io.ptr
    seek(io,io.size-2)
    finalTwo = ltoh(Base.read(io,UInt16))
    seek(io,pointer-1)
    samples = Int64(floor((io.size-(io.ptr-1))/2.))

    if (finalTwo == 0x0a0d) # this just means the last two characters were \r\n
        samples -= 1
    end

    amp =  Vector{Float32}(samples)
    marker1 = Vector{Bool}(samples)
    marker2 = Vector{Bool}(samples)

    for (i=1:samples)
        sample = ltoh(Base.read(io,UInt16))
        marker1[i] = Bool((sample >> 14) & UInt16(1))
        marker2[i] = Bool((sample >> 15) & UInt16(1))
        sample = sample & maximumValue
        amp[i] = Float32((sample/offsetPlusPPOver2)*2.0 - 1.0)
    end

    AWG5014CData(amp,marker1,marker2)
end
