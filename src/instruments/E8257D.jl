### Keysight / Agilent E8257D
module E8257DModule

import Base: getindex, setindex!

## Import packages
import VISA

## Import our modules
importall PainterQB                 # All the stuff in InstrumentDefs, etc.
metadata = insjson(joinpath(Pkg.dir("PainterQB"),"deps/E8257D.json"))

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

returntype(::Type{Bool}) = (Int, Bool)
returntype(::Type{Real}) = (Float64, Float64)
returntype(::Type{Integer}) = (Int, Int)
fmt(v::Bool) = string(Int(v))
fmt(v) = string(v)

generate_all(E8257D, metadata)

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

setfrequencyref(ins::E8257D) = write(ins, "SOURce:FREQuency:REFerence:SET")
setphaseref(ins::E8257D) = write(ins, "SOURce:PHASe:REFerence")
settled(ins::E8257D) = Bool(parse(ask(ins, ":OUTPut:SETTled?"))::Int)


end
