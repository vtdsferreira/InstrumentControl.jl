### Keysight / Agilent E5071C
export E5071C
type E5071C <: InstrumentVISA
    vi::(VISA.ViSession)
    writeTerminator::ASCIIString

    E5071C(x) = begin
        ins = new()
        ins.vi = x
        ins.writeTerminator = "\n"
        VISA.viSetAttribute(ins.vi, VISA.VI_ATTR_TERMCHAR_EN, UInt64(1))
        ins
    end

    E5071C() = new()
end

responseDictionary = Dict(

    :Network            => Dict("DHCP" => :DHCP,
                                "MAN"  => :ManualNetwork),

    :TriggerSource      => Dict("INT"  => :InternalTrigger,
                                "EXT"  => :ExternalTrigger,
                                "MAN"  => :ManualTrigger,
                                "BUS"  => :BusTrigger),

    :Timing             => Dict("BEF"  => :Before,
                                "AFT"  => :After),

    :TriggerSlope       => Dict("POS"  => :RisingTrigger,
                                "NEG"  => :FallingTrigger),

    :Polarity           => Dict("POS"  => :PositivePolarity,
                                "NEG"  => :NegativePolarity),

    :Search             => Dict("MAX"  => :Max,
                                "MIN"  => :Min,
                                "PEAK" => :Peak,
                                "LPE"  => :LeftPeak,
                                "RPE"  => :RightPeak,
                                "TARG" => :Target,
                                "LTAR" => :LeftTarget,
                                "RTAR" => :RightTarget),

    :SParameter         => Dict("S11"  => :S11,
                                "S12"  => :S12,
                                "S21"  => :S21,
                                "S22"  => :S22),

    :Medium             => Dict("COAX" => :Coaxial,
                                "WAV"  => :Waveguide),

    :DataRepresentation => Dict("MLOG" => :LogMagnitude,
                                "PHAS" => :Phase,
                                "GDEL" => :GroupDelay,
                                "SLIN" => :SmithLinear,
                                "SLOG" => :SmithLog,
                                "SCOM" => :SmithComplex,
                                "SMIT" => :Smith,
                                "SADM" => :SmithAdmittance,
                                "PLIN" => :PolarLinear,
                                "PLOG" => :PolarLog,
                                "POL"  => :PolarComplex,
                                "MLIN" => :LinearMagnitude,
                                "SWR"  => :SWR,
                                "REAL" => :RealPart,
                                "IMAG" => :ImaginaryPart,
                                "UPH"  => :ExpandedPhase,
                                "PPH"  => :PositivePhase)
)

generateResponseHandlers(E5071C, responseDictionary)

