"Definitions specific to VNAs."
module VNA

importall PainterQB
import FixedSizeArrays
import Base: search

include(joinpath(Pkg.dir("PainterQB"),"src/meta/Properties.jl"))

export InstrumentVNA
export FrequencyCenter, FrequencySpan
export MarkerSearch

# export Format, Parameter
export clearavg, data, search, shotgun

"Assume that all VNAs support VISA."
abstract InstrumentVNA  <: InstrumentVISA

abstract Averaging        <: InstrumentProperty
abstract AveragingFactor  <: InstrumentProperty{Int}

"Signals may propagate on coax or waveguide media."
abstract ElectricalMedium <: InstrumentProperty

"Post-processing and display formats typical of VNAs."
abstract Format         <: InstrumentProperty

abstract FrequencyCenter <: InstrumentProperty{Float64}
abstract FrequencySpan   <: InstrumentProperty{Float64}

"Graph layout specified by a matrix."
abstract Graphs         <: InstrumentProperty

"IF bandwidth for a VNA."
abstract IFBandwidth    <: InstrumentProperty{Float64}

"Marker state (on/off)."
abstract Marker         <: InstrumentProperty

"Stimulus value for a marker."
abstract MarkerX        <: InstrumentProperty{Float64}

"Response value for a marker."
abstract MarkerY        <: InstrumentProperty

"Number of traces."
abstract NumTraces      <: InstrumentProperty

"VNA measurement parameter, e.g. S11, S12, etc."
abstract Parameter      <: InstrumentProperty
abstract SParameter     <: Parameter
abstract ABCDParameter  <: Parameter

"Polarity for peak and dip searching with VNAs."
abstract Polarity

"Positive polarity (a peak)."
immutable Positive <: Polarity end

"Negative polarity (a dip)."
immutable Negative <: Polarity end

"Both polarities (peak or dip)."
immutable Both <: Polarity end

"""
`immutable MarkerSearch{T}`

Type encapsulating a marker search query. The type parameter should be a
symbol specifying the search type. The available options may depend on
VNA capabilities.

The E5071C supports:

```jl
:Max
:Min
:Peak
:LeftPeak
:RightPeak
:Target
:LeftTarget
:RightTarget
```
"""
immutable MarkerSearch{T}
    ch::Int
    tr::Int
    m::Int
    val::Float64
    pol::Polarity
end

"""
You are recommended to construct a `MarkerSearch` object using this function,
which makes a suitable one given the type of search you want to do
(specified by `typ::Symbol`), the channel `ch`, trace `tr`, marker number `m`,
value `val` and polarity `pol::Polarity` (`Positive()`, `Negative()`, or `Both()`).
The value will depend on what you're doing but is typically a peak excursion
or transition threshold.
"""
function MarkerSearch(typ::Symbol, ch, tr, m, val=0.0, pol::Polarity=Both())
    typ == :Max && return MarkerSearch{:Global}(ch, tr, m, 0.0, Positive())
    typ == :Min && return MarkerSearch{:Global}(ch, tr, m, 0.0, Negative())
    typ == :Bandwidth && return MarkerSearch{:Bandwidth}(ch, tr, m, val, Both())
    return MarkerSearch{typ}(ch, tr, m, val, pol)
end

subtypesArray = [
    (:Coaxial,                  ElectricalMedium),
    (:Waveguide,                ElectricalMedium),

    # True formatting types
    # Format refers to e.g. log magnitude, phase, Smith chart, etc.
    (:LogMagnitude,             Format),
    (:Phase,                    Format),
    (:GroupDelay,               Format),
    (:SmithLinear,              Format),
    (:SmithLog,                 Format),
    (:SmithComplex,             Format),
    (:Smith,                    Format),
    (:SmithAdmittance,          Format),
    (:PolarLinear,              Format),
    (:PolarLog,                 Format),
    (:PolarComplex,             Format),
    (:LinearMagnitude,          Format),
    (:SWR,                      Format),
    (:RealPart,                 Format),
    (:ImagPart,                 Format),
    (:ExpandedPhase,            Format),
    (:PositivePhase,            Format),

    # From high-level to low-level...
    # These formats should just be complex numbers at various levels of processing.
    # Mathematics: Fully calibrated data, including trace mathematics.
    # Calibrated:  Fully calibrated data.
    # Factory:     Factory calibrated data.
    # Raw:         Uncorrected data in the most raw form possible for a given VNA.
    (:Mathematics,              Format),
    (:Calibrated,               Format),
    (:Factory,                  Format),
    (:Raw,                      Format),

    (:S11,                      SParameter),
    (:S12,                      SParameter),
    (:S21,                      SParameter),
    (:S22,                      SParameter),
]

