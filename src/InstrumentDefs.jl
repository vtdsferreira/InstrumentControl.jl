# Instrument Codes
export InstrumentProperty, NoArgs

export Coupling, DataRepresentation, Lock, Network, State, TriggerOutputTiming
export ClockSlope, ClockSource, EventImpedance, EventSlope, EventTiming
export OscillatorSource, Trigger, TriggerImpedance, TriggerSlope, TriggerSource
export TriggerOutputPolarity, SampleRate, Search, SParameter
export Medium

export FrequencyStart, FrequencyStop, Output

# Exception for instruments
export InstrumentException

# Random stuff below
export Rate1GSps
export All

# Functions shared by multiple instruments
global code, configure, inspect
global phase_rad, set_phase_rad
global samplerate, set_samplerate
global output_on, set_output_on
global referenceoscillator_source, set_referenceoscillator_source
global options

export code, configure, inspect
export phase_rad, set_phase_rad
export samplerate, set_samplerate
export output_on, set_output_on
export referenceoscillator_source, set_referenceoscillator_source
export options

"""
### InstrumentProperty
`abstract InstrumentProperty <: Any`

Abstract supertype representing communications with an instrument.

Each *abstract* subtype one level down should represent a logical state of the
instrument configuration, e.g. `TriggerSource` may be have concrete
subtypes `ExternalTrigger` or `InternalTrigger`.

Each *concrete* subtype two levels down is an immutable type:
`InternalTrigger(ins::AWG5014C, "INT")` encodes everything one needs to know
for how the AWG5014C represents an internal trigger.

To retrieve what one has to send the AWG from the type signature, we have
defined a function `code`.
"""
abstract InstrumentProperty

abstract NoArgs

abstract ClockSlope <: InstrumentProperty
abstract ClockSource <: InstrumentProperty
abstract Coupling <: InstrumentProperty
abstract DataRepresentation <: InstrumentProperty
abstract EventImpedance <: InstrumentProperty
abstract EventSlope <: InstrumentProperty
abstract EventTiming <: InstrumentProperty
abstract Lock <: InstrumentProperty
abstract Medium <: InstrumentProperty
abstract Network <: InstrumentProperty
abstract OscillatorSource <: InstrumentProperty
abstract SampleRate <: InstrumentProperty
abstract Search <: InstrumentProperty
abstract SParameter <: InstrumentProperty
abstract State <: InstrumentProperty
abstract TriggerOutputTiming <: InstrumentProperty
abstract TriggerOutputPolarity <: InstrumentProperty
abstract Trigger <: InstrumentProperty
abstract TriggerImpedance <: InstrumentProperty
abstract TriggerSlope <: InstrumentProperty
abstract TriggerSource <: InstrumentProperty

abstract FrequencyStart <: InstrumentProperty
abstract FrequencyStop <: InstrumentProperty
abstract Output <: InstrumentProperty

Base.show{T<:InstrumentProperty}(io::IO, code::T) =
    print(io, "$(code.logicalname) represents as $(code.code)")

immutable InstrumentException <: Exception
    ins::Instrument
    val::Int64
    humanReadable::UTF8String
end

Base.showerror(io::IO, e::InstrumentException) =
    print(io, "$(e.ins): $(e.humanReadable) (error code $(e.val))")

# The subtypesArray is used to generate concrete types of the abstract subtypes
# of InstrumentProperty (see just above for some examples). The keys are strings containing
# the names of the concrete types, and the values are the respective abstract types.
subtypesArray = [
    (:AC,                       Coupling),
    (:DC,                       Coupling),

    (:DHCP,                     Network),
    (:ManualNetwork,            Network),

    (:Stop,                     State),
    (:Run,                      State),
    (:Wait,                     State),

    (:EventAsynchronous,        EventTiming),
    (:EventSynchronous,         EventTiming),

    (:TrigOutBeforeMeasuring,   TriggerOutputTiming),
    (:TrigOutAfterMeasuring,    TriggerOutputTiming),

    (:RisingClock,              ClockSlope),
    (:FallingClock,             ClockSlope),

    (:RisingTrigger,            TriggerSlope),
    (:FallingTrigger,           TriggerSlope),

    (:RisingEvent,              EventSlope),
    (:FallingEvent,             EventSlope),

    (:TrigOutPosPolarity,       TriggerOutputPolarity),
    (:TrigOutNegPolarity,       TriggerOutputPolarity),

    (:InternalClock,            ClockSource),
    (:ExternalClock,            ClockSource),

    (:InternalTrigger,          TriggerSource),
    (:ExternalTrigger,          TriggerSource),
    (:ManualTrigger,            TriggerSource),
    (:BusTrigger,               TriggerSource),

    (:InternalOscillator,       OscillatorSource),
    (:ExternalOscillator,       OscillatorSource),

    (:Triggered,                Trigger),
    (:Continuous,               Trigger),
    (:Gated,                    Trigger),
    (:Sequence,                 Trigger),

    (:Event50Ohms,              EventImpedance),
    (:Event1kOhms,              EventImpedance),

    (:Trigger50Ohms,            TriggerImpedance),
    (:Trigger1kOhms,            TriggerImpedance),

    (:Local,                    Lock),
    (:Remote,                   Lock),

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

    (:Coaxial,                  Medium),
    (:Waveguide,                Medium),

    (:Rate1kSps,                SampleRate),
    (:Rate2kSps,                SampleRate),
    (:Rate5kSps,                SampleRate),
    (:Rate10kSps,               SampleRate),
    (:Rate20kSps,               SampleRate),
    (:Rate50kSps,               SampleRate),
    (:Rate100kSps,              SampleRate),
    (:Rate200kSps,              SampleRate),
    (:Rate500kSps,              SampleRate),
    (:Rate1MSps,                SampleRate),
    (:Rate2MSps,                SampleRate),
    (:Rate5MSps,                SampleRate),
    (:Rate10MSps,               SampleRate),
    (:Rate20MSps,               SampleRate),
    (:Rate50MSps,               SampleRate),
    (:Rate100MSps,              SampleRate),
    (:Rate200MSps,              SampleRate),
    (:Rate500MSps,              SampleRate),
    (:Rate800MSps,              SampleRate),
    (:Rate1000MSps,             SampleRate),
    (:Rate1200MSps,             SampleRate),
    (:Rate1500MSps,             SampleRate),
    (:Rate1800MSps,             SampleRate),
    (:RateUser,                 SampleRate),

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

]::Array{Tuple{Symbol,DataType},1}

# Create all the concrete types we need using the generate_properties function.
include("Metaprogramming.jl")
for ((subtypeSymb,supertype) in subtypesArray)
    generate_properties(subtypeSymb, supertype)
end
# Note that it is tempting to do this as a macro, but you are not allowed to
# export from a local scope, so there are some headaches with for loops, etc.

typealias Rate1GSps Rate1000MSps

"The All type is meant to be dispatched upon and not instantiated."
immutable All
end
