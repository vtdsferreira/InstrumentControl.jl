### Keysight / Agilent E5071C
module E5071CModule

## Import packages
import VISA

## Import our modules
importall PainterQB                 # All the stuff in InstrumentDefs, etc.
include("../Metaprogramming.jl")

export E5071C

export frequencydata, formatteddata

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
    "electricaldelay"              => [":CALC#:TRAC#:CORR:EDEL:TIME",  AbstractFloat],        #1-160, 1-16
    "electricalmedium"             => [":CALC#:TRAC#:CORR:EDEL:MED",   Medium],    #...
    "waveguidecutoff"              => [":CALC#:TRAC#:CORR:EDEL:WGC",   AbstractFloat],
    "phaseoffset"                  => [":CALC#:TRAC#:CORR:OFFS:PHAS",  AbstractFloat],
    "dataformat"                   => [":CALC#:TRAC#:FORM",            DataRepresentation],
    "num_traces"                   => [":CALC#:PAR:COUN",              Int],        #1-160, arg: 1-9
    "smoothingaperture"            => [":CALC#:SMO:APER",              AbstractFloat],
    "smoothingon"                  => [":CALC1:SMO:STAT",              Bool],
    "markeron"                     => [":CALC#:MARK#",                 Bool],
    "setactivemarker"              => [":CALC#:MARK#:ACT",             NoArgs],
    "marker_x"                     => [":CALC#:MARK#:X",               AbstractFloat],
    "marker_y"                     => [":CALC#:MARK#:Y?",              AbstractFloat],        #:CALC{1-160}:MARK{1-9}:DATA
    "marker_search"                => [":CALC#:MARK#:FUNC:EXEC",       NoArgs],
    #:CALC{1-160}:MARK{1-10}:SET
    "setactivetrace"               => [":CALC#:PAR#:SEL",              NoArgs],
    "measurementparameter"         => [":CALC#:PAR#:DEF",              SParameter],
    "frequencydisplayed"           => [":DISP:ANN:FREQ",               Bool],
    "displayenabled"               => [":DISP:ENAB",                   Bool],
    "setactivechannel"             => [":DISP:WIND#:ACT",              NoArgs],
    "channelmaximized"             => [":DISP:MAX",                    Bool],
    "windowlayout"                 => [":DISP:SPL",                    ASCIIString],
    "tracemaximized"               => [":DISP:WIND#:MAX",              Bool], #1-160
    "graphlayout"                  => [":DISP:WIND#:SPL",              ASCIIString], #1-36 (why?)
    "autoscale"                    => [":DISP:WIND#:TRAC#:Y:AUTO",     NoArgs],  #1-160, 1-16
    "yscaleperdivision"            => [":DISP:WIND#:TRAC#:Y:PDIV",     AbstractFloat],
    "yreferencelevel"              => [":DISP:WIND#:TRAC#:Y:RLEV",     AbstractFloat],
    "yreferenceposition"           => [":DISP:WIND#:TRAC#:Y:RPOS",     Int],
    "datatraceon"                  => [":DISP:WIND#:TRAC#:STAT",       Bool],
    "ydivisions"                   => [":DISP:WIND#:Y:DIV",            Int],
    "clearaveraging"               => [":SENS#:AVER:CLE",              NoArgs],    #1-160
    "averagingfactor"              => [":SENS#:AVER:COUN",             Int],            #1-160
    "averaging"                    => [":SENS#:AVER",                  Bool],
    "if_bandwidth"                 => [":SENS1:BAND",                  AbstractFloat],
    "power_sweepfrequency"         => [":SENS#:FREQ",                  AbstractFloat],

    #ch 1--9
    "frequency_start"              => [":SENS#:FREQ:STAR",             AbstractFloat],
    "frequency_stop"               => [":SENS#:FREQ:STOP",             AbstractFloat],
    "frequency_center"             => [":SENS#:FREQ:CENT",             AbstractFloat],
    "frequency_span"               => [":SENS#:FREQ:SPAN",             AbstractFloat],
    #2 -- 20001
    "num_points"                   => [":SENS#:SWE:POIN",              Int],
    "power_level"                  => [":SOUR#:POW",                   AbstractFloat],    # 1-160
    "power_coupled"                => [":SOUR#:POW:PORT:COUP",         Bool],
    #ch 1-9 port 1-6
    "power_port"                   => [":SOUR#:POW:PORT#",             AbstractFloat],
    "power_slopelevel"             => [":SOUR#:POW:SLOP",              AbstractFloat],    #dB/GHz
    "power_slopeon"                => [":SOUR#:POW:SLOP:STAT",         Bool],

    "averagingtriggeron"           => [":TRIG:AVER",                   Bool],
    "externaltrigger_slope"        => [":TRIG:SEQ:EXT:SLOP",           TriggerSlope],
    "externaltrigger_delay"        => [":TRIG:EXT:DEL",                AbstractFloat],
    "externaltrigger_lowlatencyon" => [":TRIG:EXT:LLAT",               Bool],
    "triggeroutput"                => [":TRIG:OUTP:STAT",              Bool],
    "trigger_outputpolarity"       => [":TRIG:OUTP:POL",               Polarity],
    "trigger_outputtiming"         => [":TRIG:OUTP:POS",               Timing],
    "pointtrigger"                 => [":TRIG:POIN",                   Bool],
    "trigger_source"               => [":TRIG:SOUR",                   TriggerSource],
    "output_on"                     => [":OUTP",                        Bool]
)

for (fnName in keys(sfd))
    createStateFunction(E5071C,fnName,sfd[fnName][1],sfd[fnName][2])
end

function frequencydata(ins::E5071C, channel::Integer, trace::Integer)
    data = query_ins(ins,string(":CALC",channel,":TRAC",trace,":DATA:XAX?"))

    # Return an array of numbers
    map(parse,split(data,",",keep=false))
end

function formatteddata(ins::E5071C, channel::Integer, trace::Integer)
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

end
