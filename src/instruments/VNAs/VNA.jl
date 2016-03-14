"Definitions specific to VNAs."
module VNA
import PainterQB: InstrumentProperty, InstrumentVISA, TransferFormat

include(joinpath(Pkg.dir("PainterQB"),"src/meta/Properties.jl"))

export InstrumentVNA, ElectricalMedium, Format, MarkerSearch, Parameter
export clearavg, data, search

"Assume that all VNAs support VISA."
abstract InstrumentVNA  <: InstrumentVISA

"Signals may propagate on coax or waveguide media."
abstract ElectricalMedium <: InstrumentProperty

"Post-processing and display formats typical of VNAs."
abstract Format         <: InstrumentProperty

"VNA measurement parameter, e.g. S11, S12, etc."
abstract Parameter      <: InstrumentProperty
abstract SParameter     <: Parameter
abstract ABCDParameter  <: Parameter

"""
Object encapsulating a marker search query. The type parameter should be a
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
    pol::Bool
end

function MarkerSearch(typ::Symbol, ch, tr, m, val=0.0, pol::Bool=true)
    typ == :Max && return MarkerSearch{:Global}(ch, tr, m, 0.0, true)
    typ == :Min && return MarkerSearch{:Global}(ch, tr, m, 0.0, false)
    typ == :Bandwidth && return MarkerSearch{:Bandwidth}(ch, tr, m, val, true)
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
function search(ins::InstrumentVNA, m1::MarkerSearch, m2::MarkerSearch, m3::MarkerSearch...)
    for s in [m1, m2, m3...]
        search(ins, s)
    end
end

end
