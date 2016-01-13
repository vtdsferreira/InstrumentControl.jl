# Instrument properties
export InstrumentProperty
export NoArgs

# Properties common to many instruments and representable by codes
export Coupling
export DataRepresentation
export ClockSlope
export ClockSource
export OscillatorSource
export TriggerImpedance
export TriggerOutputTiming
export TriggerOutputPolarity
export TriggerSlope
export TriggerSource
export SampleRate
export Search
export SParameter

# Properties common to many instruments and representable by bits types
export Frequency
export FrequencyStart
export FrequencyStop
export NumPoints
export Output
export Power
export TriggerLevel

# Exceptions for instruments
export InstrumentException

# Miscellaneous stuff
export All

# Functions shared by multiple instruments
global code, configure, inspect
global phase_rad, set_phase_rad
global samplerate, set_samplerate
global referenceoscillator_source, set_referenceoscillator_source
global options

export code, configure, inspect
export phase_rad, set_phase_rad
export samplerate, set_samplerate
export referenceoscillator_source, set_referenceoscillator_source
export options

export Instrument

"""
Abstract supertype representing an instrument.
"""
abstract Instrument

"""
Abstract parametric supertype representing communications with an instrument.

Each *abstract* subtype one level down should represent a logical state of the
instrument configuration, e.g. `TriggerSource` may be have concrete
subtypes `ExternalTrigger` or `InternalTrigger`.

To retrieve what one has to send the AWG from the type signature, we have
defined a function `code`.
"""
abstract InstrumentProperty{T}

"Used internally to indicate that a property takes no argument."
abstract NoArgs

"Clock may tick on a rising or falling slope."
abstract ClockSlope            <: InstrumentProperty

"Clock source can be internal or external."
abstract ClockSource           <: InstrumentProperty

"Signals may be AC or DC coupled."
abstract Coupling              <: InstrumentProperty

abstract DataRepresentation    <: InstrumentProperty

"Oscillator source can be internal or external."
abstract OscillatorSource      <: InstrumentProperty

"The sample rate for digitizing, synthesizing, etc."
abstract SampleRate            <: InstrumentProperty{Float64}

abstract Search                <: InstrumentProperty

"Scattering parameter, e.g. S11, S12, etc."
abstract SParameter            <: InstrumentProperty

abstract State                 <: InstrumentProperty
abstract TriggerOutputTiming   <: InstrumentProperty
abstract TriggerOutputPolarity <: InstrumentProperty

"Trigger input impedance may be 50 Ohm or 1 kOhm."
abstract TriggerImpedance      <: InstrumentProperty

"Trigger engine can fire on a rising or falling slope."
abstract TriggerSlope          <: InstrumentProperty

"Trigger may be sourced from: internal, external, bus, etc."
abstract TriggerSource         <: InstrumentProperty

"Fixed frequency of a sourced signal."
abstract Frequency             <: InstrumentProperty{Float64}

"Start frequency of a fixed range."
abstract FrequencyStart        <: InstrumentProperty{Float64}

"Stop frequency of a fixed range."
abstract FrequencyStop         <: InstrumentProperty{Float64}

"Number of points per sweep."
abstract NumPoints            <: InstrumentProperty

"Boolean output state of an instrument."
abstract Output                <: InstrumentProperty{Bool}

"Output power level."
abstract Power                 <: InstrumentProperty{Float64}

"Trigger level."
abstract TriggerLevel          <: InstrumentProperty{Float64}

"""
Exception to be thrown by an instrument. Fields include the instrument in error
`ins::Instrument`, the error code `val::Int64`, and a `humanReadable` Unicode
string.
"""
immutable InstrumentException <: Exception
    ins::Instrument
    val::Int64
    humanReadable::UTF8String
end

# The subtypesArray is used to generate concrete types of the abstract subtypes
# of InstrumentProperty (see just above for some examples). The keys are strings containing
# the names of the concrete types, and the values are the respective abstract types.
subtypesArray = [
    (:RisingClock,              ClockSlope),
    (:FallingClock,             ClockSlope),

    (:InternalClock,            ClockSource),
    (:ExternalClock,            ClockSource),

    (:AC,                       Coupling),
    (:DC,                       Coupling),

    (:LogMagnitude,             DataRepresentation),
    (:Phase,                    DataRepresentation),
    (:GroupDelay,               DataRepresentation),
    (:SmithLinear,              DataRepresentation),
    (:SmithLog,                 DataRepresentation),
    (:SmithComplex,             DataRepresentation),
    (:Smith,                    DataRepresentation),
    (:SmithAdmittance,          DataRepresentation),
    (:PolarLinear,              DataRepresentation),
    (:PolarLog,                 DataRepresentation),
    (:PolarComplex,             DataRepresentation),
    (:LinearMagnitude,          DataRepresentation),
    (:SWR,                      DataRepresentation),
    (:RealPart,                 DataRepresentation),
    (:ImaginaryPart,            DataRepresentation),
    (:ExpandedPhase,            DataRepresentation),
    (:PositivePhase,            DataRepresentation),

    (:InternalOscillator,       OscillatorSource),
    (:ExternalOscillator,       OscillatorSource),

    (:Max,                      Search),
    (:Min,                      Search),
    (:Peak,                     Search),
    (:LeftPeak,                 Search),
    (:RightPeak,                Search),
    (:Target,                   Search),
    (:LeftTarget,               Search),
    (:RightTarget,              Search),

    (:S11,                      SParameter),
    (:S12,                      SParameter),
    (:S21,                      SParameter),
    (:S22,                      SParameter),

    (:Trigger50Ohms,            TriggerImpedance),
    (:Trigger1kOhms,            TriggerImpedance),

    (:TrigOutPosPolarity,       TriggerOutputPolarity),
    (:TrigOutNegPolarity,       TriggerOutputPolarity),

    (:TrigOutBeforeMeasuring,   TriggerOutputTiming),
    (:TrigOutAfterMeasuring,    TriggerOutputTiming),

    (:RisingTrigger,            TriggerSlope),
    (:FallingTrigger,           TriggerSlope),

    (:InternalTrigger,          TriggerSource),
    (:ExternalTrigger,          TriggerSource),
    (:ManualTrigger,            TriggerSource),
    (:BusTrigger,               TriggerSource),
    (:MultipleTrigger,          TriggerSource),

]::Array{Tuple{Symbol,DataType},1}

# Create all the concrete types we need using the generate_properties function.
include("Metaprogramming.jl")
for ((subtypeSymb,supertype) in subtypesArray)
    generate_properties(subtypeSymb, supertype)
end
# Note that it is tempting to do this as a macro, but you are not allowed to
# export from a local scope, so there are some headaches with for loops, etc.

"The All type is meant to be dispatched upon and not instantiated."
immutable All
end

"Splat tuples into new inspect commands."
inspect(ins::Instrument, args::Tuple{Vararg}) =
    map((x)->inspect(ins,x...),(args...))

"Allow inspecting mulitple properties at once."
inspect(ins::Instrument, args::Tuple{Vararg{DataType}}) =
    map((x)->inspect(ins,x),(args...))
