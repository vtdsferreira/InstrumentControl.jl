"Definitions specific to VNAs."
module VNA
import PainterQB: InstrumentProperty, InstrumentVISA, TransferFormat
import PainterQB: inspect, _getdata

include(joinpath(Pkg.dir("PainterQB"),"src/meta/Properties.jl"))

export InstrumentVNA, Format, Parameter
export data

"Assume that all VNAs support VISA."
abstract InstrumentVNA  <: InstrumentVISA

"Post-processing and display formats typical of VNAs."
abstract Format         <: InstrumentProperty

"VNA measurement parameter, e.g. S11, S12, etc."
abstract Parameter      <: InstrumentProperty
abstract SParameter     <: Parameter
abstract ABCDParameter  <: Parameter

# From high-level to low-level...
# Format refers to e.g. log magnitude, phase, Smith chart, etc.
"How much processing should be done to the measurements before reporting?"
abstract  Processing
"Fully calibrated and formatted data, including trace mathematics."
immutable Formatted{T<:Format} <: Processing end
"Fully calibrated data, including trace mathematics."
immutable Mathematics  <: Processing end
"Fully calibrated data."
immutable Calibrated   <: Processing end
"Factory calibrated data."
immutable Factory      <: Processing end
"Uncorrected data in the most raw form possible for a given VNA."
immutable Raw          <: Processing end

subtypesArray = [
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

"Fallback method assumes we cannot do what is requested."
_procdata{T<:Processing}(x::InstrumentVNA, ::Type{T}) = error("Not supported for this VNA.")

end
