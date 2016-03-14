### Keysight / Agilent E5071C
module E5071CModule

## Import packages
import VISA
import FileIO

## Import our modules
importall PainterQB                 # All the stuff in InstrumentDefs, etc.
import PainterQB: getdata

importall PainterQB.VNA
import PainterQB.VNA: datacmd

include(joinpath(Pkg.dir("PainterQB"),"src/meta/Metaprogramming.jl"))

export E5071C

export Averaging
export AveragingFactor
export AveragingTrigger
export ClearAveraging
export ElectricalDelay
export ElectricalMedium
export ExtTriggerDelay
export ExtTriggerLowLatency
export FrequencyCenter
export FrequencySpan
export GraphLayout
export IFBandwidth
export Marker
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
export SearchTracking
export Smoothing
export SmoothingAperture
export TraceDisplay
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

export autoscale, bandwidth
export screen, search
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

abstract Averaging            <: InstrumentProperty
abstract AveragingFactor      <: InstrumentProperty{Int}
abstract AveragingTrigger     <: InstrumentProperty
abstract ClearAveraging       <: InstrumentProperty
abstract TraceDisplay         <: InstrumentProperty
abstract ElectricalDelay      <: InstrumentProperty{Float64}
abstract ExtTriggerDelay      <: InstrumentProperty{Float64}
abstract ExtTriggerLowLatency <: InstrumentProperty
abstract FrequencyCenter      <: InstrumentProperty{Float64}
abstract FrequencySpan        <: InstrumentProperty{Float64}
abstract GraphLayout          <: InstrumentProperty
abstract IFBandwidth          <: InstrumentProperty{Float64}
abstract Marker               <: InstrumentProperty
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
abstract SearchTracking       <: InstrumentProperty
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
    (":CALC#:TRAC#:FORM",           VNA.Format),
    (":CALC#:PAR#:DEF",             VNA.Parameter),

    (":TRIG:AVER",                  AveragingTrigger,      Bool),
    (":CALC#:TRAC#:CORR:EDEL:TIME", ElectricalDelay,       AbstractFloat),
    (":TRIG:EXT:DEL",               ExtTriggerDelay,       AbstractFloat),
    (":TRIG:EXT:LLAT",              ExtTriggerLowLatency,  Bool),
    (":DISP:WIND#:SPL",             GraphLayout,           ASCIIString),
    (":CALC#:PAR:COUN",             NumTraces,             Int),
    (":CALC#:TRAC#:CORR:OFFS:PHAS", PhaseOffset,           AbstractFloat),
    (":TRIG:POIN",                  PointTrigger,          Bool),
    (":SOUR#:POW:PORT:COUP",        PowerCoupled,          Bool),
    (":SOUR#:POW:PORT#",            PowerPortLevel,        AbstractFloat),
    (":SOUR#:POW:SLOP:STAT",        PowerSlope,            Bool),
    (":SOUR#:POW:SLOP",             PowerSlopeLevel,       AbstractFloat),
    (":SENS#:FREQ",                 PowerSweepFrequency,   AbstractFloat),
    (":DISP:WIND#:MAX",             TraceMaximized,        Bool),
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
[SENSe#:AVERage][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_average_state.htm]

Turn on or off averaging for a given channel `ch` (defaults to 1).
"""
function configure(ins::E5071C, ::Type{Averaging}, b::Bool, ch::Integer=1)
    write(ins, ":SENS#:AVER #", ch, Int(b))
end

"""
[SENSe#:AVERage:COUNt][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_average_count.htm]

Change the averaging factor for a given channel `ch` (defaults to 1).
Invalid input will be clipped to valid range (1--999).
"""
function configure(ins::E5071C, ::Type{AveragingFactor}, b::Integer, ch::Integer=1)
    # (1 <= b <= 999) || warn("Averaging factor $(string(b)) will be set within 1--999.")
    write(ins, ":SENS#:AVER:COUN #", ch, b)
    ret = inspect(ins, AveragingFactor, ch)
    info("Averaging factor set to "*string(ret)*".")
end

"""
[SENSe#:FREQuency:CENTer][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_center.htm]

Change the center frequency for a given channel `ch` (defaults to 1).
Invalid input will be clipped to valid range.
"""
function configure(ins::E5071C, ::Type{FrequencyCenter}, b::Real, ch::Integer=1)
    write(ins, ":SENS#:FREQ:CENT #", ch, float(b))
    ret = inspect(ins, FrequencyCenter, ch)
    info("Center set to "*string(ret)*" Hz.")
end

"""
[SENSe#:FREQuency:SPAN][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_span.htm]

Change the frequency span for a given channel `ch` (defaults to 1).
Invalid input will be clipped to valid range.
"""
function configure(ins::E5071C, ::Type{FrequencySpan}, b::Real, ch::Integer=1)
    write(ins, ":SENS#:FREQ:SPAN #", ch, float(b))
    ret = inspect(ins, FrequencySpan, ch)
    info("Span set to "*string(ret)*" Hz.")
end

"""
[SENSe#:FREQuency:STARt][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_start.htm]

Change the start frequency for a given channel `ch` (defaults to 1).
Invalid input will be clipped to valid range.
"""
function configure(ins::E5071C, ::Type{FrequencyStart}, b::Real, ch::Integer=1)
    write(ins, ":SENS#:FREQ:STAR #", ch, float(b))
    ret = inspect(ins, FrequencyStart, ch)
    info("Start set to "*string(ret)*" Hz.")
end

"""
[SENSe#:FREQuency:STOP][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_stop.htm]

Change the stop frequency for a given channel `ch` (defaults to 1).
Invalid input will be clipped to valid range.
"""
function configure(ins::E5071C, ::Type{FrequencyStop}, b::Real, ch::Integer=1)
    write(ins, ":SENS#:FREQ:STOP #", ch, float(b))
    ret = inspect(ins, FrequencyStop, ch)
    info("Stop set to "*string(ret)*" Hz.")
end

"""
[SENSe#:BANDwidth][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_bandwidth_resolution.htm]

Change the IF bandwidth for channel `ch` (defaults to 1).
Invalid input will be clipped to valid range.
"""
function configure(ins::E5071C, ::Type{IFBandwidth}, b::Real, ch::Integer=1)
    # Valid range reported in programming guide does not seem consistent with what happens
    # (10 <= b <= 1.5e6) || warn("IF bandwidth $(string(b)) will be set within 10--1.5e6.")
    write(ins, ":SENS#:BAND #", ch, float(b))
    ret = inspect(ins, IFBandwidth, ch)
    info("IF bandwidth set to "*string(ret)*" Hz.")
end

"""
[:CALC#:TRAC#:MARK#:STATe][aaa]

Turn on or off display of marker `m` for channel `ch` and trace `tr`.
"""
function configure(ins::E5071C, ::Type{Marker}, m::Integer, b::Bool, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    write(ins, "CALC#:TRAC#:MARK# #", ch, tr, m, Int(b))
end

"""
[:CALC#:TRAC#:MARK#:X][aaa]
"""
function configure(ins::E5071C, ::Type{MarkerX}, m::Integer, b::Real, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    write(ins, "CALC#:TRAC#:MARK#:X #", ch, tr, m, float(b))
end

"""
[OUTPut][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/output/scpi_output_state.htm]

Turn on or off the stimulus signal output.
"""
function configure(ins::E5071C, ::Type{Output}, b::Bool)
    write(ins, ":OUTP #", Int(b))
end

"""
[:SENS#:SWE:POIN][aaa]

Set the number of points to sweep over for channel `ch`.
"""
function configure(ins::E5071C, ::Type{NumPoints}, b::Integer, ch::Integer=1)
    write(ins, ":SENS#:SWE:POIN #", ch, b)
end

"""
[SOURce#:POWer][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/source/scpi_source_ch_power_level_immediate_amplitude.htm]

Change the stimulus power level for channel `ch` (defaults to 1).
Invalid input will be clipped to valid range (it depends).
"""
function configure(ins::E5071C, ::Type{PowerLevel}, b::Real, ch::Integer=1)
    write(ins, ":SOUR#:POW #", ch, float(b))
    ret = inspect(ins, PowerLevel, ch)
    info("Power level set to "*string(ret)*" dBm.")
end

"""
[:CALC#:MARK#:FUNC:TRAC][aaa]

Set whether or not the marker search for marker `m` is repeated with trace updates.
"""
function configure(ins::E5071C, ::Type{SearchTracking}, m::Integer, b::Bool, ch::Integer=1)
    write(ins, ":CALC#:MARK#:FUNC:TRAC #", ch, m, Int(b))
end

"""
[CALCulate#:TRACe#:SMOothing:STATe][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_smoothing_state.htm]

Turn on or off smoothing for a given channel `ch` and trace `tr` (default to 1).
"""
function configure(ins::E5071C, ::Type{Smoothing}, b::Bool, ch::Integer=1, tr::Integer=1)
    write(ins, ":CALC#:TRAC#:SMO #", ch, tr, Int(b))
end

"""
[CALCulate#:TRACe#:SMOothing:APERture][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_smoothing_aperture.htm]

Change the smoothing aperture (% of sweep span value) for
channel `ch` and trace `tr` (default to 1).
Invalid input will be clipped to valid range (0.05--25).
"""
function configure(ins::E5071C, ::Type{SmoothingAperture}, b::Real, ch::Integer=1, tr::Integer=1)
    write(ins, ":CALC#:TRAC#:SMO:APER #", ch, tr, float(b))
    ret = inspect(ins, SmoothingAperture, ch, tr)
    info("Smoothing aperture set to "*string(ret)*"%.")
end

"""
[:DISP:WIND#:TRAC#:STAT][aaa]

Turn on or off display of trace `tr` of channel `ch`.
"""
function configure(ins::E5071C, ::Type{TraceDisplay}, b::Bool, ch::Integer=1, tr::Integer=1)
    write(ins, ":DISP:WIND#:TRAC#:STAT #", ch, tr, Int(b))
end

"""
[TRIGger:OUTPut][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/trigger/scpi_trigger_output_state.htm]

Turn on or off the external trigger output.
"""
function configure(ins::E5071C, ::Type{TriggerOutput}, b::Bool)
    write(ins, ":TRIG:OUTP #", Int(b))
end

"""
[TRIGger:SEQuence:SOURce][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/trigger/scpi_trigger_sequence_source.htm]

Configure the trigger source: `InternalTrigger`, `ExternalTrigger`,
`BusTrigger`, `ManualTrigger`.
"""
function configure{T<:TriggerSource}(ins::E5071C, ::Type{T})
    write(ins, ":TRIG:SOUR #", code(ins,T))
end

"""
[SENSe#:AVERage][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_average_state.htm]

Is averaging on for a given channel `ch` (defaults to 1)?
"""
function inspect(ins::E5071C, ::Type{Averaging}, ch::Integer=1)
    Bool(parse(ask(ins, ":SENS#:AVER?", ch))::Int)
end

"""
[SENSe#:AVERage:COUNt][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_average_count.htm]

What is the averaging factor for a given channel `ch` (defaults to 1)?
"""
function inspect(ins::E5071C, ::Type{AveragingFactor}, ch::Integer=1)
    parse(ask(ins, ":SENS#:AVER:COUN?", ch))::Int
end

"""
[SENSe#:FREQuency:CENTer][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_center.htm]

Inspect the center frequency for a given channel `ch` (defaults to 1).
Invalid input will be clipped to valid range.
"""
function inspect(ins::E5071C, ::Type{FrequencyCenter}, ch::Integer=1)
    parse(ask(ins, ":SENS#:FREQ:CENT?", ch))::Float64
end

"""
[SENSe#:FREQuency:SPAN][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_span.htm]

Inspect the frequency span for a given channel `ch` (defaults to 1).
Invalid input will be clipped to valid range.
"""
function inspect(ins::E5071C, ::Type{FrequencySpan}, ch::Integer=1)
    parse(ask(ins, ":SENS#:FREQ:SPAN?", ch))::Float64
end

"""
[SENSe#:FREQuency:STARt][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_start.htm]

Inspect the start frequency for a given channel `ch` (defaults to 1).
Invalid input will be clipped to valid range.
"""
function inspect(ins::E5071C, ::Type{FrequencyStart}, ch::Integer=1)
    parse(ask(ins, ":SENS#:FREQ:STAR?", ch))::Float64
end

"""
[SENSe#:FREQuency:STOP][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_stop.htm]

Inspect the stop frequency for a given channel `ch` (defaults to 1).
Invalid input will be clipped to valid range.
"""
function inspect(ins::E5071C, ::Type{FrequencyStop}, ch::Integer=1)
    parse(ask(ins, ":SENS#:FREQ:STOP?", ch))::Float64
end

"""
[SENSe#:BANDwidth][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_bandwidth_resolution.htm]

Inspect the IF bandwidth for channel `ch` (defaults to 1).
"""
function inspect(ins::E5071C, ::Type{IFBandwidth}, ch::Integer=1)
    parse(ask(ins, ":SENS#:BAND?", ch))::Float64
end

"""
[:CALC#:TRAC#:MARK#:STATe][aaa]

Query whether marker `m` is displayed for channel `ch` and trace `tr`.
"""
function inspect(ins::E5071C, ::Type{Marker}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    Bool(parse(ask(ins, "CALC#:TRAC#:MARK#?", ch, tr, m))::Int)
end

"""
[:CALC#:TRAC#:MARK#:X][aaa]
"""
function inspect(ins::E5071C, ::Type{MarkerX}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    parse(ask(ins, "CALC#:TRAC#:MARK#:X?", ch, tr, m))::Float64
end

"""
[CALC#:TRAC#:MARK#:Y?][aaa]
"""
function inspect(ins::E5071C, ::Type{MarkerY}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    data = split(ask(ins, "CALC#:TRAC#:MARK#:Y?", ch, tr, m), ",")
    _reformat(ins, data, ch, tr)[1]
end

"""
[:SENS#:SWE:POIN][aaa]

Set the number of points to sweep over for channel `ch`.
"""
function inspect(ins::E5071C, ::Type{NumPoints}, ch::Integer=1)
    parse(ask(ins, ":SENS#:SWE:POIN?", ch))::Int
end

"""
[OUTPut][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/output/scpi_output_state.htm]

Is the stimulus signal output on?
"""
function inspect(ins::E5071C, ::Type{Output})
    Bool(parse(ask(ins, ":OUTP?"))::Int)
end

"""
[SOURce#:POWer][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/source/scpi_source_ch_power_level_immediate_amplitude.htm]

Inspect the stimulus power level for channel `ch` (defaults to 1).
"""
function inspect(ins::E5071C, ::Type{PowerLevel}, ch::Integer=1)
    parse(ask(ins, ":SOUR#:POW?", ch))::Float64
end

"""
[:CALC#:MARK#:FUNC:TRAC][aaa]

Set whether or not the marker search for marker `m` is repeated with trace updates.
"""
function inspect(ins::E5071C, ::Type{SearchTracking}, m::Integer, ch::Integer=1)
    Bool(parse(ask(ins, ":CALC#:MARK#:FUNC:TRAC?", ch, m))::Int)
end

"""
[CALCulate#:TRACe#:SMOothing:STATe][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_smoothing_state.htm]

Is smoothing on or off for a given channel `ch` and trace `tr` (default to 1)?
"""
function inspect(ins::E5071C, ::Type{Smoothing}, ch::Integer=1, tr::Integer=1)
    Bool(parse(ask(ins, ":CALC#:TRAC#:SMO?", ch, tr))::Int)
end

"""
[CALCulate#:TRACe#:SMOothing:APERture][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_smoothing_aperture.htm]

What is the smoothing aperture (% of sweep span value) for
channel `ch` and trace `tr` (default to 1)?
"""
function inspect(ins::E5071C, ::Type{SmoothingAperture}, ch::Integer=1, tr::Integer=1)
    parse(ask(ins, ":CALC#:TRAC#:SMO:APER?", ch, tr))::Float64
end

"""
[:DISP:WIND#:TRAC#:STAT][aaa]

Turn on or off display of trace `tr` of channel `ch`.
"""
function inspect(ins::E5071C, ::Type{TraceDisplay}, ch::Integer=1, tr::Integer=1)
    Bool(parse(ask(ins, ":DISP:WIND#:TRAC#:STAT?", ch, tr))::Int)
end

"""
[TRIGger:OUTPut][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/trigger/scpi_trigger_output_state.htm]

Is the external trigger output on?
"""
function inspect(ins::E5071C, ::Type{TriggerOutput})
    Bool(parse(ask(ins, ":TRIG:OUTP?"))::Int)
end

"""
[TRIGger:SEQuence:SOURce][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/trigger/scpi_trigger_sequence_source.htm]

Configure the trigger source: `InternalTrigger`, `ExternalTrigger`,
`BusTrigger`, `ManualTrigger`.
"""
function inspect(ins::E5071C, ::Type{TriggerSource})
    code(ins, ask(ins, ":TRIG:SOUR?"))
end

"""
[DISP:WIND#:TRAC#:Y:AUTO][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/display/scpi_display_window_ch_trace_tr_y_scale_auto.htm]

Autoscales y-axis of trace `tr` of channel `ch`.
"""
function autoscale(ins::E5071C, ch::Integer=1, tr::Integer=1)
    write(ins, ":DISP:WIND#:TRAC#:Y:AUTO", ch, tr)
    return nothing
end

"""
[SENSe#:FREQuency:DATA?][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_data.htm]

Read the stimulus values for the given channel (defaults to 1).
"""
function stimdata(ins::E5071C, ch::Int=1)
    xfer = inspect(ins, TransferFormat)
    getdata(ins, xfer, ":SENSe"*string(ch)*":FREQuency:DATA?")
end

"""
[Internal data processing][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/remote_control/reading-writing_measurement_data/internal_data_processing.htm]
[:CALCulate#:DATA:FDATa][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_data_fdata.htm]
[:CALCulate#:DATA:SDATa][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_data_sdata.htm]
"""
# Note that optional arguments still participate in method dispatch, so the
# result should be type-stable.
function data{T<:VNA.Format}(ins::E5071C, fmt::Type{T}, ch::Integer=1, tr::Integer=1)
    T != VNA.Format && configure(ins, fmt, ch, tr)
    xfer = inspect(ins, TransferFormat)
    cmdstr = datacmd(ins, fmt)
    cmdstr = replace(cmdstr,"#",string(ch),1)
    cmdstr = replace(cmdstr,"#",string(tr),1)
    data = getdata(ins, xfer, cmdstr)
    if T == VNA.Format
        _reformat(ins, data, ch, tr)
    else
        _reformat(ins, fmt, data)
    end
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
    cmdstr = datacmd(ins, processing)
    cmdstr = replace(cmdstr,"#",string(ch),1)
    cmdstr = replace(cmdstr,"#",code(ins,mpar),1)
    data = getdata(ins, xfer, cmdstr)
    reinterpret(Complex{Float64}, data)
end

"Default to formatted data."
data(ins::InstrumentVNA, ch::Integer=1, tr::Integer=1) =
    data(ins, VNA.Format, ch, tr)

datacmd{T<:VNA.Format}(x::E5071C, ::Type{T})  = ":CALC#:TRAC#:DATA:FDAT?"
datacmd(x::E5071C, ::Type{VNA.Calibrated})    = ":CALC#:TRAC#:DATA:SDAT?"
datacmd(x::E5071C, ::Type{VNA.Raw})           = ":SENS#:DATA:RAWD? #"

function _reformat(x::E5071C, data, ch, tr)
    fmt = inspect(x, VNA.Format, ch, tr)
    _reformat(x, fmt, data)
end
_reformat(x::E5071C, ::Type{VNA.LogMagnitude}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{VNA.Phase}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{VNA.GroupDelay}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{VNA.SmithLinear}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::E5071C, ::Type{VNA.SmithLog}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::E5071C, ::Type{VNA.SmithComplex}, data) =
    reinterpret(Complex{Float64}, data)
_reformat(x::E5071C, ::Type{VNA.Smith}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::E5071C, ::Type{VNA.SmithAdmittance}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::E5071C, ::Type{VNA.PolarLinear}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::E5071C, ::Type{VNA.PolarLog}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::E5071C, ::Type{VNA.PolarComplex}, data) =
    reinterpret(Complex{Float64}, data)
_reformat(x::E5071C, ::Type{VNA.LinearMagnitude}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{VNA.SWR}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{VNA.RealPart}, data) =
    reinterpret(Complex{Float64}, data)
_reformat(x::E5071C, ::Type{VNA.ImagPart}, data) =
    im*reinterpret(Complex{Float64}, data)
_reformat(x::E5071C, ::Type{VNA.ExpandedPhase}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{VNA.Calibrated}, data) =
    reinterpret(Complex{Float64}, data)
_reformat{T<:VNA.Format}(x::E5071C, ::Type{T}, data) =
    reinterpret(NTuple{2,Float64}, data)

function search(ins::E5071C, m::MarkerSearch{:Global}, exec::Bool=true)
    typ = (m.pol ? "MAX" : "MIN")
    write(ins, ":CALC#:TRAC#:MARK#:TYPE #", m.ch, m.tr, m.m, typ)
    exec && _search(ins, m)
end

function search{T}(ins::E5071C, m::MarkerSearch{T}, exec::Bool=true)
    write(ins, _type(ins, m), m.ch, m.tr, m.m)
    write(ins, _val(ins, m),  m.ch, m.tr, m.m, m.val)
    write(ins, _pol(ins, m),  m.ch, m.tr, m.m, Int(m.pol))
    exec && _search(ins, m)
end

function _search(ins::E5071C, m::MarkerSearch)
    write(ins, ":CALC#:TRAC#:MARK#:FUNC:EXEC", m.ch, m.tr, m.m)
    ask(ins, ":CALC#:TRAC#:MARK#:DATA?", m.ch, m.tr, m.m)
end

function _search(ins::E5071C, m::MarkerSearch{:Bandwidth})
    ask(ins, ":CALC#:MARK#:BWID:DATA?", m.ch, m.m)
end

_type(::E5071C, ::MarkerSearch{:Peak})         = ":CALC#:TRAC#:MARK#:FUNC:TYPE PEAK"
_type(::E5071C, ::MarkerSearch{:LeftPeak})     = ":CALC#:TRAC#:MARK#:FUNC:TYPE LPE"
_type(::E5071C, ::MarkerSearch{:RightPeak})    = ":CALC#:TRAC#:MARK#:FUNC:TYPE RPE"
_type(::E5071C, ::MarkerSearch{:Target})       = ":CALC#:TRAC#:MARK#:FUNC:TYPE TARG"
_type(::E5071C, ::MarkerSearch{:LeftTarget})   = ":CALC#:TRAC#:MARK#:FUNC:TYPE LTAR"
_type(::E5071C, ::MarkerSearch{:RightTarget})  = ":CALC#:TRAC#:MARK#:FUNC:TYPE RTAR"
_type(::E5071C, ::MarkerSearch{:Bandwidth})    = ""

_val(::E5071C,  ::MarkerSearch{:Peak})         = ":CALC#:TRAC#:MARK#:FUNC:PEXC #"
_val(::E5071C,  ::MarkerSearch{:LeftPeak})     = ":CALC#:TRAC#:MARK#:FUNC:PEXC #"
_val(::E5071C,  ::MarkerSearch{:RightPeak})    = ":CALC#:TRAC#:MARK#:FUNC:PEXC #"
_val(::E5071C,  ::MarkerSearch{:Target})       = ":CALC#:TRAC#:MARK#:FUNC:TARG #"
_val(::E5071C,  ::MarkerSearch{:LeftTarget})   = ":CALC#:TRAC#:MARK#:FUNC:TARG #"
_val(::E5071C,  ::MarkerSearch{:RightTarget})  = ":CALC#:TRAC#:MARK#:FUNC:TARG #"
_val(::E5071C,  ::MarkerSearch{:Bandwidth})    = ":CALC#:TRAC#:MARK#:BWID:THR #"

_pol(::E5071C,  ::MarkerSearch{:Peak})         = ":CALC#:TRAC#:MARK#:FUNC:PPOL #"
_pol(::E5071C,  ::MarkerSearch{:LeftPeak})     = ":CALC#:TRAC#:MARK#:FUNC:PPOL #"
_pol(::E5071C,  ::MarkerSearch{:RightPeak})    = ":CALC#:TRAC#:MARK#:FUNC:PPOL #"
_pol(::E5071C,  ::MarkerSearch{:Target})       = ":CALC#:TRAC#:MARK#:FUNC:TTR #"
_pol(::E5071C,  ::MarkerSearch{:LeftTarget})   = ":CALC#:TRAC#:MARK#:FUNC:TTR #"
_pol(::E5071C,  ::MarkerSearch{:RightTarget})  = ":CALC#:TRAC#:MARK#:FUNC:TTR #"
_pol(::E5071C,  ::MarkerSearch{:Bandwidth})    = ""

function screen(ins::E5071C, filename::AbstractString="screenshot.png", display::Bool=true)
    write(ins, ":MMEM:STOR:IMAG \"screen.png\"")
    write(ins, ":MMEM:TRAN? \"screen.png\"")
    io = binblockreadavailable(ins)
    img = readbytes(io)
    fi = open(filename,"w+")
    write(fi, img)
    close(fi)
    display && FileIO.load(filename)
end

end
