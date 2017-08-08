module E5071C
import Base: getindex, setindex!
import VISA
importall InstrumentControl
importall InstrumentControl.VNA
import InstrumentControl.VNA:
    autoscale,
    nummarkers,
    peaknotfound,
    trig1,
    window
import FileIO
import InstrumentControl: getdata
import StaticArrays: SArray, @SArray

returntype(::Type{Bool}) = (Int, Bool)
returntype(::Type{Real}) = (Float64, Float64)
returntype(::Type{Integer}) = (Int, Int)
fmt(v::Bool) = string(Int(v))
fmt(v) = string(v)

@generate_all(InstrumentControl.meta["E5071C"])

export GraphLayout
export SearchTracking
export WindowLayout
export SetActiveMarker
export SetActiveChannel

export autoscale,
    nummarkers,
    trig1

export screen, search
export stimdata, data
export mktrace

# The E5071C has rather incomplete support for referring to traces by name.
# We will maintain an internal description of what names correspond to what
# trace numbers.

abstract type GraphLayout      <: InstrumentProperty end
abstract type SearchTracking   <: InstrumentProperty end
abstract type WindowLayout     <: InstrumentProperty end
abstract type SetActiveMarker  <: InstrumentProperty end
abstract type SetActiveChannel <: InstrumentProperty end

