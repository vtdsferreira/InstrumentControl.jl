### Keysight / Agilent E8257D
module E8257DModule

## Import packages
import VISA

## Import our modules
importall PainterQB                 # All the stuff in InstrumentDefs, etc.
include(joinpath(Pkg.dir("PainterQB"),"src/Metaprogramming.jl"))

export E8257D

export ALCBandwidth
export ALCBandwidthAuto
export ALC
export ALCLevel
export AttenuatorAuto
export FlatnessCorrection
#export FrequencyMultiplier
export FrequencyStart
export FrequencyStop
export FrequencyStep
#export FrequencyOffsetLevel
#export FrequencyOffset
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
#export PowerOffsetLevel
export PowerReference
export PowerReferenceLevel
export PowerSearchProtection
export PowerOptimizeSNR
export SetFrequencyReference
export SetPhaseReference

export boards, cumulativeattenuatorswitches, cumulativepowerons, cumulativeontime
export options, revision

"Concrete type representing an E8257D."
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

    :OscillatorSource     => Dict("INT"  => :InternalOscillator,
                                  "EXT"  => :ExternalOscillator),

    :TriggerSource        => Dict("IMM"  => :InternalTrigger,
                                  "EXT"  => :ExternalTrigger,
                                  "KEY"  => :ManualTrigger,
                                  "BUS"  => :BusTrigger),
)

generate_handlers(E8257D, responses)

"ALC bandwidth."
abstract ALCBandwidth            <: InstrumentProperty{Float64}

"Boolean state for automatic selection of the ALC bandwidth."
abstract ALCBandwidthAuto        <: InstrumentProperty

"Boolean state of the ALC."
abstract ALC                     <: InstrumentProperty

"Level of the ALC when the attenuator hold is active."
abstract ALCLevel                <: InstrumentProperty{Float64}

"Boolean state for automatic operation of the attenuator."
abstract AttenuatorAuto          <: InstrumentProperty

"Boolean state for flatness correction."
abstract FlatnessCorrection      <: InstrumentProperty


# abstract FrequencyMultiplier     <: InstrumentProperty{Int}
"Step size for a frequency sweep."
abstract FrequencyStep           <: InstrumentProperty{Float64}

#abstract FrequencyOffsetLevel    <: InstrumentProperty{Float64}
#abstract FrequencyOffset         <: InstrumentProperty

"Boolean state of the frequency reference level."
abstract FrequencyReference      <: InstrumentProperty

"Reference level for configuring/inspecting frequency."
abstract FrequencyReferenceLevel <: InstrumentProperty{Float64}

"Boolean state for the output blanking."
abstract OutputBlanking          <: InstrumentProperty

"Boolean state for automatic blanking of the output."
abstract OutputBlankingAuto      <: InstrumentProperty

"Has the output settled?"
abstract OutputSettled           <: InstrumentProperty

"RF output power limit."
abstract PowerLimit              <: InstrumentProperty{Float64}

"Boolean for whether or not the RF output power limit can be adjusted."
abstract PowerLimitAdjustable    <: InstrumentProperty

"Start power in a sweep."
abstract PowerStart              <: InstrumentProperty{Float64}

"Stop power in a sweep."
abstract PowerStop               <: InstrumentProperty{Float64}

"Step size for a power sweep."
abstract PowerStep               <: InstrumentProperty{Float64}

#abstract PowerOffsetLevel        <: InstrumentProperty{Float64}

"Boolean state of the power reference level."
abstract PowerReference          <: InstrumentProperty

"Reference level for configuring/inspecting power."
abstract PowerReferenceLevel     <: InstrumentProperty{Float64}

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
#    ("SOURce:FREQuency:MULTiplier",         FrequencyMultiplier,     Int),
    ("SOURce:FREQuency:STARt",              FrequencyStart,          AbstractFloat),
    ("SOURce:FREQuency:STOP",               FrequencyStop,           AbstractFloat),
    ("SOURce:FREQuency:STEP",               FrequencyStep,           AbstractFloat),
#    ("SOURce:FREQuency:OFFSet",             FrequencyOffsetLevel,    AbstractFloat),
#    ("SOURce:POWer:REFerence:STATe",        FrequencyOffset,         Bool),
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
#    ("SOURce:POWer:LEVel:OFFSet",           PowerOffsetLevel,        AbstractFloat),
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

boards(ins::E8257D) = ask(ins,"DIAGnostic:INFOrmation:BOARds?")

cumulativeattenuatorswitches(ins::E8257D) =
    ask(ins,"DIAGnostic:INFOrmation:CCOunt:ATTenuator?")

"Returns the number of attenuator switching events over the instrument lifetime."
cumulativeattenuatorswitches

cumulativepowerons(ins::E8257D) = ask(ins,"DIAGnostic:INFOrmation:CCOunt:PON?")

"Returns the number of power on events over the instrument lifetime."
cumulativepowerons

cumulativeontime(ins::E8257D) = ask(ins,"DIAGnostic:INFOrmation:OTIMe?")

"Returns the cumulative on-time over the instrument lifetime."
cumulativeontime

function options(ins::E8257D; verbose=false)
    if verbose
        ask(ins,"DIAGnostic:INFOrmation:OPTions:DETail?")
    else
        ask(ins,"DIAGnostic:INFOrmation:OPTions?")
    end
end

"Reports the options available for the given E8257D."
options

revision(ins::E8257D) = ask(ins,"DIAGnostic:INFOrmation:REVision?")

"Reports the revision of the E8257D."
revision

end
