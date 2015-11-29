### Keysight / Agilent E5071C
module E5071CModule

## Import packages
import VISA

## Import our modules
importall PainterQB                 # All the stuff in InstrumentDefs, etc.
include("../Metaprogramming.jl")

export E5071C

export Averaging, AveragingFactor
export FrequencyStart, FrequencyStop, FrequencyCenter, FrequencySpan
export ExtTriggerDelay, ExtTriggerLowLatency
export IFBandwidth
export PowerLevel
export MarkerX, MarkerY, Marker
export Smoothing, SmoothingAperture
export TriggerOutput
export PhaseOffset
export ElectricalDelay, ElecticalMedium, WaveguideCutoff
export YDivisions, YScalePerDivision, YReferencePosition, YReferenceLevel
export PowerCoupled, PowerSlope, PowerSlopeLevel, PowerLevel
export NumPoints, NumTraces
export PointTrigger, AveragingTrigger
export TraceMaximized
export PowerSweepFrequency
export WindowLayout
export GraphLayout
export SetActiveMarker
export MarkerSearch
export SetActiveTrace
export SetActiveChannel
export Autoscale
export ClearAveraging
export DataTrace
export Output

export frequencydata, formatteddata

type E5071C <: InstrumentVISA
    vi::(VISA.ViSession)
    writeTerminator::ASCIIString
    model::AbstractString

    E5071C(x) = begin
        ins = new()
        ins.vi = x
        ins.writeTerminator = "\n"
        ins.model = "E5071C"
        VISA.viSetAttribute(ins.vi, VISA.VI_ATTR_TERMCHAR_EN, UInt64(1))
        ins
    end

    E5071C() = new()
end

abstract Averaging            <: InstrumentProperty
abstract AveragingFactor      <: InstrumentProperty
abstract FrequencyStart       <: InstrumentProperty
abstract FrequencyStop        <: InstrumentProperty
abstract FrequencyCenter      <: InstrumentProperty
abstract FrequencySpan        <: InstrumentProperty
abstract ExtTriggerDelay      <: InstrumentProperty
abstract ExtTriggerLowLatency <: InstrumentProperty
abstract IFBandwidth          <: InstrumentProperty
abstract PowerLevel           <: InstrumentProperty
abstract MarkerX              <: InstrumentProperty
abstract MarkerY              <: InstrumentProperty
abstract Marker               <: InstrumentProperty
abstract Smoothing            <: InstrumentProperty
abstract SmoothingAperture    <: InstrumentProperty
abstract YDivisions           <: InstrumentProperty
abstract TriggerOutput        <: InstrumentProperty
abstract PhaseOffset          <: InstrumentProperty
abstract ElectricalDelay      <: InstrumentProperty
abstract ElecticalMedium      <: InstrumentProperty
abstract WaveguideCutoff      <: InstrumentProperty
abstract YScalePerDivision    <: InstrumentProperty
abstract YReferencePosition   <: InstrumentProperty
abstract YReferenceLevel      <: InstrumentProperty
abstract PowerCoupled         <: InstrumentProperty
abstract PowerSlope           <: InstrumentProperty
abstract PowerSlopeLevel      <: InstrumentProperty
abstract PowerLevel           <: InstrumentProperty
abstract NumPoints            <: InstrumentProperty
abstract NumTraces            <: InstrumentProperty
abstract PointTrigger         <: InstrumentProperty
abstract AveragingTrigger     <: InstrumentProperty
abstract TraceMaximized       <: InstrumentProperty
abstract PowerSweepFrequency  <: InstrumentProperty
abstract WindowLayout         <: InstrumentProperty
abstract GraphLayout          <: InstrumentProperty
abstract SetActiveMarker      <: InstrumentProperty
abstract MarkerSearch         <: InstrumentProperty
abstract SetActiveTrace       <: InstrumentProperty
abstract SetActiveChannel     <: InstrumentProperty
abstract Autoscale            <: InstrumentProperty
abstract ClearAveraging       <: InstrumentProperty
abstract DataTrace            <: InstrumentProperty
abstract Output               <: InstrumentProperty

