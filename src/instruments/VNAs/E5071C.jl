### Keysight / Agilent E5071C
module E5071CModule

## Import packages
import VISA

## Import our modules
importall PainterQB                 # All the stuff in InstrumentDefs, etc.
include(joinpath(Pkg.dir("PainterQB"),"src/Metaprogramming.jl"))

export E5071C

export Autoscale
export Averaging
export AveragingFactor
export AveragingTrigger
export ClearAveraging
export DataTrace
export ElectricalDelay
export ElectricalMedium
export ExtTriggerDelay
export ExtTriggerLowLatency
export FrequencyCenter
export FrequencySpan
export GraphLayout
export IFBandwidth
export Marker
export MarkerSearch
export MarkerX
export MarkerY
export NumTraces
export PhaseOffset
export PointTrigger
export PowerCoupled
export PowerLevel
export PowerSlope
export PowerSlopeLevel
export PowerSweepFrequency
export Smoothing
export SmoothingAperture
export TraceMaximized
export TriggerOutput
export WaveguideCutoff
export WindowLayout
export YDivisions
export YReferenceLevel
export YReferencePosition
export YScalePerDivision
export SetActiveMarker
export SetActiveTrace
export SetActiveChannel

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

"Signals may propagate on coax or waveguide media."
abstract ElectricalMedium <: InstrumentProperty

subtypesArray = [

    (:Coaxial,                  ElectricalMedium),
    (:Waveguide,                ElectricalMedium),

]::Array{Tuple{Symbol,DataType},1}

# Create all the concrete types we need using the generate_properties function.
for ((subtypeSymb,supertype) in subtypesArray)
    generate_properties(subtypeSymb, supertype)
end

responseDictionary = Dict(
    :ElectricalMedium       => Dict("COAX" => :Coaxial,
                                    "WAV"  => :Waveguide),

    ################

    :VNAFormat              => Dict("MLOG" => :LogMagnitude,
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
                                    "IMAG" => :ImagPart,
                                    "UPH"  => :ExpandedPhase,
                                    "PPH"  => :PositivePhase),

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

    :TriggerOutputPolarity  => Dict("POS"  => :TrigOutPosPolarity,
                                    "NEG"  => :TrigOutNegPolarity),

    :TriggerOutputTiming    => Dict("BEF"  => :TrigOutBeforeMeasuring,
                                    "AFT"  => :TrigOutAfterMeasuring),

    :TriggerSlope           => Dict("POS"  => :RisingTrigger,
                                    "NEG"  => :FallingTrigger),

    :TriggerSource          => Dict("INT"  => :InternalTrigger,
                                    "EXT"  => :ExternalTrigger,
                                    "MAN"  => :ManualTrigger,
                                    "BUS"  => :BusTrigger)
)

generate_handlers(E5071C, responseDictionary)

abstract Autoscale            <: InstrumentProperty
abstract Averaging            <: InstrumentProperty
abstract AveragingFactor      <: InstrumentProperty{Int}
abstract AveragingTrigger     <: InstrumentProperty
abstract ClearAveraging       <: InstrumentProperty
abstract DataTrace            <: InstrumentProperty
abstract ElectricalDelay      <: InstrumentProperty{Float64}
abstract ExtTriggerDelay      <: InstrumentProperty{Float64}
abstract ExtTriggerLowLatency <: InstrumentProperty
abstract FrequencyCenter      <: InstrumentProperty{Float64}
abstract FrequencySpan        <: InstrumentProperty{Float64}
abstract GraphLayout          <: InstrumentProperty
abstract IFBandwidth          <: InstrumentProperty{Float64}
abstract Marker               <: InstrumentProperty
abstract MarkerSearch         <: InstrumentProperty
abstract MarkerX              <: InstrumentProperty{Float64}
abstract MarkerY              <: InstrumentProperty
abstract NumTraces            <: InstrumentProperty
abstract PhaseOffset          <: InstrumentProperty{Float64}
abstract PointTrigger         <: InstrumentProperty
abstract PowerCoupled         <: InstrumentProperty
abstract PowerLevel           <: InstrumentProperty{Float64}
abstract PowerPortLevel       <: InstrumentProperty{Float64}
abstract PowerSlope           <: InstrumentProperty
abstract PowerSlopeLevel      <: InstrumentProperty{Float64}
abstract PowerSweepFrequency  <: InstrumentProperty{Float64}
abstract Smoothing            <: InstrumentProperty
abstract SmoothingAperture    <: InstrumentProperty{Float64}
abstract TraceMaximized       <: InstrumentProperty
abstract TriggerOutput        <: InstrumentProperty
abstract WaveguideCutoff      <: InstrumentProperty{Float64}
abstract YDivisions           <: InstrumentProperty
abstract YScalePerDivision    <: InstrumentProperty{Float64}
abstract YReferenceLevel      <: InstrumentProperty{Float64}
abstract YReferencePosition   <: InstrumentProperty
abstract WindowLayout         <: InstrumentProperty
abstract SetActiveMarker      <: InstrumentProperty
abstract SetActiveTrace       <: InstrumentProperty
abstract SetActiveChannel     <: InstrumentProperty

