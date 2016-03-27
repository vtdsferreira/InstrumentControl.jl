### Keysight / Agilent E5071C
module E5071CModule

## Import packages
import VISA
import FileIO

## Import our modules
importall PainterQB                 # All the stuff in InstrumentDefs, etc.
import PainterQB: getdata

importall PainterQB.VNA
import PainterQB.VNA: datacmd, peaknotfound, window
import FixedSizeArrays
import FixedSizeArrays.Mat

metadata = insjson(joinpath(Pkg.dir("PainterQB"),"deps/E5071C.json"))
include(joinpath(Pkg.dir("PainterQB"),"src/meta/Metaprogramming.jl"))

export E5071C

export AveragingTrigger
export ElectricalDelay
export ExtTriggerDelay
export ExtTriggerLowLatency
export GraphLayout
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
export SweepTime

export autoscale, bandwidth
export screen, search
export stimdata, data
export mktrace, trig1

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

abstract AveragingTrigger     <: InstrumentProperty
abstract TraceDisplay         <: InstrumentProperty
abstract ElectricalDelay      <: InstrumentProperty{Float64}
abstract ExtTriggerDelay      <: InstrumentProperty{Float64}
abstract ExtTriggerLowLatency <: InstrumentProperty
abstract GraphLayout          <: InstrumentProperty
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
abstract SweepTime            <: InstrumentProperty

returntype(::Type{Bool}) = (Int, Bool)
returntype(::Type{Real}) = (Float64, Float64)
returntype(::Type{Integer}) = (Int, Int)
fmt(v::Bool) = string(Int(v))
fmt(v) = string(v)