for (subtypeSymb,supertype) in subtypesArray
    generate_properties(subtypeSymb, supertype, false)
end

"Read the data from the VNA."
function data end





"""
`clearavg(ins::InstrumentVNA, ch::Integer=1)`

SENSe#:AVERage:CLEar
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_average_clear.htm]
[ZNB20][https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/ff10e010f00d4b14.htm#ID_f98b8f87fa95f4f10a00206a01537005-1a87cdf1fa95ef340a00206a01a6673d-en-US]

Restart averaging for a given channel `ch` (defaults to 1).
"""
function clearavg(ins::InstrumentVNA, ch::Integer=1)
    write(ins, ":SENS#:AVER:CLE", ch)
end

"Fallback method assumes we cannot do what is requested."
datacmd{T<:Format}(x::InstrumentVNA, ::Type{T}) = error("Not supported for this VNA.")

"""
Can execute marker searches defined by any number of MarkerSearch objects.
"""
search(ins::InstrumentVNA, m1::MarkerSearch, m2::MarkerSearch, m3::MarkerSearch...) =
    [search(ins, s) for s in [m1, m2, m3...]]

"""
Markers with numbers in the range `m` are spread across the frequency span.
The first marker begins at the start frequency but the last marker is
positioned before the stop frequency, such that each marker has the same
frequency span to the right of it within the stimulus window.
"""
function shotgun(ins::InstrumentVNA, m::AbstractArray=collect(1:9),
        ch::Integer=1, tr::Integer=1)
    f1, f2 = inspect(ins, ((FrequencyStart, ch),
                           (FrequencyStop, ch)))
    fs = linspace(f1,f2,length(m)+1)
    for marker in 1:length(m)
        configure(ins, Marker,  m[marker], true, ch, tr)
        configure(ins, MarkerX, m[marker], fs[marker], ch, tr)
    end
end

shotgun(ins::InstrumentVNA, m::OrdinalRange=1:9, ch::Integer=1, tr::Integer=1) =
    shotgun(ins, collect(m), ch, tr)

"Determines if an error code reflects a peak search failure."
function peaknotfound end

"How to specify a window layout in a command string, given a matrix."
function window end


"""
`configure(ins::InstrumentVNA, ::Type{Averaging}, b::Bool, ch::Integer=1)`

SENSe#:AVERage
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_average_state.htm]
[ZNB20][https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/f2c90c7855f6416e.htm]

Turn on or off averaging for a given channel `ch` (defaults to 1).
"""
function configure(ins::InstrumentVNA, ::Type{Averaging}, b::Bool, ch::Integer=1)
    write(ins, ":SENS#:AVER #", ch, Int(b))
end

"""
`configure(ins::InstrumentVNA, ::Type{AveragingFactor}, b::Integer, ch::Integer=1)`

SENSe#:AVERage:COUNt
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_average_count.htm]
[ZNB20][https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/5f171177edec4acc.htm]

Change the averaging factor for a given channel `ch` (defaults to 1).
Invalid input may be clipped to a valid range.
"""
function configure(ins::InstrumentVNA, ::Type{AveragingFactor}, b::Integer, ch::Integer=1)
    # (1 <= b <= 999) || warn("Averaging factor $(string(b)) will be set within 1--999.")
    write(ins, ":SENS#:AVER:COUN #", ch, b)
    ret = inspect(ins, AveragingFactor, ch)
    info("Averaging factor set to "*string(ret)*".")
end

"""
`configure(ins::InstrumentVNA, ::Type{FrequencyCenter}, b::Real, ch::Integer=1)`

SENSe#:FREQuency:CENTer
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_center.htm]
[ZNB20][https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/42d8825bb9304f5a.htm]

Change the center frequency for a given channel `ch` (defaults to 1).
Invalid input will be clipped to valid range.
"""
function configure(ins::InstrumentVNA, ::Type{FrequencyCenter}, b::Real, ch::Integer=1)
    write(ins, ":SENS#:FREQ:CENT #", ch, float(b))
    ret = inspect(ins, FrequencyCenter, ch)
    info("Center set to "*string(ret)*" Hz.")
end