commands = [

    (":CALC#:TRAC#:CORR:EDEL:MED",  ElectricalMedium),
    (":TRIG:OUTP:POL",              TriggerOutputPolarity),
    (":TRIG:OUTP:POS",              TriggerOutputTiming),
    (":TRIG:SEQ:EXT:SLOP",          TriggerSlope),
    (":TRIG:SOUR",                  TriggerSource),
    (":CALC#:PAR#:DEF",             SParameter),
    (":CALC#:TRAC#:FORM",           VNAFormat),

    (":DISP:WIND#:TRAC#:Y:AUTO",    Autoscale,             NoArgs),
    (":SENS#:AVER",                 Averaging,             Bool),
    (":SENS#:AVER:COUN",            AveragingFactor,       Int),
    (":TRIG:AVER",                  AveragingTrigger,      Bool),
    (":SENS#:AVER:CLE",             ClearAveraging,        NoArgs),
    (":DISP:WIND#:TRAC#:STAT",      DataTrace,             Bool),
    (":CALC#:TRAC#:CORR:EDEL:TIME", ElectricalDelay,       AbstractFloat),
    (":TRIG:EXT:DEL",               ExtTriggerDelay,       AbstractFloat),
    (":TRIG:EXT:LLAT",              ExtTriggerLowLatency,  Bool),
    (":SENS#:FREQ:CENT",            FrequencyCenter,       AbstractFloat),
    (":SENS#:FREQ:SPAN",            FrequencySpan,         AbstractFloat),
    (":SENS#:FREQ:STAR",            FrequencyStart,        AbstractFloat),
    (":SENS#:FREQ:STOP",            FrequencyStop,         AbstractFloat),
    (":DISP:WIND#:SPL",             GraphLayout,           ASCIIString),
    (":SENS1:BAND",                 IFBandwidth,           AbstractFloat),
    (":CALC#:MARK#",                Marker,                Bool),
    (":CALC#:MARK#:FUNC:EXEC",      MarkerSearch,          NoArgs),
    (":CALC#:MARK#:X",              MarkerX,               AbstractFloat),
    (":CALC#:MARK#:Y?",             MarkerY,               AbstractFloat),
    (":SENS#:SWE:POIN",             NumPoints,             Int),
    (":CALC#:PAR:COUN",             NumTraces,             Int),
    (":OUTP",                       Output,                Bool),
    (":CALC#:TRAC#:CORR:OFFS:PHAS", PhaseOffset,           AbstractFloat),
    (":TRIG:POIN",                  PointTrigger,          Bool),
    (":SOUR#:POW:PORT:COUP",        PowerCoupled,          Bool),
    (":SOUR#:POW",                  PowerLevel,            AbstractFloat),
    (":SOUR#:POW:PORT#",            PowerPortLevel,        AbstractFloat),
    (":SOUR#:POW:SLOP:STAT",        PowerSlope,            Bool),
    (":SOUR#:POW:SLOP",             PowerSlopeLevel,       AbstractFloat),
    (":SENS#:FREQ",                 PowerSweepFrequency,   AbstractFloat),
    (":CALC1:SMO:STAT",             Smoothing,             Bool),
    (":CALC#:SMO:APER",             SmoothingAperture,     AbstractFloat),
    (":DISP:WIND#:MAX",             TraceMaximized,        Bool),
    (":TRIG:OUTP:STAT",             TriggerOutput,         Bool),
    (":CALC#:TRAC#:CORR:EDEL:WGC",  WaveguideCutoff,       AbstractFloat),
    (":DISP:WIND#:Y:DIV",           YDivisions,            Int),
    (":DISP:WIND#:TRAC#:Y:PDIV",    YScalePerDivision,     AbstractFloat),
    (":DISP:WIND#:TRAC#:Y:RLEV",    YReferenceLevel,       AbstractFloat),
    (":DISP:WIND#:TRAC#:Y:RPOS",    YReferencePosition,    Int),
    (":DISP:SPL",                   WindowLayout,          ASCIIString),
    (":CALC#:MARK#:ACT",            SetActiveMarker,       NoArgs),
    (":CALC#:PAR#:SEL",             SetActiveTrace,        NoArgs),
    (":DISP:WIND#:ACT",             SetActiveChannel,      NoArgs),
]

for args in commands
    generate_inspect(E5071C,args...)
    args[1][end] != '?' && generate_configure(E5071C,args...)
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
