### Keysight / Agilent E8257D
module E8257DModule

## Import packages
import VISA

## Import our modules
importall PainterQB                 # All the stuff in InstrumentDefs, etc.
include("../Metaprogramming.jl")

export E8257D

export E8257DStimulus
export E8257DPowerStimulus, E8257DFrequencyStimulus, source

export FlatnessCorrection
export Frequency
export FrequencyMultiplier
export FrequencyStart
export FrequencyStop
export FrequencyStep
export FrequencyOffsetLevel
export FrequencyOffset
export FrequencyReferenceLevel
export FrequencyReference
export OutputBlanking
export OutputBlankingAuto
export Power
export PowerLimit
export PowerLimitAdjustable
export PowerStart
export PowerStop
export PowerStep
export PowerOffset
export PowerReference
export PowerReferenceLevel
export PowerSearchProtection
export PowerOptimizeSNR
export AttenuatorAuto
export ALCBandwidth
export ALCBandwidthAuto
export ALC
export ALCLevel
export SetFrequencyReference
export SetPhaseReference
export OutputSettled
export Output

export flatnesscorrectionfile_load, flatnesscorrectionfile_save
export boards, cumulativeattenuatorswitches, cumulativepowerons, cumulativeontime
export options, options_verbose, revision

type E8257D <: InstrumentVISA
    vi::(VISA.ViSession)
    writeTerminator::ASCIIString
    model::AbstractString
    E8257D(x) = begin
        ins = new()
        ins.vi = x
        ins.writeTerminator = "\n"
        ins.model = "E8257D"
        VISA.viSetAttribute(ins.vi, VISA.VI_ATTR_TERMCHAR_EN, UInt64(1))
        ins
    end

    E8257D() = new()
end

abstract E8257DStimulus <: Stimulus

type E8257DPowerStimulus <: E8257DStimulus
    ins::E8257D
#   label::Label
    val::AbstractFloat
end

type E8257DFrequencyStimulus <: E8257DStimulus
    ins::E8257D
#   label::Label
    val::AbstractFloat
end

function source(ch::E8257DPowerStimulus, val::Real)
    ch.val = val
    configure(ch.ins,Power,val)
end

function source(ch::E8257DFrequencyStimulus, val::Real)
    ch.val = val
    configure(ch.ins,Frequency,val)
end

abstract FlatnessCorrection      <: InstrumentProperty
abstract Frequency               <: InstrumentProperty
abstract FrequencyMultiplier     <: InstrumentProperty
abstract FrequencyStep           <: InstrumentProperty
abstract FrequencyOffsetLevel    <: InstrumentProperty
abstract FrequencyOffset         <: InstrumentProperty
abstract FrequencyReferenceLevel <: InstrumentProperty
abstract FrequencyReference      <: InstrumentProperty
abstract OutputBlanking          <: InstrumentProperty
abstract OutputBlankingAuto      <: InstrumentProperty
abstract Power                   <: InstrumentProperty
abstract PowerLimit              <: InstrumentProperty
abstract PowerLimitAdjustable    <: InstrumentProperty
abstract PowerStart              <: InstrumentProperty
abstract PowerStop               <: InstrumentProperty
abstract PowerStep               <: InstrumentProperty
abstract PowerOffset             <: InstrumentProperty
abstract PowerReference          <: InstrumentProperty
abstract PowerReferenceLevel     <: InstrumentProperty
abstract PowerSearchProtection   <: InstrumentProperty
abstract PowerOptimizeSNR        <: InstrumentProperty
abstract AttenuatorAuto          <: InstrumentProperty
abstract ALCBandwidth            <: InstrumentProperty
abstract ALCBandwidthAuto        <: InstrumentProperty
abstract ALC                     <: InstrumentProperty
abstract ALCLevel                <: InstrumentProperty
abstract SetFrequencyReference   <: InstrumentProperty
abstract SetPhaseReference       <: InstrumentProperty
abstract OutputSettled           <: InstrumentProperty

responses = Dict(

    :Network              => Dict("DHCP" => :DHCP,
                                  "MAN"  => :ManualNetwork),

    :TriggerSource        => Dict("IMM"  => :InternalTrigger,
                                  "EXT"  => :ExternalTrigger,
                                  "KEY"  => :ManualTrigger,
                                  "BUS"  => :BusTrigger),

    :OscillatorSource     => Dict("INT"  => :InternalOscillator,
                                  "EXT"  => :ExternalOscillator)
)

generate_handlers(E8257D, responses)