for p in metadata[:properties]
    generate_handlers(E5071C, p)
    generate_inspect(E5071C, p)
    p[:cmd][end] != '?' && generate_configure(E5071C, p)
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
[:CALC#:TRAC#:MARK#:STATe][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_state.htm]

Turn on or off display of marker `m` for channel `ch` and trace `tr`.
"""
function configure(ins::E5071C, ::Type{VNA.Marker}, m::Integer, b::Bool, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    write(ins, "CALC#:TRAC#:MARK# #", ch, tr, m, Int(b))
end

"""
:CALC#:TRAC#:MARK#:X
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_x.htm]
"""
function configure(ins::E5071C, ::Type{VNA.MarkerX}, m::Integer, b::Real, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    write(ins, "CALC#:TRAC#:MARK#:X #", ch, tr, m, float(b))
end

"""
CALC#:PAR:COUNt
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_parameter_count.htm]
"""
function configure(ins::E5071C, ::Type{VNA.NumTraces}, b::Integer, ch::Integer=1)
    write(ins, ":CALC#:PAR:COUN #", ch, b)
end

"""
[:SENSe#:SWEep:POINts][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_sweep_points.htm]

Set the number of points to sweep over for channel `ch`.
"""
function configure(ins::E5071C, ::Type{NumPoints}, b::Integer, ch::Integer=1)
    write(ins, ":SENS#:SWE:POIN #", ch, b)
    ret = inspect(ins, NumPoints, ch)
    info("Number of points set to "*string(ret)*".")
end

"""
[OUTPut][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/output/scpi_output_state.htm]

Turn on or off the stimulus signal output.
"""
function configure(ins::E5071C, ::Type{Output}, b::Bool)
    write(ins, ":OUTP #", Int(b))
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
[CALCulate#:TRACe#:MARKer#:FUNCtion:TRACking][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_function_tracking.htm]

Set whether or not the marker search for marker `m` is repeated with trace updates.
"""
function configure(ins::E5071C, ::Type{SearchTracking}, m::Integer, b::Bool, ch::Integer=1, tr::Integer=1)
    write(ins, ":CALC#:TRAC#:MARK#:FUNC:TRAC #", ch, tr, m, Int(b))
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
[:DISP:WIND#:TRAC#:STAT][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/display/scpi_display_window_ch_trace_tr_state.htm]

Turn on or off display of trace `tr` of channel `ch`.
"""
function configure(ins::E5071C, ::Type{TraceDisplay}, b::Bool, ch::Integer=1, tr::Integer=1)
    write(ins, ":DISP:WIND#:TRAC#:STAT #", ch, tr, Int(b))
end

"""
DISPlay:SPLit
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/display/scpi_display_split.htm]

`configure(ins::InstrumentVNA, ::Type{Windows}, a::AbstractArray{Int})`

Configure the layout of graph windows using a matrix to abstract the layout.
For instance, passing [1 2; 3 3] makes two windows in one row and a third window below.
"""
function configure(ins::E5071C, ::Type{VNA.Graphs}, a::AbstractArray{Int}, ch::Integer=1)
    write(ins, ":DISP:WIND#:SPL #", ch, window(ins, Val{FixedSizeArrays.Mat(a)}))
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
[CALCulate#:TRACe#:MARKer#:STATe][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_state.htm]

Query whether marker `m` is displayed for channel `ch` and trace `tr`.
"""
function inspect(ins::E5071C, ::Type{VNA.Marker}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    Bool(parse(ask(ins, "CALC#:TRAC#:MARK#?", ch, tr, m))::Int)
end

"""
[CALCulate#:TRACe#:MARKer#:X][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_x.htm]
"""
function inspect(ins::E5071C, ::Type{VNA.MarkerX}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    parse(ask(ins, "CALC#:TRAC#:MARK#:X?", ch, tr, m))::Float64
end

"""
[CALCulate#:TRACe#:MARKer#:Y?][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_y.htm]
"""
function inspect(ins::E5071C, ::Type{VNA.MarkerY}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    data = getdata(ins, TransferFormat{ASCIIString}, "CALC#:TRAC#:MARK#:Y?", ch, tr, m)
    _reformat(ins, data, ch, tr)[1]
end

"""
[:SENSe#:SWEep:POINts][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_sweep_points.htm]

Set the number of points to sweep over for channel `ch`.
"""
function inspect(ins::E5071C, ::Type{NumPoints}, ch::Integer=1)
    parse(ask(ins, ":SENS#:SWE:POIN?", ch))::Int
end

"""
CALC#:PAR:COUNt
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_parameter_count.htm]
"""
function inspect(ins::E5071C, ::Type{VNA.NumTraces}, ch::Integer=1)
    parse(ask(ins, ":CALC#:PAR:COUN?", ch))::Int
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
[:CALCulate#:TRACe#:MARKer#:FUNCtion:TRACking][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_function_tracking.htm]

Set whether or not the marker search for marker `m` is repeated with trace updates.
"""
function inspect(ins::E5071C, ::Type{SearchTracking}, m::Integer, ch::Integer=1, tr::Integer=1)
    Bool(parse(ask(ins, ":CALC#:TRAC#:MARK#:FUNC:TRAC?", ch, tr, m))::Int)
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
[:DISP:WIND#:TRAC#:STAT][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/display/scpi_display_window_ch_trace_tr_state.htm]

Turn on or off display of trace `tr` of channel `ch`.
"""
function inspect(ins::E5071C, ::Type{TraceDisplay}, ch::Integer=1, tr::Integer=1)
    Bool(parse(ask(ins, ":DISP:WIND#:TRAC#:STAT?", ch, tr))::Int)
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

trig1(ins::E5071C) = write(ins, ":TRIG:SING")

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
_reformat(x::E5071C, ::Type{VNA.RealPart}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{VNA.ImagPart}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{VNA.ExpandedPhase}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{VNA.PositivePhase}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{VNA.Calibrated}, data) =
    reinterpret(Complex{Float64}, data)
_reformat{T<:VNA.Format}(x::E5071C, ::Type{T}, data) =
    reinterpret(NTuple{2,Float64}, data)

function search(ins::E5071C, m::MarkerSearch{:Global}, exec::Bool=true)
    write(ins, ":CALC#:TRAC#:MARK#:TYPE #", m.ch, m.tr, m.m, code(ins, m.pol))
    errors(ins)
    exec && _search(ins, m)
end

function search{T}(ins::E5071C, m::MarkerSearch{T}, exec::Bool=true)
    write(ins, _type(ins, m), m.ch, m.tr, m.m)
    write(ins, _val(ins, m),  m.ch, m.tr, m.m, m.val)
    write(ins, _pol(ins, m),  m.ch, m.tr, m.m, code(ins, m.pol))
    errors(ins)
    exec && _search(ins, m)
end

function _search(ins::E5071C, m::MarkerSearch)
    write(ins, ":CALC#:TRAC#:MARK#:FUNC:EXEC", m.ch, m.tr, m.m)
    f = eval(parse(ask(ins, ":CALC#:TRAC#:MARK#:DATA?", m.ch, m.tr, m.m)))[3]
    try
        errors(ins)
    catch e
        if isa(e, InstrumentException)
            for x in e.val
                peaknotfound(ins,x) || rethrow(e)
            end
            f = NaN
        else
            rethrow(e)
        end
    end
    f
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

code(::E5071C,  ::VNA.Positive) = "POS"
code(::E5071C,  ::VNA.Negative) = "NEG"
code(::E5071C,  ::VNA.Both)    = "BOTH"

peaknotfound(::E5071C, val::Integer) = (val == 41)

function screen(ins::E5071C, filename::AbstractString="screen.png", display::Bool=true)
    rempath = "D:\\screen.png"
    write(ins, ":MMEM:STOR:IMAG #", quoted(rempath))
    getfile(ins, rempath, filename)
    display && FileIO.load(filename)
end

window(::E5071C, ::Type{Val{Mat([1])}}) = "D1"
window(::E5071C, ::Type{Val{Mat([1 2])}}) = "D12"
window(::E5071C, ::Type{Val{Mat([1,2])}}) = "D1_2"
window(::E5071C, ::Type{Val{Mat([1 1 2])}}) = "D112"
window(::E5071C, ::Type{Val{Mat([1,1,2])}}) = "D1_1_2"
window(::E5071C, ::Type{Val{Mat([1 2 3])}}) = "D123"
window(::E5071C, ::Type{Val{Mat([1,2,3])}}) = "D1_2_3"
window(::E5071C, ::Type{Val{Mat([1 2; 3 3])}}) = "D12_33"
window(::E5071C, ::Type{Val{Mat([1 1; 2 3])}}) = "D11_23"
window(::E5071C, ::Type{Val{Mat([1 3; 2 3])}}) = "D13_23"
window(::E5071C, ::Type{Val{Mat([1 2; 1 3])}}) = "D12_13"
window(::E5071C, ::Type{Val{Mat([1 2 3 4])}}) = "D1234"
window(::E5071C, ::Type{Val{Mat([1,2,3,4])}}) = "D1_2_3_4"
window(::E5071C, ::Type{Val{Mat([1 2;3 4])}}) = "D12_34"
window(::E5071C, ::Type{Val{Mat([1 2 3; 4 5 6])}}) = "D123_456"
window(::E5071C, ::Type{Val{Mat([1 2; 3 4; 5 6])}}) = "D12_34_56"
window(::E5071C, ::Type{Val{Mat([1 2 3 4; 5 6 7 8])}}) = "D1234_5678"
window(::E5071C, ::Type{Val{Mat([1 2; 3 4; 5 6; 7 8])}}) = "D12_34_56_78"
window(::E5071C, ::Type{Val{Mat([1 2 3; 4 5 6; 7 8 9])}}) = "D123_456_789"
window(::E5071C, ::Type{Val{Mat([1 2 3; 4 5 6; 7 8 9; 10 11 12])}}) = "D123__ABC"
window(::E5071C, ::Type{Val{Mat([1 2 3 4; 5 6 7 8; 9 10 11 12])}}) = "D1234__9ABC"
window(::E5071C, ::Type{Val{Mat([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16])}}) = "D1234__DEFG"

end
