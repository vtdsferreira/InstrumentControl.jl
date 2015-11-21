### Keysight / Agilent E8257D
export E8257D
type E8257D <: InstrumentVISA
    vi::(VISA.ViSession)
    writeTerminator::ASCIIString

    E8257D(x) = begin
        ins = new()
        ins.vi = x
        ins.writeTerminator = "\n"
        VISA.viSetAttribute(ins.vi, VISA.VI_ATTR_TERMCHAR_EN, UInt64(1))
        ins
    end

    E8257D() = new()
end

export E8257DOutput
abstract E8257DOutput <: Output

export E8257DPowerOutput
type E8257DPowerOutput <: E8257DOutput
    ins::E8257D
#   label::Label
    val::AbstractFloat
end

export E8257DFrequencyOutput
type E8257DFrequencyOutput <: E8257DOutput
    ins::E8257D
#   label::Label
    val::AbstractFloat
end

export source
function source(ch::E8257DPowerOutput, val::Real)
    ch.val = val
    setPower(ch.ins,val)
end

function source(ch::E8257DFrequencyOutput, val::Real)
    ch.val = val
    setFrequency(ch.ins,val)
end

subtypeStateDictionary = Dict(

    :Network              => Dict("DHCP" => :DHCP,
                                  "MAN"  => :ManualNetwork),

    :TriggerSource        => Dict("IMM"  => :InternalTrigger,
                                  "EXT"  => :ExternalTrigger,
                                  "KEY"  => :ManualTrigger,
                                  "BUS"  => :BusTrigger),

    :OscillatorSource     => Dict("INT"  => :InternalOscillator,
                                  "EXT"  => :ExternalOscillator)
)

generateResponseHandlers(E8257D, responseDictionary)

sfd = Dict(
    "screenshot"                 => ["DISP:CAPT",                           NoArgs],
    "numFlatnessCorrectionPts"   => ["SOURce:CORRection:FLATness:POINts?",  Int],
    "factoryFlatnessCorrection"  => ["SOURce:CORRection:FLATness:PRESet",   NoArgs],
    "flatnessCorrectionOn"       => ["SOURce:CORRection:STATe",             Bool],
    "frequencyBandOn"            => ["SOURce:FREQuency:CHANnels:STATe",     Bool],
    "frequency"                  => ["SOURce:FREQuency:FIXed",              AbstractFloat],            # units?
    "stepFrequencyUp"            => ["SOURce:FREQuency:FIXed UP",           NoArgs],
    "stepFrequencyDown"          => ["SOURce:FREQuency:FIXed DOWN",         NoArgs],
    "frequencyMultiplier"        => ["SOURce:FREQuency:MULTiplier",         Int],
    "frequencyOffsetOn"          => ["SOURce:FREQuency:OFFSet:STATe",       Bool],
    "frequencyOffset"            => ["SOURce:FREQuency:OFFSet",             AbstractFloat],
    "frequencyReference"         => ["SOURce:FREQuency:REFerence",          AbstractFloat],
    "setFrequencyReference"      => ["SOURce:FREQuency:REFerence:SET",      NoArgs],
    "frequencyReferenceOn"       => ["SOURce:FREQuency:REFerence:STATe",    Bool],
    "startFrequency"             => ["SOURce:FREQuency:STARt",              AbstractFloat],
    "stopFrequency"              => ["SOURce:FREQuency:STOP",               AbstractFloat],
    "frequencyIncrement"         => ["SOURce:FREQuency:STEP",               AbstractFloat],
    "phase"                      => ["SOURce:PHASe:ADJust",                 AbstractFloat],            #radians?
    "setPhaseReference"          => ["SOURce:PHASe:REFerence",              NoArgs],
    "referenceOscillatorSource"  => ["SOURce:ROSCillator:SOURce?",          OscillatorSource],
    "autoBlanking"               => ["SOURce:OUTPut:BLANking:AUTO",         Bool],
    "blankingOn"                 => ["SOURce:OUTPut:BLANking:STATe",        Bool],
    "outputSettled"              => [":OUTPut:SETTled?",                    NoArgs],
    "powerOn"                    => [":OUTPut",                             Bool],
    "alcBandwidth"               => ["SOURce:POWer:ALC:BANDwidth",          AbstractFloat],
    "alcAutoBandwidth"           => ["SOURce:POWer:ALC:BANDwidth:AUTO",     Bool],
    "alcLevel"                   => ["SOURce:POWer:ALC:LEVel",              AbstractFloat],            # step attenuator
    "alcPowerSearchRefLevel"     => ["SOURce:POWer:ALC:SEARch:REF:LEVel",   AbstractFloat],
    "alcPowerSearchStart"        => ["SOURce:POWer:ALC:SEARch:SPAN:START",  AbstractFloat],            # may want units?
    "alcPowerSearchStop"         => ["SOURce:POWer:ALC:SEARch:SPAN:STOP",   AbstractFloat],            # may want units?
    "alcPowerSearchSpanOn"       => ["SOURce:POWer:ALC:SEARch:SPAN:STATe",  Bool],
    "alcOn"                      => ["SOURce:POWer:ALC:STATe",              Bool],
    "triggerSweep"               => ["SOURce:TSWeep",                       NoArgs],
    "attenuation"                => ["SOURce:POWer:ATTenuation",            AbstractFloat],            # step attenuator    # may want units?
    "autoAttenuator"             => ["SOURce:POWer:ATTenuation:AUTO",       Bool],        # step attenuator # docstring
    "autoOptimizeSNROn"          => ["SOURce:POWer:NOISe:STATe",            Bool],
    "outputPowerLimitAdjust"     => ["SOURce:POWer:LIMit:MAX:ADJust",       Bool],
    "outputPowerLimit"           => ["SOURce:POWer:LIMit:MAX",              AbstractFloat],            # units?
    "powerSearchProtection"      => ["SOURce:POWer:PROTection:STATe",       Bool],
    "powerOutputReference"       => ["SOURce:POWer:REFerence",              AbstractFloat],            # units?
    "powerOutputReferenceOn"     => ["SOURce:POWer:REFerence:STATe",        Bool],
    "startPower"                 => ["SOURce:POWer:STARt",                  AbstractFloat],            # units?
    "stopPower"                  => ["SOURce:POWer:STOP",                   AbstractFloat],            # units?
    "powerOffset"                => ["SOURce:POWer:LEVel:OFFSet",           AbstractFloat],            # units?
    "power"                      => ["SOURce:POWer",                        AbstractFloat],            # units?
    "powerIncrement"             => ["SOURce:POWer:LEVel:STEP",             AbstractFloat],            # units?

    "lanConfiguration"           => ["SYST:COMM:LAN:CONF",                  Network],    # IMPLEMENT ERROR HANDLING
    "lanHostname"                => ["SYSTem:COMMunicate:LAN:HOSTname",     ASCIIString],
    "lanIP"                      => ["SYSTem:COMMunicate:LAN:IP",           ASCIIString],
    "lanSubnet"                  => ["SYSTem:COMMunicate:LAN:SUBNet",       ASCIIString],
#    "systemDate"                  => ["SYST:DATE",                             Int],
#    "systemTime"                  => ["SYST:TIME",                             Int],
    "triggerOutputPolarity"      => ["TRIG:OUTP:POL",                       Polarity],
    "triggerSource"              => ["TRIG:SOUR",                           TriggerSource]
)