responseDictionary = Dict(

    :Network                => Dict("DHCP" => :DHCP,
                                    "MAN"  => :ManualNetwork),

    :TriggerSource          => Dict("INT"  => :InternalTrigger,
                                    "EXT"  => :ExternalTrigger,
                                    "MAN"  => :ManualTrigger,
                                    "BUS"  => :BusTrigger),

    :TriggerOutputTiming    => Dict("BEF"  => :TrigOutBeforeMeasuring,
                                    "AFT"  => :TrigOutAfterMeasuring),

    :TriggerSlope           => Dict("POS"  => :RisingTrigger,
                                    "NEG"  => :FallingTrigger),

    :TriggerOutputPolarity  => Dict("POS"  => :TrigOutPosPolarity,
                                    "NEG"  => :TrigOutNegPolarity),

    :Search                 => Dict("MAX"  => :Max,
                                    "MIN"  => :Min,
                                    "PEAK" => :Peak,
                                    "LPE"  => :LeftPeak,
                                    "RPE"  => :RightPeak,
                                    "TARG" => :Target,
                                    "LTAR" => :LeftTarget,
                                    "RTAR" => :RightTarget),

    :SParameter             => Dict("S11"  => :S11,
                                    "S12"  => :S12,
                                    "S21"  => :S21,
                                    "S22"  => :S22),

    :Medium                 => Dict("COAX" => :Coaxial,
                                    "WAV"  => :Waveguide),

    :DataRepresentation     => Dict("MLOG" => :LogMagnitude,
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

generate_handlers(E5071C, responseDictionary)

commands = [

    (":CALC#:TRAC#:FORM",           DataRepresentation)
    (":TRIG:SOUR",                  TriggerSource),
    (":TRIG:OUTP:POL",              TriggerOutputPolarity),
    (":TRIG:OUTP:POS",              TriggerOutputTiming),
    (":TRIG:SEQ:EXT:SLOP",          ExternalTriggerSlope),
    (":CALC#:PAR#:DEF",             SParameter),

    (":SENS#:AVER",                 Averaging,             Bool),
    (":SENS#:AVER:COUN",            AveragingFactor,       Int),
    (":SENS#:FREQ:STAR",            FrequencyStart,        AbstractFloat),
    (":SENS#:FREQ:STOP",            FrequencyStop,         AbstractFloat),
    (":SENS#:FREQ:CENT",            FrequencyCenter,       AbstractFloat),
    (":SENS#:FREQ:SPAN",            FrequencySpan,         AbstractFloat),
    (":TRIG:EXT:DEL",               ExtTriggerDelay,       AbstractFloat),
    (":TRIG:EXT:LLAT",              ExtTriggerLowLatency,  Bool),
    (":SENS1:BAND",                 IFBandwidth,           AbstractFloat),
    (":SOUR#:POW",                  PowerLevel,            AbstractFloat),
    (":CALC#:MARK#:X",              MarkerX,               AbstractFloat),
    (":CALC#:MARK#:Y?",             MarkerY,               AbstractFloat),
    (":CALC#:MARK#",                Marker,                Bool),
    (":CALC1:SMO:STAT",             Smoothing,             Bool),
    (":CALC#:SMO:APER",             SmoothingAperture,     AbstractFloat),
    (":DISP:WIND#:Y:DIV",           YDivisions,            Int),
    (":TRIG:OUTP:STAT",             TriggerOutput,         Bool),
    (":CALC#:TRAC#:CORR:OFFS:PHAS", PhaseOffset,           AbstractFloat),
    (":CALC#:TRAC#:CORR:EDEL:TIME", ElectricalDelay,       AbstractFloat),
    (":CALC#:TRAC#:CORR:EDEL:MED",  ElecticalMedium,       Medium),
    (":CALC#:TRAC#:CORR:EDEL:WGC",  WaveguideCutoff,       AbstractFloat),
    (":DISP:WIND#:TRAC#:Y:PDIV",    YScalePerDivision,     AbstractFloat),
    (":DISP:WIND#:TRAC#:Y:RPOS",    YReferencePosition,    Int),
    (":DISP:WIND#:TRAC#:Y:RLEV",    YReferenceLevel,       AbstractFloat),
    (":SOUR#:POW:PORT:COUP",        PowerCoupled,          Bool),
    (":SOUR#:POW:SLOP:STAT",        PowerSlope,            Bool),
    (":SOUR#:POW:SLOP",             PowerSlopeLevel,       AbstractFloat),
    (":SOUR#:POW:PORT#",            PowerLevel,            AbstractFloat),
    (":SENS#:SWE:POIN",             NumPoints,             Int),
    (":CALC#:PAR:COUN",             NumTraces,             Int),
    (":TRIG:POIN",                  PointTrigger,          Bool),
    (":TRIG:AVER",                  AveragingTrigger,      Bool),
    (":DISP:WIND#:MAX",             TraceMaximized,        Bool),
    (":SENS#:FREQ",                 PowerSweepFrequency,   AbstractFloat),
    (":DISP:SPL",                   WindowLayout,          ASCIIString),
    (":DISP:WIND#:SPL",             GraphLayout,           ASCIIString),
    (":CALC#:MARK#:ACT",            SetActiveMarker,       NoArgs),
    (":CALC#:MARK#:FUNC:EXEC",      MarkerSearch,          NoArgs),
    (":CALC#:PAR#:SEL",             SetActiveTrace,        NoArgs),
    (":DISP:WIND#:ACT",             SetActiveChannel,      NoArgs),
    (":DISP:WIND#:TRAC#:Y:AUTO",    Autoscale,             NoArgs),
    (":SENS#:AVER:CLE",             ClearAveraging,        NoArgs),
    (":DISP:WIND#:TRAC#:STAT",      DataTrace,             Bool),
    (":OUTP",                       Output,                Bool),
]

function output(ins::E5071C, on::Bool)
    write(ins, string(":OUTP ",Int(on)))
end

function frequencydata(ins::E5071C, channel::Integer, trace::Integer)
    data = ask(ins,string(":CALC",channel,":TRAC",trace,":DATA:XAX?"))

    # Return an array of numbers
    map(parse,split(data,",",keep=false))
end

function formatteddata(ins::E5071C, channel::Integer, trace::Integer)
    data = ask(ins,string(":CALC",channel,":TRAC",trace,":DATA:FDAT?"))

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