sfd = Dict(
    "electricalDelay"              => [":CALC#:TRAC#:CORR:EDEL:TIME",  AbstractFloat],        #1-160, 1-16
    "electricalMedium"             => [":CALC#:TRAC#:CORR:EDEL:MED",   Medium],    #...
    "waveguideCutoffFrequency"     => [":CALC#:TRAC#:CORR:EDEL:WGC",   AbstractFloat],
    "phaseOffset"                  => [":CALC#:TRAC#:CORR:OFFS:PHAS",  AbstractFloat],
    "dataFormat"                   => [":CALC#:TRAC#:FORM",            DataRepresentation],
    "numberOfTraces"               => [":CALC#:PAR:COUN",              Int],        #1-160, arg: 1-9
    "smoothingAperture"            => [":CALC#:SMO:APER",              AbstractFloat],
    "smoothingOn"                  => [":CALC1:SMO:STAT",              Bool],
    "markerOn"                     => [":CALC#:MARK#",                 Bool],
    "setActiveMarker"              => [":CALC#:MARK#:ACT",             NoArgs],
    "markerX"                      => [":CALC#:MARK#:X",               AbstractFloat],
    "markerY"                      => [":CALC#:MARK#:Y?",              AbstractFloat],        #:CALC{1-160}:MARK{1-9}:DATA
    "markerSearch"                 => [":CALC#:MARK#:FUNC:EXEC",       NoArgs],
    #:CALC{1-160}:MARK{1-10}:SET
    "setActiveTrace"               => [":CALC#:PAR#:SEL",              NoArgs],
    "measurementParameter"         => [":CALC#:PAR#:DEF",              SParameter],
    "frequencyDisplayed"           => [":DISP:ANN:FREQ",               Bool],
    "displayEnabled"               => [":DISP:ENAB",                   Bool],
    "setActiveChannel"             => [":DISP:WIND#:ACT",              NoArgs],
    "channelMaximized"             => [":DISP:MAX",                    Bool],
    "windowLayout"                 => [":DISP:SPL",                    ASCIIString],
    "traceMaximized"               => [":DISP:WIND#:MAX",              Bool], #1-160
    "graphLayout"                  => [":DISP:WIND#:SPL",              ASCIIString], #1-36 (why?)
    "autoscale"                    => [":DISP:WIND#:TRAC#:Y:AUTO",     NoArgs],  #1-160, 1-16
    "yScalePerDivision"            => [":DISP:WIND#:TRAC#:Y:PDIV",     AbstractFloat],
    "yReferenceLevel"              => [":DISP:WIND#:TRAC#:Y:RLEV",     AbstractFloat],
    "yReferencePosition"           => [":DISP:WIND#:TRAC#:Y:RPOS",     Int],
    "dataTraceOn"                  => [":DISP:WIND#:TRAC#:STAT",       Bool],
    "yDivisions"                   => [":DISP:WIND#:Y:DIV",            Int],
    "clearAveraging"               => [":SENS#:AVER:CLE",              NoArgs],    #1-160
    "averagingFactor"              => [":SENS#:AVER:COUN",             Int],            #1-160
    "averagingOn"                  => [":SENS#:AVER",                  Bool],
    "IFBandwidth"                  => [":SENS1:BAND",                  AbstractFloat],
    "powerSweepFrequency"          => [":SENS#:FREQ",                  AbstractFloat],

    #ch 1--9
    "startFrequency"               => [":SENS#:FREQ:STAR",             AbstractFloat],
    "stopFrequency"                => [":SENS#:FREQ:STOP",             AbstractFloat],
    "centerFrequency"              => [":SENS#:FREQ:CENT",             AbstractFloat],
    "spanFrequency"                => [":SENS#:FREQ:SPAN",             AbstractFloat],
    #2 -- 20001
    "numberOfPoints"               => [":SENS#:SWE:POIN",              Int],
    "powerLevel"                   => [":SOUR#:POW",                   AbstractFloat],    # 1-160
    "powerCoupled"                 => [":SOUR#:POW:PORT:COUP",         Bool],
    #ch 1-9 port 1-6
    "portPower"                    => [":SOUR#:POW:PORT#",             AbstractFloat],
    "powerSlopeLevel"              => [":SOUR#:POW:SLOP",              AbstractFloat],    #dB/GHz
    "powerSlopeOn"                 => [":SOUR#:POW:SLOP:STAT",         Bool],

    "averagingTriggerOn"           => [":TRIG:AVER",                   Bool],
    "externalTriggerSlope"         => [":TRIG:SEQ:EXT:SLOP",           TriggerSlope],
    "externalTriggerDelay"         => [":TRIG:EXT:DEL",                AbstractFloat],
    "externalTriggerLowLatencyOn"  => [":TRIG:EXT:LLAT",               Bool],
    "triggerOutputOn"              => [":TRIG:OUTP:STAT",              Bool],
    "triggerOutputPolarity"        => [":TRIG:OUTP:POL",               Polarity],
    "triggerOutputTiming"          => [":TRIG:OUTP:POS",               Timing],
    "pointTriggerOn"               => [":TRIG:POIN",                   Bool],
    "triggerSource"                => [":TRIG:SOUR",                   TriggerSource],
    "powerOn"                      => [":OUTP",                        Bool],
)

for (fnName in keys(sfd))
    createStateFunction(E5071C,fnName,sfd[fnName][1],sfd[fnName][2])
end

export frequencyData, formattedData

function frequencyData(ins::E5071C, channel::Integer, trace::Integer)
    data = query_ins(ins,string(":CALC",channel,":TRAC",trace,":DATA:XAX?"))

    # Return an array of numbers
    map(parse,split(data,",",keep=false))
end

function formattedData(ins::E5071C, channel::Integer, trace::Integer)
    data = query_ins(ins,string(":CALC",channel,":TRAC",trace,":DATA:FDAT?"))

    # Return an array of numbers
    nums = map(parse,split(data,",",keep=false))
    half = convert(Int, length(nums) / 2)
    a = Array(AbstractFloat,half)
    b = Array(AbstractFloat,half)

    # Every other item should go in a separate collection
    for (i in 1:half)
        a[i] = nums[2*i-1]
        b[i] = nums[2*i]
    end

    # Return both collections
    (a,b)
end
