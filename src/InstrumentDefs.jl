# Instrument Codes
export InstrumentCode, NoArgs

export Network, State, Timing
export TriggerSlope, EventSlope, ClockSlope
export ClockSource, TriggerSource
export OscillatorSource, Trigger, Polarity
export Impedance, Lock, Search, SParameter
export Medium, SampleRate, DataRepresentation, Coupling

# very important
export state

# Exception for instruments
export InstrumentException

# Random stuff below
export Rate1GSps
export All

# Global and export
# macro globex(x)
#     if (isa(x,Symbol))
#         Expr(:block,Expr(:global,x),Expr(:toplevel,Expr(:export,x)))
#     else
#         x.head = :global
#         y = copy(x)
#         y.head = :export
#         Expr(:block,x,Expr(:toplevel,y))
#     end
# end
# Functions shared by multiple instruments
global triggerSource, setTriggerSource
global triggerOutputPolarity, setTriggerOutputPolarity
global startFrequency, setStartFrequency
global stopFrequency, setStopFrequency
global sampleRate, setSampleRate
global powerOn, setPowerOn
global referenceOscillatorSource, setReferenceOscillatorSource
global options

export triggerSource, setTriggerSource
export triggerOutputPolarity, setTriggerOutputPolarity
export startFrequency, setStartFrequency
export stopFrequency, setStopFrequency
export sampleRate, setSampleRate
export powerOn, setPowerOn
export referenceOscillatorSource, setReferenceOscillatorSource
export options

"""
### InstrumentCode
`abstract InstrumentCode <: Any`

Abstract supertype representing communications with an instrument.

Each *abstract* subtype one level down should represent a logical state of the
instrument configuration, e.g. `InstrumentTriggerSource` may be have concrete
subtypes `ExternalTrigger` or `InternalTrigger`.

Each *concrete* subtype two levels down is a parametric immutable type:
`InternalTrigger{AWG5014C,:INT}` encodes everything one needs to know about
how the AWG5014C represents an internal trigger in the type signature only.

To retrieve what one has to send the AWG from the type signature, we have
defined a function `state`.
"""
abstract InstrumentCode

abstract NoArgs <: InstrumentCode

abstract Network <: InstrumentCode
abstract State <: InstrumentCode
abstract Timing <: InstrumentCode
abstract ClockSlope <: InstrumentCode
abstract TriggerSlope <: InstrumentCode
abstract EventSlope <: InstrumentCode
abstract ClockSource <: InstrumentCode
abstract TriggerSource <: InstrumentCode
abstract OscillatorSource <: InstrumentCode
abstract Trigger <: InstrumentCode
abstract Polarity <: InstrumentCode
abstract Impedance <: InstrumentCode
abstract Lock <: InstrumentCode
abstract Search <: InstrumentCode
abstract SParameter <: InstrumentCode
abstract Medium <: InstrumentCode
abstract SampleRate <: InstrumentCode
abstract DataRepresentation <: InstrumentCode
abstract Coupling <: InstrumentCode

immutable InstrumentException <: Exception
        ins::Instrument
        val::Int64
        humanReadable::UTF8String
end
Base.showerror(io::IO, e::InstrumentException) = print(io, "$(e.ins): $(e.humanReadable) (error code $(e.val))")

# The subtypesArray is used to generate concrete types of the abstract subtypes
# of InstrumentCode (see just above for some examples). The keys are strings containing
# the names of the concrete types, and the values are the respective abstract types.
subtypesArray = [
    (:AC,                       Coupling),
    (:DC,                       Coupling),

    (:DHCP,                     Network),
    (:ManualNetwork,            Network),

    (:Stop,                     State),
    (:Run,                      State),
    (:Wait,                     State),

    (:Asynchronous,             Timing),    #AWG5014C
    (:Synchronous,              Timing),
    (:Before,                   Timing),    #E5071C
    (:After,                    Timing),

    (:RisingClock,              ClockSlope),
    (:FallingClock,             ClockSlope),

    (:RisingTrigger,            TriggerSlope),
    (:FallingTrigger,           TriggerSlope),

    (:RisingEvent,              EventSlope),
    (:FallingEvent,             EventSlope),

    (:PositivePolarity,         Polarity),
    (:NegativePolarity,         Polarity),

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

    (:Ohm50,                    Impedance),
    (:Ohm1k,                    Impedance),

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

# Create all the concrete types we need using the createCodeType function.
include("Metaprogramming.jl")
for ((subtypeSymb,supertype) in subtypesArray)
    createCodeType(subtypeSymb, supertype)
end
# Note that it is tempting to do this as a macro, but you are not allowed to
# export from a local scope, so there are some headaches with for loops, etc.

typealias Rate1GSps Rate1000MSps

"The All type is meant to be dispatched upon and not instantiated."
immutable All
end