commands = [
    ("TRIG:SOUR",                           TriggerSource),
    ("TRIG:OUTP:POL",                       TriggerOutputPolarity),
    ("SOURce:ROSCillator:SOURce?",          OscillatorSource),

    ("SOURce:CORRection:STATe",             FlatnessCorrection,      Bool),
    ("SOURce:FREQuency:FIXed",              Frequency,               AbstractFloat),
    ("SOURce:FREQuency:MULTiplier",         FrequencyMultiplier,     Int),
    ("SOURce:FREQuency:STARt",              FrequencyStart,          AbstractFloat),
    ("SOURce:FREQuency:STOP",               FrequencyStop,           AbstractFloat),
    ("SOURce:FREQuency:STEP",               FrequencyStep,           AbstractFloat),
    ("SOURce:FREQuency:OFFSet",             FrequencyOffsetLevel,    AbstractFloat),
    ("SOURce:POWer:REFerence:STATe",        FrequencyOffset,         Bool),
    ("SOURce:FREQuency:REFerence",          FrequencyReferenceLevel, AbstractFloat),
    ("SOURce:FREQuency:REFerence:STATe",    FrequencyReference,      Bool),
    ("SOURce:OUTPut:BLANking:STATe",        OutputBlanking,          Bool),
    ("SOURce:OUTPut:BLANking:AUTO",         OutputBlankingAuto,      Bool),
    ("SOURce:POWer",                        Power,                   AbstractFloat),
    ("SOURce:POWer:LIMit:MAX",              PowerLimit,              AbstractFloat),
    ("SOURce:POWer:LIMit:MAX:ADJust",       PowerLimitAdjustable,    Bool),
    ("SOURce:POWer:STARt",                  PowerStart,              AbstractFloat),
    ("SOURce:POWer:STOP",                   PowerStop,               AbstractFloat),
    ("SOURce:POWer:LEVel:STEP",             PowerStep,               AbstractFloat),
    ("SOURce:POWer:LEVel:OFFSet",           PowerOffset,             AbstractFloat),
    ("SOURce:POWer:REFerence:STATe",        PowerReference,          Bool),
    ("SOURce:POWer:REFerence",              PowerReferenceLevel,     AbstractFloat),
    ("SOURce:POWer:PROTection:STATe",       PowerSearchProtection,   Bool),
    ("SOURce:POWer:NOISe:STATe",            PowerOptimizeSNR,        Bool),
    ("SOURce:POWer:ATTenuation:AUTO",       AttenuatorAuto,          Bool),
    ("SOURce:PHASe:ADJust",                 Phase,                   AbstractFloat),
    ("SOURce:POWer:ALC:BANDwidth",          ALCBandwidth,            AbstractFloat),
    ("SOURce:POWer:ALC:BANDwidth:AUTO",     ALCBandwidthAuto,        Bool),
    ("SOURce:POWer:ALC:STATe",              ALC,                     Bool),
    ("SOURce:POWer:ALC:LEVel",              ALCLevel,                AbstractFloat),
    ("SOURce:FREQuency:REFerence:SET",      SetFrequencyReference,   NoArgs),
    ("SOURce:PHASe:REFerence",              SetPhaseReference,       NoArgs),
    (":OUTPut:SETTled?",                    OutputSettled,           NoArgs),
    (":OUTPut",                             Output,                  Bool)
]

for args in commands
    generate_inspect(E8257D,args...)
    args[1][end] != '?' && generate_configure(E8257D,args...)
end

flatnesscorrectionfile_load(ins::E8257D, file::ASCIIString) =
    write(ins, "SOURce:CORRection:FLATness:LOAD \""*file*"\"")

flatnesscorrectionfile_save(ins::E8257D, file::ASCIIString) =
    write(ins, "SOURce:CORRection:FLATness:STORe \""*file*"\"")

boards(ins::E8257D)                       = ask(ins,"DIAGnostic:INFOrmation:BOARds?")
cumulativeattenuatorswitches(ins::E8257D) = ask(ins,"DIAGnostic:INFOrmation:CCOunt:ATTenuator?")
cumulativepowerons(ins::E8257D)           = ask(ins,"DIAGnostic:INFOrmation:CCOunt:PON?")
cumulativeontime(ins::E8257D)             = ask(ins,"DIAGnostic:INFOrmation:OTIMe?")
options(ins::E8257D)                      = ask(ins,"DIAGnostic:INFOrmation:OPTions?")
options_verbose(ins::E8257D)              = ask(ins,"DIAGnostic:INFOrmation:OPTions:DETail?")
revision(ins::E8257D)                     = ask(ins,"DIAGnostic:INFOrmation:REVision?")

end