"""
`configure(ins::InstrumentVNA, ::Type{FrequencySpan}, b::Real, ch::Integer=1)`

SENSe#:FREQuency:SPAN
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_span.htm]
[ZNB20][https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/880fb7cf42594d10.htm]

Change the frequency span for a given channel `ch` (defaults to 1).
Invalid input will be clipped to valid range.
"""
function configure(ins::InstrumentVNA, ::Type{FrequencySpan}, b::Real, ch::Integer=1)
    write(ins, ":SENS#:FREQ:SPAN #", ch, float(b))
    ret = inspect(ins, FrequencySpan, ch)
    info("Span set to "*string(ret)*" Hz.")
end

"""
`configure(ins::InstrumentVNA, ::Type{IFBandwidth}, b::Real, ch::Integer=1)`

SENSe#:BANDwidth
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_bandwidth_resolution.htm]
[ZNB20][https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/dd1fd694e0ce4dd8.htm]

Change the IF bandwidth for channel `ch` (defaults to 1).
Invalid input will be clipped to valid range.
"""
function configure(ins::InstrumentVNA, ::Type{IFBandwidth}, b::Real, ch::Integer=1)
    # Valid range reported in programming guide does not seem consistent with what happens
    # (10 <= b <= 1.5e6) || warn("IF bandwidth $(string(b)) will be set within 10--1.5e6.")
    write(ins, ":SENS#:BAND #", ch, float(b))
    ret = inspect(ins, IFBandwidth, ch)
    info("IF bandwidth set to "*string(ret)*" Hz.")
end

"""
`inspect(ins::InstrumentVNA, ::Type{Averaging}, ch::Integer=1)`

SENSe#:AVERage
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_average_state.htm]
[ZNB20][https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/f2c90c7855f6416e.htm]

Is averaging on for a given channel `ch` (defaults to 1)?
"""
function inspect(ins::InstrumentVNA, ::Type{Averaging}, ch::Integer=1)
    Bool(parse(ask(ins, ":SENS#:AVER?", ch))::Int)
end

"""
`inspect(ins::InstrumentVNA, ::Type{AveragingFactor}, ch::Integer=1)`

SENSe#:AVERage:COUNt
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_average_count.htm]
[ZNB20][https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/5f171177edec4acc.htm]

What is the averaging factor for a given channel `ch` (defaults to 1)?
"""
function inspect(ins::InstrumentVNA, ::Type{AveragingFactor}, ch::Integer=1)
    parse(ask(ins, ":SENS#:AVER:COUN?", ch))::Int
end

"""
`inspect(ins::InstrumentVNA, ::Type{FrequencyCenter}, ch::Integer=1)`

SENSe#:FREQuency:CENTer
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_center.htm]
[ZNB20][https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/42d8825bb9304f5a.htm]

Inspect the center frequency for a given channel `ch` (defaults to 1).
Invalid input will be clipped to valid range.
"""
function inspect(ins::InstrumentVNA, ::Type{FrequencyCenter}, ch::Integer=1)
    parse(ask(ins, ":SENS#:FREQ:CENT?", ch))::Float64
end

"""
`inspect(ins::InstrumentVNA, ::Type{FrequencySpan}, ch::Integer=1)`

SENSe#:FREQuency:SPAN
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_frequency_span.htm]
[ZNB20][https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/880fb7cf42594d10.htm]

Inspect the frequency span for a given channel `ch` (defaults to 1).
Invalid input will be clipped to valid range.
"""
function inspect(ins::InstrumentVNA, ::Type{FrequencySpan}, ch::Integer=1)
    parse(ask(ins, ":SENS#:FREQ:SPAN?", ch))::Float64
end

"""
`inspect(ins::InstrumentVNA, ::Type{IFBandwidth}, ch::Integer=1)`

SENSe#:BANDwidth
[E5071C][http://ena.support.keysight.com/e5071c/manuals/webhelp/eng/programming/command_reference/sense/scpi_sense_ch_bandwidth_resolution.htm]
[ZNB20][https://www.rohde-schwarz.com/webhelp/znb_znbt_webhelp_en_6/Content/dd1fd694e0ce4dd8.htm]

Inspect the IF bandwidth for channel `ch` (defaults to 1).
"""
function inspect(ins::InstrumentVNA, ::Type{IFBandwidth}, ch::Integer=1)
    parse(ask(ins, ":SENS#:BAND?", ch))::Float64
end

end
