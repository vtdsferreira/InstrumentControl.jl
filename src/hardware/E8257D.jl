export E8257D
type E8257D <: InstrumentVISA
    vi::PyObject     # this is the GpibInstrument object!
    E8257D(x) = new(x)
    E8257D() = new()
end

export E8257DOutput
abstract E8257DOutput <: Output

export E8257DPowerOutput
type E8257DPowerOutput <: E8257DOutput
    ins::E8257D
#   label::Label
    val::Float64
end

export E8257DFrequencyOutput
type E8257DFrequencyOutput <: E8257DOutput
    ins::E8257D
#   label::Label
    val::Float64
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

    :InstrumentNetwork              => Dict("DHCP" => :DHCP,
                                            "MAN"  => :ManualNetwork),

    :InstrumentTriggerSource        => Dict("IMM"  => :InternalTrigger,
                                            "EXT"  => :ExternalTrigger,
                                            "KEY"  => :ManualTrigger,
                                            "BUS"  => :BusTrigger),

    :InstrumentOscillatorSource     => Dict("INT"  => :InternalOscillator,
                                            "EXT"  => :ExternalOscillator)
)

generateResponseHandlers(E8257D, responseDictionary)

sfd = Dict(
    "screenshot"                 => ["DISP:CAPT",                           InstrumentNoArgs],
    "numFlatnessCorrectionPts"   => ["SOURce:CORRection:FLATness:POINts?",  Int64],
    "factoryFlatnessCorrection"  => ["SOURce:CORRection:FLATness:PRESet",   InstrumentNoArgs],
    "flatnessCorrectionOn"       => ["SOURce:CORRection:STATe",             Bool],
    "frequencyBandOn"            => ["SOURce:FREQuency:CHANnels:STATe",     Bool],
    "frequency"                  => ["SOURce:FREQuency:FIXed",              Float64],            # units?
    "stepFrequencyUp"            => ["SOURce:FREQuency:FIXed UP",           InstrumentNoArgs],
    "stepFrequencyDown"          => ["SOURce:FREQuency:FIXed DOWN",         InstrumentNoArgs],
    "frequencyMultiplier"        => ["SOURce:FREQuency:MULTiplier",         Int64],
    "frequencyOffsetOn"          => ["SOURce:FREQuency:OFFSet:STATe",       Bool],
    "frequencyOffset"            => ["SOURce:FREQuency:OFFSet",             Float64],
    "frequencyReference"         => ["SOURce:FREQuency:REFerence",          Float64],
    "setFrequencyReference"      => ["SOURce:FREQuency:REFerence:SET",      InstrumentNoArgs],
    "frequencyReferenceOn"       => ["SOURce:FREQuency:REFerence:STATe",    Bool],
    "startFrequency"             => ["SOURce:FREQuency:STARt",              Float64],
    "stopFrequency"              => ["SOURce:FREQuency:STOP",               Float64],
    "frequencyIncrement"         => ["SOURce:FREQuency:STEP",               Float64],
    "phase"                      => ["SOURce:PHASe:ADJust",                 Float64],            #radians?
    "setPhaseReference"          => ["SOURce:PHASe:REFerence",              InstrumentNoArgs],
    "referenceOscillatorSource"  => ["SOURce:ROSCillator:SOURce?",          InstrumentOscillatorSource],
    "autoBlanking"               => ["SOURce:OUTPut:BLANking:AUTO",         Bool],
    "blankingOn"                 => ["SOURce:OUTPut:BLANking:STATe",        Bool],
    "outputSettled"              => [":OUTPut:SETTled?",                    InstrumentNoArgs],
    "powerOn"                    => [":OUTPut",                             Bool],
    "alcBandwidth"               => ["SOURce:POWer:ALC:BANDwidth",          Float64],
    "alcAutoBandwidth"           => ["SOURce:POWer:ALC:BANDwidth:AUTO",     Bool],
    "alcLevel"                   => ["SOURce:POWer:ALC:LEVel",              Float64],            # step attenuator
    "alcPowerSearchRefLevel"     => ["SOURce:POWer:ALC:SEARch:REF:LEVel",   Float64],
    "alcPowerSearchStart"        => ["SOURce:POWer:ALC:SEARch:SPAN:START",  Float64],            # may want units?
    "alcPowerSearchStop"         => ["SOURce:POWer:ALC:SEARch:SPAN:STOP",   Float64],            # may want units?
    "alcPowerSearchSpanOn"       => ["SOURce:POWer:ALC:SEARch:SPAN:STATe",  Bool],
    "alcOn"                      => ["SOURce:POWer:ALC:STATe",              Bool],
    "triggerSweep"               => ["SOURce:TSWeep",                       InstrumentNoArgs],
    "attenuation"                => ["SOURce:POWer:ATTenuation",            Float64],            # step attenuator    # may want units?
    "autoAttenuator"             => ["SOURce:POWer:ATTenuation:AUTO",       Bool],        # step attenuator # docstring
    "autoOptimizeSNROn"          => ["SOURce:POWer:NOISe:STATe",            Bool],
    "outputPowerLimitAdjust"     => ["SOURce:POWer:LIMit:MAX:ADJust",       Bool],
    "outputPowerLimit"           => ["SOURce:POWer:LIMit:MAX",              Float64],            # units?
    "powerSearchProtection"      => ["SOURce:POWer:PROTection:STATe",       Bool],
    "powerOutputReference"       => ["SOURce:POWer:REFerence",              Float64],            # units?
    "powerOutputReferenceOn"     => ["SOURce:POWer:REFerence:STATe",        Bool],
    "startPower"                 => ["SOURce:POWer:STARt",                  Float64],            # units?
    "stopPower"                  => ["SOURce:POWer:STOP",                   Float64],            # units?
    "powerOffset"                => ["SOURce:POWer:LEVel:OFFSet",           Float64],            # units?
    "power"                      => ["SOURce:POWer",                        Float64],            # units?
    "powerIncrement"             => ["SOURce:POWer:LEVel:STEP",             Float64],            # units?

    "lanConfiguration"           => ["SYST:COMM:LAN:CONF",                  InstrumentNetwork],    # IMPLEMENT ERROR HANDLING
    "lanHostname"                => ["SYSTem:COMMunicate:LAN:HOSTname",     InstrumentString],
    "lanIP"                      => ["SYSTem:COMMunicate:LAN:IP",           InstrumentString],
    "lanSubnet"                  => ["SYSTem:COMMunicate:LAN:SUBNet",       InstrumentString],
#    "systemDate"                  => ["SYST:DATE",                             Int64],
#    "systemTime"                  => ["SYST:TIME",                             Int64],
    "triggerOutputPolarity"      => ["TRIG:OUTP:POL",                       InstrumentPolarity],
    "triggerSource"              => ["TRIG:SOUR",                           InstrumentTriggerSource]
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
    write(ins, "SOURce:CORRection:FLATness:LOAD \""*file*"\"")
end

export saveFlatnessCorrectionFile
function saveFlatnessCorrectionFile(ins::E8257D, file::ASCIIString)
    write(ins, "SOURce:CORRection:FLATness:STORe \""*file*"\"")
end

export boards, cumulativeAttenuatorSwitches, cumulativePowerOns, cumulativeOnTime
export options, optionsVerbose, revision
boards(ins::E8257D)                       = query(ins,"DIAGnostic:INFOrmation:BOARds?")
cumulativeAttenuatorSwitches(ins::E8257D) = query(ins,"DIAGnostic:INFOrmation:CCOunt:ATTenuator?")
cumulativePowerOns(ins::E8257D)           = query(ins,"DIAGnostic:INFOrmation:CCOunt:PON?")
cumulativeOnTime(ins::E8257D)             = query(ins,"DIAGnostic:INFOrmation:OTIMe?")
options(ins::E8257D)                      = query(ins,"DIAGnostic:INFOrmation:OPTions?")
optionsVerbose(ins::E8257D)               = query(ins,"DIAGnostic:INFOrmation:OPTions:DETail?")
revision(ins::E8257D)                     = query(ins,"DIAGnostic:INFOrmation:REVision?")
