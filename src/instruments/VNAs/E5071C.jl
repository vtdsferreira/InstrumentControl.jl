### Keysight / Agilent E5071C
module E5071CModule

## Import packages
import VISA

## Import our modules
importall PainterQB                 # All the stuff in InstrumentDefs, etc.
import PainterQB: _getdata

importall PainterQB.VNA
import PainterQB.VNA: _procdata

include(joinpath(Pkg.dir("PainterQB"),"src/meta/Metaprogramming.jl"))

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
export SetActiveChannel

export stimdata, data
export mktrace

# The E5071C has rather incomplete support for referring to traces by name.
# We will maintain an internal description of what names correspond to what
# trace numbers.

type E5071C <: InstrumentVNA
    vi::(VISA.ViSession)
    writeTerminator::ASCIIString
    model::AbstractString
    tracenames::Dict{AbstractString,Int}

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
for (subtypeSymb,supertype) in subtypesArray
    generate_properties(subtypeSymb, supertype)
end

responseDictionary = Dict(
    :ElectricalMedium       => Dict("COAX" => :Coaxial,
                                    "WAV"  => :Waveguide),

    ################

    :Format                 => Dict("MLOG" => :(VNA.LogMagnitude),
                                    "PHAS" => :(VNA.Phase),
                                    "GDEL" => :(VNA.GroupDelay),
                                    "SLIN" => :(VNA.SmithLinear),
                                    "SLOG" => :(VNA.SmithLog),
                                    "SCOM" => :(VNA.SmithComplex),
                                    "SMIT" => :(VNA.Smith),
                                    "SADM" => :(VNA.SmithAdmittance),
                                    "PLIN" => :(VNA.PolarLinear),
                                    "PLOG" => :(VNA.PolarLog),
                                    "POL"  => :(VNA.PolarComplex),
                                    "MLIN" => :(VNA.LinearMagnitude),
                                    "SWR"  => :(VNA.SWR),
                                    "REAL" => :(VNA.RealPart),
                                    "IMAG" => :(VNA.ImagPart),
                                    "UPH"  => :(VNA.ExpandedPhase),
                                    "PPH"  => :(VNA.PositivePhase)),

    :Search                 => Dict("MAX"  => :Max,
                                    "MIN"  => :Min,
                                    "PEAK" => :Peak,
                                    "LPE"  => :LeftPeak,
                                    "RPE"  => :RightPeak,
                                    "TARG" => :Target,
                                    "LTAR" => :LeftTarget,
                                    "RTAR" => :RightTarget),

    :Parameter              => Dict("S11"  => :(VNA.S11),
                                    "S12"  => :(VNA.S12),
                                    "S21"  => :(VNA.S21),
                                    "S22"  => :(VNA.S22)),

    :TransferByteOrder      => Dict("NORM" => :BigEndianTransfer,
                                    "SWAP" => :LittleEndianTransfer),

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

code(ins::E5071C, ::Type{TransferFormat{ASCIIString}}) = "ASC"
code(ins::E5071C, ::Type{TransferFormat{Float32}}) = "REAL32"
code(ins::E5071C, ::Type{TransferFormat{Float64}}) = "REAL"
TransferFormat(ins::E5071C, x::AbstractString) = begin
    if x=="ASC"
        return TransferFormat{ASCIIString}
    elseif x=="REAL32"
        return TransferFormat{Float32}
    elseif x=="REAL"
        return TransferFormat{Float64}
    else
        error("Transfer format error.")
    end
end

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
abstract SetActiveChannel     <: InstrumentProperty

commands = [

    (":CALC#:TRAC#:CORR:EDEL:MED",  ElectricalMedium),
    (":TRIG:OUTP:POL",              TriggerOutputPolarity),
    (":TRIG:OUTP:POS",              TriggerOutputTiming),
    (":TRIG:SEQ:EXT:SLOP",          TriggerSlope),
    (":TRIG:SOUR",                  TriggerSource),
    (":CALC#:TRAC#:FORM",           VNA.Format),
    (":CALC#:PAR#:DEF",             VNA.Parameter),

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
    (":CALC#:PAR#:SEL",             ActiveTrace,           NoArgs),
    (":DISP:WIND#:ACT",             SetActiveChannel,      NoArgs),
]

for args in commands
    generate_inspect(E5071C,args...)
    args[1][end] != '?' && generate_configure(E5071C,args...)
end

"""
[SENSe#:FREQuency:DATA?][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_data.htm]

Read the stimulus values for the given channel (default ch. 1).
"""
function stimdata(ins::E5071C, ch::Int=1)
    xfer = inspect(ins, TransferFormat)
    PainterQB._getdata(ins, xfer, ":SENSe"*string(ch)*":FREQuency:DATA?")
end

"""
[Internal data processing][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/remote_control/reading-writing_measurement_data/internal_data_processing.htm]
[:CALCulate#:DATA:FDATa][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_data_fdata.htm]
"""
# Note that optional arguments still participate in method dispatch, so the
# result should be type-stable.
function data{T<:VNA.Processing}(ins::E5071C, processing::Type{T}=VNA.Formatted, ch::Integer=1, tr::Integer=1)

    # Get measurement parameter
    xfer = inspect(ins, TransferFormat)
    cmdstr = _procdata(ins, processing)
    cmdstr = replace(cmdstr,"#",string(ch),1)
    cmdstr = replace(cmdstr,"#",string(tr),1)
    data = _getdata(ins, xfer, cmdstr)

    # # Return an array of numbers
    # nums = map(parse,split(data,",",keep=false))
    # half = convert(Int, length(nums) / 2)
    # a = Array(AbstractFloat,half)
    # b = Array(AbstractFloat,half)
    #
    # # Every other item should go in a separate collection
    # for (i in 1:half)
    #     a[i] = nums[2*i-1]
    #     b[i] = nums[2*i]
    # end
    #
    # # Return both collections
    # (a,b)
end

"""
[:CALCulate#:DATA:SDATa][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_data_sdata.htm]
"""
function data(ins::E5071C, processing::Type{VNA.Calibrated}, ch::Integer=1, tr::Integer=1)
    xfer = inspect(ins, TransferFormat)
    cmdstr = _procdata(ins, processing)
    cmdstr = replace(cmdstr,"#",string(ch),1)
    cmdstr = replace(cmdstr,"#",string(tr),1)
    data = _getdata(ins, xfer, cmdstr)
    reinterpret(Complex{Float64}, data)
end

"""
[:SENSe#:DATA:RAWData][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi.sense(ch).data.rawdata.htm]
This instrument does not associate raw data with a particular trace, but we use the
trace number to look up what S parameter should be retrieved.
"""
function data(ins::E5071C, processing::Type{VNA.Raw}, ch::Integer=1, tr::Integer=1)
    # Get measurement parameter
    mpar = inspect(ins, VNA.Parameter, ch, tr)
    !(mpar <: VNA.SParameter) &&
        error("Raw data must represent a wave quantity or ratio.")

    xfer = inspect(ins, TransferFormat)
    cmdstr = _procdata(ins, processing)
    cmdstr = replace(cmdstr,"#",string(ch),1)
    cmdstr = replace(cmdstr,"#",code(ins,mpar),1)
    data = _getdata(ins, xfer, cmdstr)
    reinterpret(Complex{Float64}, data)
end

"Default to formatted data."
data(ins::InstrumentVNA, ch::Integer=1, tr::Integer=1) = data(ins, VNA.Formatted, ch, tr)

_procdata(x::E5071C, ::Type{VNA.Formatted})  = ":CALC#:TRAC#:DATA:FDAT?"
_procdata(x::E5071C, ::Type{VNA.Calibrated}) = ":CALC#:TRAC#:DATA:SDAT?"
_procdata(x::E5071C, ::Type{VNA.Raw})        = ":SENS#:DATA:RAWD? #"

end
