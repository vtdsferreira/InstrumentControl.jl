### Keysight / Agilent E5071C
module E5071CModule

import Base: getindex, setindex!

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

export E5071C

export GraphLayout
export SearchTracking
export WindowLayout
export SetActiveMarker
export SetActiveChannel

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

abstract GraphLayout          <: InstrumentProperty
abstract SearchTracking       <: InstrumentProperty
abstract WindowLayout         <: InstrumentProperty
abstract SetActiveMarker      <: InstrumentProperty
abstract SetActiveChannel     <: InstrumentProperty

returntype(::Type{Bool}) = (Int, Bool)
returntype(::Type{Real}) = (Float64, Float64)
returntype(::Type{Integer}) = (Int, Int)
fmt(v::Bool) = string(Int(v))
fmt(v) = string(v)

generate_all(E5071C, metadata)

# """
# [SENSe#:FREQuency:STARt][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_start.htm]
#
# Change the start frequency for a given channel `ch` (defaults to 1).
# Invalid input will be clipped to valid range.
# """
#
# """
# [SENSe#:FREQuency:STOP][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_stop.htm]
#
# Change the stop frequency for a given channel `ch` (defaults to 1).
# Invalid input will be clipped to valid range.
# """

"""
[:CALC#:TRAC#:MARK#:STATe][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_state.htm]

Turn on or off display of marker `m` for channel `ch` and trace `tr`.
"""
function setindex!(ins::E5071C, b::Bool, ::Type{VNA.Marker}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    write(ins, "CALC#:TRAC#:MARK# #", ch, tr, m, Int(b))
end

"""
:CALC#:TRAC#:MARK#:X
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_x.htm]
"""
function setindex!(ins::E5071C, b::Real, ::Type{VNA.MarkerX}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    write(ins, "CALC#:TRAC#:MARK#:X #", ch, tr, m, float(b))
end

# """
# CALC#:PAR:COUNt
# [E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_parameter_count.htm]
# """
# """
# [:SENSe#:SWEep:POINts][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_sweep_points.htm]
#
# Set the number of points to sweep over for channel `ch`.
# """
# """
# [OUTPut][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/output/scpi_output_state.htm]
#
# Turn on or off the stimulus signal output.
# """
# """
# [SOURce#:POWer][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/source/scpi_source_ch_power_level_immediate_amplitude.htm]
#
# Change the stimulus power level for channel `ch` (defaults to 1).
# Invalid input will be clipped to valid range (it depends).
# """
# """
# [CALCulate#:TRACe#:MARKer#:FUNCtion:TRACking][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_function_tracking.htm]
#
# Set whether or not the marker search for marker `m` is repeated with trace updates.
# """
function setindex!(ins::E5071C, b::Bool, ::Type{SearchTracking}, m::Integer, ch::Integer=1, tr::Integer=1)
    write(ins, ":CALC#:TRAC#:MARK#:FUNC:TRAC #", ch, tr, m, Int(b))
end
# """
# [CALCulate#:TRACe#:SMOothing:STATe][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_smoothing_state.htm]
#
# Turn on or off smoothing for a given channel `ch` and trace `tr` (default to 1).
# """
# """
# [CALCulate#:TRACe#:SMOothing:APERture][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_smoothing_aperture.htm]
#
# Change the smoothing aperture (% of sweep span value) for
# channel `ch` and trace `tr` (default to 1).
# Invalid input will be clipped to valid range (0.05--25).
# """
# """
# [:DISP:WIND#:TRAC#:STAT][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/display/scpi_display_window_ch_trace_tr_state.htm]
#
# Turn on or off display of trace `tr` of channel `ch`.
# """

"""
DISPlay:SPLit
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/display/scpi_display_split.htm]

`setindex!(ins::InstrumentVNA, ::Type{Windows}, a::AbstractArray{Int})`

Configure the layout of graph windows using a matrix to abstract the layout.
For instance, passing [1 2; 3 3] makes two windows in one row and a third window below.
"""
function setindex!(ins::E5071C, a::AbstractArray{Int}, ::Type{VNA.Graphs}, ch::Integer=1)
    write(ins, ":DISP:WIND#:SPL #", ch, window(ins, Val{FixedSizeArrays.Mat(a)}))
end

"""
[CALCulate#:TRACe#:MARKer#:STATe][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_state.htm]

Query whether marker `m` is displayed for channel `ch` and trace `tr`.
"""
function getindex(ins::E5071C, ::Type{VNA.Marker}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    Bool(parse(ask(ins, "CALC#:TRAC#:MARK#?", ch, tr, m))::Int)
end

"""
[CALCulate#:TRACe#:MARKer#:X][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_x.htm]
"""
function getindex(ins::E5071C, ::Type{VNA.MarkerX}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    parse(ask(ins, "CALC#:TRAC#:MARK#:X?", ch, tr, m))::Float64
end

"""
[CALCulate#:TRACe#:MARKer#:Y?][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_y.htm]
"""
function getindex(ins::E5071C, ::Type{VNA.MarkerY}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    data = getdata(ins, Val{:ASCIIString}, "CALC#:TRAC#:MARK#:Y?", ch, tr, m)
    _reformat(ins, data, ch, tr)[1]
end

"""
[:CALCulate#:TRACe#:MARKer#:FUNCtion:TRACking][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_marker_mk_function_tracking.htm]

Set whether or not the marker search for marker `m` is repeated with trace updates.
"""
function getindex(ins::E5071C, ::Type{SearchTracking}, m::Integer, ch::Integer=1, tr::Integer=1)
    Bool(parse(ask(ins, ":CALC#:TRAC#:MARK#:FUNC:TRAC?", ch, tr, m))::Int)
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
    xfer = ins[TransferFormat]
    getdata(ins, Val{xfer}, ":SENSe"*string(ch)*":FREQuency:DATA?")
end

"""
[Internal data processing][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/remote_control/reading-writing_measurement_data/internal_data_processing.htm]
[:CALCulate#:DATA:FDATa][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_data_fdata.htm]
[:CALCulate#:DATA:SDATa][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/calculate/scpi_calculate_ch_selected_data_sdata.htm]
"""
function data{T}(ins::E5071C, ::Type{Val{T}}, ch::Integer=1, tr::Integer=1)
    ins[VNA.Format, ch, tr] = T
    xfer = ins[TransferFormat]
    cmdstr = datacmd(ins, Val{T})
    cmdstr = replace(cmdstr, "#", string(ch), 1)
    cmdstr = replace(cmdstr, "#", string(tr), 1)
    data = getdata(ins, Val{xfer}, cmdstr)
    _reformat(ins, Val{T}, data)
end

"""
[:SENSe#:DATA:RAWData][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi.sense(ch).data.rawdata.htm]
This instrument does not associate raw data with a particular trace, but we use the
trace number to look up what S parameter should be retrieved.
"""
function data(ins::E5071C, processing::Type{Val{:Raw}}, ch::Integer=1, tr::Integer=1)
    # Get measurement parameter
    mpar = ins[VNA.Parameter, ch, tr]
    !(mpar ∈ [:S11, :S12, :S21, :S22]) &&
        error("Raw data must represent a wave quantity or ratio.")

    xfer = ins[TransferFormat]
    cmdstr = datacmd(ins, processing)
    cmdstr = replace(cmdstr,"#",string(ch),1)
    cmdstr = replace(cmdstr,"#",code(ins,mpar),1)
    data = getdata(ins, Val{xfer}, cmdstr)
    reinterpret(Complex{Float64}, data)
end

"Trigger a single sweep when TriggerSource is :Bus."
trig1(ins::E5071C) = write(ins, ":TRIG:SING")

datacmd{T}(x::E5071C, ::Type{Val{T}})        = ":CALC#:TRAC#:DATA:FDAT?"
datacmd(x::E5071C, ::Type{Val{:Calibrated}}) = ":CALC#:TRAC#:DATA:SDAT?"
datacmd(x::E5071C, ::Type{Val{:Raw}})        = ":SENS#:DATA:RAWD? #"

_reformat(x::E5071C, ::Type{Val{:LogMagnitude}}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{Val{:Phase}}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{Val{:GroupDelay}}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{Val{:SmithLinear}}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::E5071C, ::Type{Val{:SmithLog}}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::E5071C, ::Type{Val{:SmithComplex}}, data) =
    reinterpret(Complex{Float64}, data)
_reformat(x::E5071C, ::Type{Val{:Smith}}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::E5071C, ::Type{Val{:SmithAdmittance}}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::E5071C, ::Type{Val{:PolarLinear}}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::E5071C, ::Type{Val{:PolarLog}}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::E5071C, ::Type{Val{:PolarComplex}}, data) =
    reinterpret(Complex{Float64}, data)
_reformat(x::E5071C, ::Type{Val{:LinearMagnitude}}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{Val{:SWR}}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{Val{:RealPart}}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{Val{:ImagPart}}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{Val{:ExpandedPhase}}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{Val{:PositivePhase}}, data) = data[1:2:end]
_reformat(x::E5071C, ::Type{Val{:Calibrated}}, data) =
    reinterpret(Complex{Float64}, data)
_reformat{T}(x::E5071C, ::Type{Val{T}}, data) = reinterpret(NTuple{2,Float64}, data)

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
