import Base: show, showerror

# Instrument properties
export InstrumentProperty

# Properties common to many instruments and representable by codes
export Coupling
export ClockSlope
export ClockSource
export OscillatorSource
export TransferByteOrder
export TransferFormat
export TriggerImpedance
export TriggerOutputTiming
export TriggerOutputPolarity
export TriggerSlope
export TriggerSource
export SampleRate

# Properties common to many instruments and representable by bits types
export ActiveTrace
export Frequency
export FrequencyStart
export FrequencyStop
export NumPoints
export Output
export OutputPhase
export Power
export TriggerLevel

# Exceptions for instruments
export InstrumentException

# Miscellaneous stuff
export VNA

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
export stimdata

export Instrument

"""
Abstract supertype representing an instrument.
"""
abstract Instrument

"How to display an instrument, e.g. in an error."
show(io::IO, x::Instrument) = print(io, x.model)

"""
Abstract parametric supertype representing communications with an instrument.

Each *abstract* subtype one level down should represent a logical state of the
instrument configuration, e.g. `TriggerSource` may be have concrete
subtypes `ExternalTrigger` or `InternalTrigger`.

To retrieve what one has to send the AWG from the type signature, we have
defined a function `code`.
"""
abstract InstrumentProperty{T}

"Clock may tick on a rising or falling slope."
abstract ClockSlope            <: InstrumentProperty

"Clock source can be internal or external."
abstract ClockSource           <: InstrumentProperty

"Signals may be AC or DC coupled."
abstract Coupling              <: InstrumentProperty

"Oscillator source can be internal or external."
abstract OscillatorSource      <: InstrumentProperty

"The sample rate for digitizing, synthesizing, etc."
abstract SampleRate            <: InstrumentProperty{Float64}

abstract State                 <: InstrumentProperty

"Little-endian or big-endian binary transfer from an instrument?"
abstract TransferByteOrder     <: InstrumentProperty

"Format for moving data, e.g. typically ASCIIString, Float32, Float64."
abstract TransferFormat        <: InstrumentProperty

abstract TriggerOutputTiming   <: InstrumentProperty
abstract TriggerOutputPolarity <: InstrumentProperty

"Trigger input impedance may be 50 Ohm or 1 kOhm."
abstract TriggerImpedance      <: InstrumentProperty

"Trigger engine can fire on a rising or falling slope."
abstract TriggerSlope          <: InstrumentProperty

"Trigger may be sourced from: internal, external, bus, etc."
abstract TriggerSource         <: InstrumentProperty

"Active trace."
abstract ActiveTrace           <: InstrumentProperty

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

"Output phase."
abstract OutputPhase           <: InstrumentProperty{Float64}

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
    val::Array{Int,1}
    humanReadable::Array{UTF8String,1}
end

"Simple method for when there is just one error."
InstrumentException(ins::Instrument, val::Integer, hr::AbstractString) =
    InstrumentException(ins, Int[val], UTF8String[hr])

function showerror(io::IO, e::InstrumentException)
    if length(e.val) != length(e.humanReadable)
        print(io, "Error in determining the errors of $(e.ins).")
    else
        println(io,"Instrument $(e.ins) had errors:")
        for i in 1:length(e.val)
            println(io,"    $((e.val)[i]): $((e.humanReadable)[i])")
        end
    end
end

"Read the stimulus values."
function stimdata end