for (fnName in keys(sfd))
    createStateFunction(E8257D,fnName,sfd[fnName][1],sfd[fnName][2])
end

# setSystemDate(ins,insDateTime::InstrumentDateTime) = setSystemDate(ins,Dates.year(insDateTime.dateTime),
#                                                                        Dates.month(insDateTime.dateTime),
#                                                                        Dates.day(insDateTime.dateTime))
# setSystemTime(ins,insDateTime::InstrumentDateTime) = setSystemTime(ins,Dates.hour(insDateTime.dateTime),
#                                                                        Dates.minute(insDateTime.dateTime),
#                                                                        Dates.second(insDateTime.dateTime))

export loadFlatnessCorrectionFile
function loadFlatnessCorrectionFile(ins::E8257D, file::ASCIIString)
    write_ins(ins, "SOURce:CORRection:FLATness:LOAD \""*file*"\"")
end

export saveFlatnessCorrectionFile
function saveFlatnessCorrectionFile(ins::E8257D, file::ASCIIString)
    write_ins(ins, "SOURce:CORRection:FLATness:STORe \""*file*"\"")
end

export boards, cumulativeAttenuatorSwitches, cumulativePowerOns, cumulativeOnTime
export options, optionsVerbose, revision
boards(ins::E8257D)                       = query_ins(ins,"DIAGnostic:INFOrmation:BOARds?")
cumulativeAttenuatorSwitches(ins::E8257D) = query_ins(ins,"DIAGnostic:INFOrmation:CCOunt:ATTenuator?")
cumulativePowerOns(ins::E8257D)           = query_ins(ins,"DIAGnostic:INFOrmation:CCOunt:PON?")
cumulativeOnTime(ins::E8257D)             = query_ins(ins,"DIAGnostic:INFOrmation:OTIMe?")
options(ins::E8257D)                      = query_ins(ins,"DIAGnostic:INFOrmation:OPTions?")
optionsVerbose(ins::E8257D)               = query_ins(ins,"DIAGnostic:INFOrmation:OPTions:DETail?")
revision(ins::E8257D)                     = query_ins(ins,"DIAGnostic:INFOrmation:REVision?")
