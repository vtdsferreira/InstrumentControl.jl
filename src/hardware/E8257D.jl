### Keysight / Agilent E8257D
module E8257DModule

## Import packages
import VISA

## Import our modules
importall PainterQB                 # All the stuff in InstrumentDefs, etc.
include("../Metaprogramming.jl")

export E8257D

export ALCBandwidth
export ALCBandwidthAuto
export ALC
export ALCLevel
export AttenuatorAuto
export FlatnessCorrection
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
export OutputSettled
export PowerLimit
export PowerLimitAdjustable
export PowerStart
export PowerStop
export PowerStep
export PowerOffsetLevel
export PowerReference
export PowerReferenceLevel
export PowerSearchProtection
export PowerOptimizeSNR
export SetFrequencyReference
export SetPhaseReference

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

responses = Dict(

    :Network              => Dict("DHCP" => :DHCP,
                                  "MAN"  => :ManualNetwork),

    :OscillatorSource     => Dict("INT"  => :InternalOscillator,
                                  "EXT"  => :ExternalOscillator),

    :TriggerSource        => Dict("IMM"  => :InternalTrigger,
                                  "EXT"  => :ExternalTrigger,
                                  "KEY"  => :ManualTrigger,
                                  "BUS"  => :BusTrigger),
)

generate_handlers(E8257D, responses)

abstract ALCBandwidth            <: NumericalProperty
abstract ALCBandwidthAuto        <: InstrumentProperty
abstract ALC                     <: InstrumentProperty
abstract ALCLevel                <: NumericalProperty
abstract AttenuatorAuto          <: InstrumentProperty
abstract FlatnessCorrection      <: InstrumentProperty
abstract FrequencyMultiplier     <: NumericalProperty
abstract FrequencyStep           <: NumericalProperty
abstract FrequencyOffsetLevel    <: NumericalProperty
abstract FrequencyOffset         <: InstrumentProperty
abstract FrequencyReferenceLevel <: NumericalProperty
abstract FrequencyReference      <: InstrumentProperty
abstract OutputBlanking          <: InstrumentProperty
abstract OutputBlankingAuto      <: InstrumentProperty
abstract OutputSettled           <: InstrumentProperty
abstract PowerLimit              <: NumericalProperty
abstract PowerLimitAdjustable    <: InstrumentProperty
abstract PowerStart              <: NumericalProperty
abstract PowerStop               <: NumericalProperty
abstract PowerStep               <: NumericalProperty
abstract PowerOffsetLevel        <: NumericalProperty
abstract PowerReference          <: InstrumentProperty
abstract PowerReferenceLevel     <: NumericalProperty
abstract PowerSearchProtection   <: InstrumentProperty
abstract PowerOptimizeSNR        <: InstrumentProperty
abstract SetFrequencyReference   <: InstrumentProperty
abstract SetPhaseReference       <: InstrumentProperty

commands = [
    ("SOURce:ROSCillator:SOURce?",          OscillatorSource),
    ("TRIG:OUTP:POL",                       TriggerOutputPolarity),
    ("TRIG:SOUR",                           TriggerSource),

    ("SOURce:POWer:ALC:STATe",              ALC,                     Bool),
    ("SOURce:POWer:ALC:BANDwidth",          ALCBandwidth,            AbstractFloat),
    ("SOURce:POWer:ALC:BANDwidth:AUTO",     ALCBandwidthAuto,        Bool),
    ("SOURce:POWer:ALC:LEVel",              ALCLevel,                AbstractFloat),
    ("SOURce:POWer:ATTenuation:AUTO",       AttenuatorAuto,          Bool),
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
    (":OUTPut",                             Output,                  Bool),
    ("SOURce:OUTPut:BLANking:STATe",        OutputBlanking,          Bool),
    ("SOURce:OUTPut:BLANking:AUTO",         OutputBlankingAuto,      Bool),
    (":OUTPut:SETTled?",                    OutputSettled,           NoArgs),
    ("SOURce:PHASe:ADJust",                 Phase,                   AbstractFloat),
    ("SOURce:POWer",                        Power,                   AbstractFloat),
    ("SOURce:POWer:LIMit:MAX",              PowerLimit,              AbstractFloat),
    ("SOURce:POWer:LIMit:MAX:ADJust",       PowerLimitAdjustable,    Bool),
    ("SOURce:POWer:STARt",                  PowerStart,              AbstractFloat),
    ("SOURce:POWer:STOP",                   PowerStop,               AbstractFloat),
    ("SOURce:POWer:LEVel:STEP",             PowerStep,               AbstractFloat),
    ("SOURce:POWer:LEVel:OFFSet",           PowerOffsetLevel,        AbstractFloat),
    ("SOURce:POWer:REFerence:STATe",        PowerReference,          Bool),
    ("SOURce:POWer:REFerence",              PowerReferenceLevel,     AbstractFloat),
    ("SOURce:POWer:PROTection:STATe",       PowerSearchProtection,   Bool),
    ("SOURce:POWer:NOISe:STATe",            PowerOptimizeSNR,        Bool),
    ("SOURce:FREQuency:REFerence:SET",      SetFrequencyReference,   NoArgs),
    ("SOURce:PHASe:REFerence",              SetPhaseReference,       NoArgs),

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