function setindex!(ins::InsE5071C, b::Bool, ::Type{VNA.Marker}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    write(ins, "CALC#:TRAC#:MARK# #", ch, tr, m, Int(b))
end

function setindex!(ins::InsE5071C, b::Real, ::Type{VNA.MarkerX}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    write(ins, "CALC#:TRAC#:MARK#:X #", ch, tr, m, float(b))
end

function setindex!(ins::InsE5071C, b::Bool, ::Type{VNA.SearchTracking}, m::Integer, ch::Integer=1, tr::Integer=1)
    write(ins, ":CALC#:TRAC#:MARK#:FUNC:TRAC #", ch, tr, m, Int(b))
end

function setindex!(ins::InsE5071C, a::AbstractArray{Int}, ::Type{VNA.Graphs}, ch::Integer=1)
    write(ins, ":DISP:WIND#:SPL #", ch, window(ins, Val{SArray{Tuple{size(a)...}}(a)}))
end

function getindex(ins::InsE5071C, ::Type{VNA.Marker}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    Bool(parse(ask(ins, "CALC#:TRAC#:MARK#?", ch, tr, m))::Int)
end

function getindex(ins::InsE5071C, ::Type{VNA.MarkerX}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    parse(ask(ins, "CALC#:TRAC#:MARK#:X?", ch, tr, m))::Float64
end

function getindex(ins::InsE5071C, ::Type{VNA.MarkerY}, m::Integer, ch::Integer=1, tr::Integer=1)
    1 <= m <= 10 || error("Invalid marker number.")
    data = getdata(ins, :String, "CALC#:TRAC#:MARK#:Y?", ch, tr, m)
    _reformat(ins, data, ch, tr)[1]
end

function getindex(ins::InsE5071C, ::Type{VNA.SearchTracking}, m::Integer, ch::Integer=1, tr::Integer=1)
    Bool(parse(ask(ins, ":CALC#:TRAC#:MARK#:FUNC:TRAC?", ch, tr, m))::Int)
end

function autoscale(ins::InsE5071C, ch::Integer=1, tr::Integer=1)
    write(ins, ":DISP:WIND#:TRAC#:Y:AUTO", ch, tr)
    return nothing
end

function stimdata(ins::InsE5071C, ch::Int=1)
    xfer = ins[TransferFormat]
    getdata(ins, xfer, ":SENSe"*string(ch)*":FREQuency:DATA?")
end

function data(ins::InsE5071C, ::Type{Val{T}}, ch::Integer=1, tr::Integer=1) where {T}
    ins[VNA.Format, ch, tr] = T
    xfer = ins[TransferFormat]
    cmdstr = datacmd(ins, Val{T})
    cmdstr = replace(cmdstr, "#", string(ch), 1)
    cmdstr = replace(cmdstr, "#", string(tr), 1)
    data = getdata(ins, xfer, cmdstr)
    _reformat(ins, Val{T}, data)
end

function data(ins::InsE5071C, processing::Type{Val{:Raw}}, ch::Integer=1, tr::Integer=1)
    # Get measurement parameter
    mpar = ins[VNA.Parameter, ch, tr]
    !(mpar ∈ [:S11, :S12, :S21, :S22]) &&
        error("Raw data must represent a wave quantity or ratio.")

    xfer = ins[TransferFormat]
    cmdstr = datacmd(ins, processing)
    cmdstr = replace(cmdstr,"#",string(ch),1)
    cmdstr = replace(cmdstr,"#",code(ins,mpar),1)
    data = getdata(ins, xfer, cmdstr)
    reinterpret(Complex{Float64}, data)
end

trig1(ins::InsE5071C) = write(ins, ":TRIG:SING")

nummarkers(ins::InsE5071C) = 9

function datacmd(x::InsE5071C, s)
    if s == :Raw
        ":SENS#:DATA:RAWD? #"
    elseif s == :Calibrated
        ":CALC#:TRAC#:DATA:SDAT?"
    else
        ":CALC#:TRAC#:DATA:FDAT?"
    end
end

_reformat(x::InsE5071C, ::Type{Val{:LogMagnitude}}, data) =
    view(data, 1:2:length(data))
_reformat(x::InsE5071C, ::Type{Val{:Phase}}, data) =
    view(data, 1:2:length(data))
_reformat(x::InsE5071C, ::Type{Val{:GroupDelay}}, data) =
    view(data, 1:2:length(data))
_reformat(x::InsE5071C, ::Type{Val{:SmithLinear}}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::InsE5071C, ::Type{Val{:SmithLog}}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::InsE5071C, ::Type{Val{:SmithComplex}}, data) =
    reinterpret(Complex{Float64}, data)
_reformat(x::InsE5071C, ::Type{Val{:Smith}}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::InsE5071C, ::Type{Val{:SmithAdmittance}}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::InsE5071C, ::Type{Val{:PolarLinear}}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::InsE5071C, ::Type{Val{:PolarLog}}, data) =
    reinterpret(NTuple{2,Float64}, data)
_reformat(x::InsE5071C, ::Type{Val{:PolarComplex}}, data) =
    reinterpret(Complex{Float64}, data)
_reformat(x::InsE5071C, ::Type{Val{:LinearMagnitude}}, data) =
    view(data, 1:2:length(data))
_reformat(x::InsE5071C, ::Type{Val{:SWR}}, data) =
    view(data, 1:2:length(data))
_reformat(x::InsE5071C, ::Type{Val{:RealPart}}, data) =
    view(data, 1:2:length(data))
_reformat(x::InsE5071C, ::Type{Val{:ImagPart}}, data) =
    view(data, 1:2:length(data))
_reformat(x::InsE5071C, ::Type{Val{:ExpandedPhase}}, data) =
    view(data, 1:2:length(data))
_reformat(x::InsE5071C, ::Type{Val{:PositivePhase}}, data) =
    view(data, 1:2:length(data))
_reformat(x::InsE5071C, ::Type{Val{:Calibrated}}, data) =
    reinterpret(Complex{Float64}, data)
_reformat(x::InsE5071C, ::Type{Val{T}}, data) where {T} =
    reinterpret(NTuple{2,Float64}, data)

function search(ins::InsE5071C, m::MarkerSearch{:Global}, exec::Bool=true)
    write(ins, ":CALC#:TRAC#:MARK#:TYPE #", m.ch, m.tr, m.m, code(ins, m.pol))
    errors(ins)
    exec && _search(ins, m)
end

function search(ins::InsE5071C, m::MarkerSearch{T}, exec::Bool=true) where {T}
    write(ins, _type(ins, m), m.ch, m.tr, m.m)
    write(ins, _val(ins, m),  m.ch, m.tr, m.m, m.val)
    write(ins, _pol(ins, m),  m.ch, m.tr, m.m, code(ins, m.pol))
    errors(ins)
    if exec
        return _search(ins, m)
    end
end

function _search(ins::InsE5071C, m::MarkerSearch)
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

function _search(ins::InsE5071C, m::MarkerSearch{:Bandwidth})
    ask(ins, ":CALC#:MARK#:BWID:DATA?", m.ch, m.m)
end

_type(::InsE5071C, ::MarkerSearch{:Peak})         = ":CALC#:TRAC#:MARK#:FUNC:TYPE PEAK"
_type(::InsE5071C, ::MarkerSearch{:LeftPeak})     = ":CALC#:TRAC#:MARK#:FUNC:TYPE LPE"
_type(::InsE5071C, ::MarkerSearch{:RightPeak})    = ":CALC#:TRAC#:MARK#:FUNC:TYPE RPE"
_type(::InsE5071C, ::MarkerSearch{:Target})       = ":CALC#:TRAC#:MARK#:FUNC:TYPE TARG"
_type(::InsE5071C, ::MarkerSearch{:LeftTarget})   = ":CALC#:TRAC#:MARK#:FUNC:TYPE LTAR"
_type(::InsE5071C, ::MarkerSearch{:RightTarget})  = ":CALC#:TRAC#:MARK#:FUNC:TYPE RTAR"
_type(::InsE5071C, ::MarkerSearch{:Bandwidth})    = ""

_val(::InsE5071C,  ::MarkerSearch{:Peak})         = ":CALC#:TRAC#:MARK#:FUNC:PEXC #"
_val(::InsE5071C,  ::MarkerSearch{:LeftPeak})     = ":CALC#:TRAC#:MARK#:FUNC:PEXC #"
_val(::InsE5071C,  ::MarkerSearch{:RightPeak})    = ":CALC#:TRAC#:MARK#:FUNC:PEXC #"
_val(::InsE5071C,  ::MarkerSearch{:Target})       = ":CALC#:TRAC#:MARK#:FUNC:TARG #"
_val(::InsE5071C,  ::MarkerSearch{:LeftTarget})   = ":CALC#:TRAC#:MARK#:FUNC:TARG #"
_val(::InsE5071C,  ::MarkerSearch{:RightTarget})  = ":CALC#:TRAC#:MARK#:FUNC:TARG #"
_val(::InsE5071C,  ::MarkerSearch{:Bandwidth})    = ":CALC#:TRAC#:MARK#:BWID:THR #"

_pol(::InsE5071C,  ::MarkerSearch{:Peak})         = ":CALC#:TRAC#:MARK#:FUNC:PPOL #"
_pol(::InsE5071C,  ::MarkerSearch{:LeftPeak})     = ":CALC#:TRAC#:MARK#:FUNC:PPOL #"
_pol(::InsE5071C,  ::MarkerSearch{:RightPeak})    = ":CALC#:TRAC#:MARK#:FUNC:PPOL #"
_pol(::InsE5071C,  ::MarkerSearch{:Target})       = ":CALC#:TRAC#:MARK#:FUNC:TTR #"
_pol(::InsE5071C,  ::MarkerSearch{:LeftTarget})   = ":CALC#:TRAC#:MARK#:FUNC:TTR #"
_pol(::InsE5071C,  ::MarkerSearch{:RightTarget})  = ":CALC#:TRAC#:MARK#:FUNC:TTR #"
_pol(::InsE5071C,  ::MarkerSearch{:Bandwidth})    = ""

code(::InsE5071C,  ::VNA.Positive) = "POS"
code(::InsE5071C,  ::VNA.Negative) = "NEG"
code(::InsE5071C,  ::VNA.Both)    = "BOTH"

peaknotfound(::InsE5071C, val::Integer) = (val == 41)

"""
```
screen(ins::InsE5071C, filename::AbstractString="screen.png", display::Bool=true)
```

Take and retrieve a local copy of a screenshot. Display the screenshot if
`display` is true.

Whatever is at `filename` on the computer calling this method will be overwritten
with the screenshot. The screenshot is also saved on the instrument.
"""
function screen(ins::InsE5071C, filename::AbstractString="screen.png", display::Bool=true)
    rempath = "D:\\screen.png"
    write(ins, ":MMEM:STOR:IMAG #", quoted(rempath))
    getfile(ins, rempath, filename)
    display && FileIO.load(filename)
end

window(::InsE5071C, ::Type{Val{@SArray([1])}}) = "D1"
window(::InsE5071C, ::Type{Val{@SArray([1 2])}}) = "D12"
window(::InsE5071C, ::Type{Val{@SArray([1,2])}}) = "D1_2"
window(::InsE5071C, ::Type{Val{@SArray([1 1 2])}}) = "D112"
window(::InsE5071C, ::Type{Val{@SArray([1,1,2])}}) = "D1_1_2"
window(::InsE5071C, ::Type{Val{@SArray([1 2 3])}}) = "D123"
window(::InsE5071C, ::Type{Val{@SArray([1,2,3])}}) = "D1_2_3"
window(::InsE5071C, ::Type{Val{@SArray([1 2; 3 3])}}) = "D12_33"
window(::InsE5071C, ::Type{Val{@SArray([1 1; 2 3])}}) = "D11_23"
window(::InsE5071C, ::Type{Val{@SArray([1 3; 2 3])}}) = "D13_23"
window(::InsE5071C, ::Type{Val{@SArray([1 2; 1 3])}}) = "D12_13"
window(::InsE5071C, ::Type{Val{@SArray([1 2 3 4])}}) = "D1234"
window(::InsE5071C, ::Type{Val{@SArray([1,2,3,4])}}) = "D1_2_3_4"
window(::InsE5071C, ::Type{Val{@SArray([1 2;3 4])}}) = "D12_34"
window(::InsE5071C, ::Type{Val{@SArray([1 2 3; 4 5 6])}}) = "D123_456"
window(::InsE5071C, ::Type{Val{@SArray([1 2; 3 4; 5 6])}}) = "D12_34_56"
window(::InsE5071C, ::Type{Val{@SArray([1 2 3 4; 5 6 7 8])}}) = "D1234_5678"
window(::InsE5071C, ::Type{Val{@SArray([1 2; 3 4; 5 6; 7 8])}}) = "D12_34_56_78"
window(::InsE5071C, ::Type{Val{@SArray([1 2 3; 4 5 6; 7 8 9])}}) = "D123_456_789"
window(::InsE5071C, ::Type{Val{@SArray([1 2 3; 4 5 6; 7 8 9; 10 11 12])}}) = "D123__ABC"
window(::InsE5071C, ::Type{Val{@SArray([1 2 3 4; 5 6 7 8; 9 10 11 12])}}) = "D1234__9ABC"
window(::InsE5071C, ::Type{Val{@SArray([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16])}}) = "D1234__DEFG"

end
