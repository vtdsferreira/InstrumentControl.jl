
# Get the resource manager
import VISA
const resourceManager = VISA.viOpenDefaultRM()

export resourceManager

export Instrument, InstrumentVISA

export InstrumentCode, NoArgs

# Instrument Codes
export Network, State, Timing
export TriggerSlope, EventSlope, ClockSlope
export ClockSource, TriggerSource
export OscillatorSource, Trigger, Polarity
export Impedance, Lock, Search, SParameter
export Medium, SampleRate, DataFormat, Coupling

# Exception for instruments
export InstrumentException

# Methods for talking to and initializing instruments
export gpib, tcpipInstrument, tcpipSocket
export query, read, write, readAvailable, binBlockWrite, binBlockReadAvailable
export test, reset, identify, clearRegisters, trigger, abortTrigger
export quoted

"""
### Instrument
`abstract Instrument <: Any`

Abstract supertype of all concrete Instrument types, e.g. `AWG5014C <: Instrument`.
"""
abstract Instrument

"""
### InstrumentVISA
`abstract InstrumentVISA <: Instrument`

Abstract supertype of all Instruments addressable using a VISA library.
Concrete types are expected to have fields:

`vi::ViSession`
`writeTerminator::ASCIIString`
"""
abstract InstrumentVISA <: Instrument

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
defined a function `state`
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

export state
function createCodeType(subtype::Symbol, supertype::DataType)
    @eval immutable ($subtype){S<:Instrument,Symbol} <: $supertype end
    @eval export $subtype
    @eval state{S<:Instrument,T}(::Type{($subtype){S,T}}) = begin
        str = string(T)
        isa(parse(str), Number) ? parse(str) : str
    end
end

# Create all the concrete types we need using the createCodeType function.
for ((subtypeSymb,supertype) in subtypesArray)
    createCodeType(subtypeSymb, supertype)
end

# Note that it is tempting to do this as a macro, but you are not allowed to
# export from a local scope, so there are some headaches with for loops, etc.

typealias Rate1GSps Rate1000MSps

"The All type is meant to be dispatched upon and not instantiated."
immutable All
end

"""
### createStateFunction

`createStateFunction{S<:Instrument,T<:Union{InstrumentCode,Number,AbstractString}}
    (instrumentType::Type{S}, fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})`

For each `command`, there may be up to two functions generated, provided `command` contains no # signs. For example, if:

```
instrumentType == AWG5014C
fnName == "triggerSource"
command == "TRIG:REF"
setArgType == InstrumentTriggerSource
```

then we would have the functions:

```
function triggerSource(ins::AWG5014C)
    result = query(ins, "TRIG:REF?")
    InstrumentTriggerSource(ins,result)
end

function setTriggerSource(ins::AWG5014C, x::Type{InstrumentTriggerSource})
    write(ins, string("TRIG:REF ",x.state))
end
```

If there were a `?` at the end of `command` then only the first function would be generated.
If `setArgType` is `NoArgs` then the second function is generated with fnName, e.g. if:

```
instrumentType == AWG5014C
fnName == "run"
command == "AWGC:RUN"
setArgType == NoArgs
```

then

```
function run(ins::AWG5014C)
    write(ins, "AWGC:RUN")
end
```

would be generated.

If we have # signs in `command`, then each function becomes a *varargs* function,
with a variable number of Int64 arguments at the end. These are used to allow for
infixing of `command` whereever a # sign is. Some commands sent to instruments need
this, especially if there are multiple channels that each respond to a command.

There are some other details buried in here.

"""
function createStateFunction{S<:Instrument,T<:Union{InstrumentCode,Number,AbstractString}}(
        instrumentType::Type{S}, fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

    createGettingFunction(instrumentType,fnName,command,setArgType)

    # Create setting function?
    if (command[end]=='?')
        return
    end

    createSettingFunction(instrumentType,fnName,command,setArgType)

end

function createStateFunction{S<:Instrument}(instrumentType::Type{S},
        fnName::ASCIIString, command::ASCIIString, setArgType::Type{NoArgs})
    nameSymb = symbol(fnName)

    @eval function ($nameSymb)(ins::$instrumentType, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
        write(ins, string(cmd))
    end

    @eval export $nameSymb
end

function createStateFunction{S<:Instrument}(instrumentType::Type{S},
        fnName::ASCIIString, command::ASCIIString, setArgType::Type{InstrumentException})

    readNameSymb = symbol(fnName)
    @eval function ($readNameSymb)(ins::$instrumentType, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
        response = query(ins, (cmd[end] == '?' ? cmd : cmd*"?"))
        ($setArgType)($instrumentType,response)
    end
    @eval export $readNameSymb
end

function createGettingFunction{S<:Instrument, T<:InstrumentCode}(instrumentType::Type{S},
        fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

    readNameSymb = symbol(fnName)
    @eval function ($readNameSymb)(ins::$instrumentType, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
        response = query(ins, (cmd[end] == '?' ? cmd : cmd*"?"))
        ($setArgType)($instrumentType,response)
    end
    @eval export $readNameSymb
end

function createGettingFunction{S<:Instrument, T<:Union{Number,AbstractString}}(
        instrumentType::Type{S}, fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

    readNameSymb = symbol(fnName)
    @eval function ($readNameSymb)(ins::$instrumentType, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
        response = query(ins, (cmd[end] == '?' ? cmd : cmd*"?"))
        ($setArgType)($setArgType <: Number ? parse(response) : response)
    end
    @eval export $readNameSymb
end

function createSettingFunction{S<:Instrument, T<:InstrumentCode}(instrumentType::Type{S},
        fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

    setNameSymb = symbol(string("set",ucfirst(fnName)))

    # # Take object as argument
    # @eval function ($setNameSymb)(ins::$instrumentType, x::$setArgType, infixes::Int64...)
    #     cmd = $command
    #     for (infix in infixes)
    #         cmd = replace(cmd,"#",infix,1)
    #     end
    #     write(ins, string(cmd," ",x.state))
    # end

    # Take type as argument
    @eval function ($setNameSymb){T<:$setArgType}(ins::$instrumentType, x::Type{T}, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
    #    @assert ($x in responseDict.values.values)
        write(ins, string(cmd," ",state((x)($instrumentType))))
    end

    @eval export $setNameSymb

end

function createSettingFunction{S<:Instrument, T<:Union{Number,AbstractString}}(
        instrumentType::Type{S}, fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

    setNameSymb = symbol(string("set",ucfirst(fnName)))

    @eval function ($setNameSymb)(ins::$instrumentType, x::$setArgType, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
        write(ins, string(cmd," ",($setArgType === Bool ? Int(x) : x)))
    end

    @eval export $setNameSymb
end

"""
### generateResponseHandlers

`generateResponseHandlers(insType::DataType, responseDict::Dict)`

Each instrument can have a `responseDictionary`. For each setting of the instrument,
for instance the `ClockSource`, we need to know the correspondence between a
logical state `ExternalClock` and how the instrument encodes that logical state, "EXT".
The responseDictionary is actually a dictionary of dictionaries. The first level keys
are like `ClockSource` and the second level keys are like "EXT".

This function makes a lot of other functions. Given some response from an instrument,
we require a function to map that response back on to the appropiate logical state.

`ClockSource(ins::AWG5014C,res::AbstractString)`
returns an `InternalClock{AWG5014C,:INT)` or `ExternalClock(AWG5014C,:EXT)` object as appropriate,
based on the logical meaning of the response.

We also want a function to generate logical states without having to know the way
they are encoded by the instrument.

`InternalClock(ins::Instrument)`
returns an `InternalClock(ins,"INT")` object, with "INT" encoding how to pass this logical state
to the instrument `ins`.
"""
function generateResponseHandlers{T<:Instrument}(insType::Type{T}, responseDict::Dict)

    for (supertypeSymb in keys(responseDict))

        # Generate response handlers for concrete InstrumentCodes to
        # make the correct concrete type.
        #
        # e.g. InstrumentInternal(AWG5014C) = InstrumentInternal{AWG5014C,symbol("INT")}
        d = responseDict[supertypeSymb]
        for response in keys(d)
            fnSymb = d[response]
            @eval ($fnSymb){S<:$insType}(g::Type{S}) = ($fnSymb){g,symbol($response)}
        end

        # Generate response handlers for abstract InstrumentCodes
        # to make the correct concrete type.
        #
        # e.g. InstrumentReference(AWG5014C, "INT") =
        #          InstrumentInternal{AWG5014C,symbol("INT")}
        @eval ($supertypeSymb)(::Type{$insType}, res::AbstractString) =
            (typeof(parse(res)) <: Number ?
            Expr(:curly, ($d)[parse(res)],  $insType, QuoteNode(symbol(res)))  :
            Expr(:curly, ($d)[res],         $insType, QuoteNode(symbol(res)))) |> eval

        @eval ($supertypeSymb)(::Type{$insType}, res::Number) =
            Expr(:call, ($d)[res], $insType, QuoteNode(symbol(res))) |> eval
    end

end

gpib(primary) = VISA.viOpen(resourceManager, "GPIB::"*primary*"::0::INSTR")
gpib(board, primary) = VISA.viOpen(resourceManager, "GPIB"*(board == 0 ? "" : board)+"::"*primary*"::0::INSTR")
gpib(board, primary, secondary) = VISA.viOpen(resourceManager, "GPIB"*(board == 0 ? "" : board)*"::"+primary+"::"+secondary+"::INSTR")
tcpipInstrument(ip) = VISA.viOpen(resourceManager, "TCPIP::"*ip*"::INSTR")
tcpipSocket(ip,port) = VISA.viOpen(resourceManager, "TCPIP0::"*ip*"::"*string(port)*"::SOCKET")
tcpipSocket(ip) = begin
    arr = split(ip,":")
    if (length(arr) == 1)
        return tcpipSocket(arr[1],5555)
    else
        return VISA.viOpen(resourceManager, "TCPIP0::"*arr[1]*"::"*arr[2]*"::SOCKET")
    end
end

function query(ins::InstrumentVISA, msg::ASCIIString, delay::Real=0)
    write(ins, msg)
    sleep(delay)
    readAvailable(ins)
end

read(ins::InstrumentVISA) = rstrip(bytestring(VISA.viRead(ins.vi)), ['\r', '\n'])
write(ins::InstrumentVISA, msg::ASCIIString) = VISA.viWrite(ins.vi, string(msg, ins.writeTerminator))
readAvailable(ins::InstrumentVISA) = rstrip(bytestring(VISA.readAvailable(ins.vi)), ['\r','\n'])
binBlockWrite(ins::InstrumentVISA,
              message::Union{ASCIIString, Vector{UInt8}},
              data::Vector{UInt8}) = VISA.binBlockWrite(ins.vi, message, data, ins.writeTerminator)
binBlockReadAvailable(ins::InstrumentVISA) = VISA.binBlockReadAvailable(ins.vi)

find_resources(expr::AbstractString="?*::INSTR") = VISA.viFindRsrc(resourceManager, expr)

# Define commands implemented by several instruments.
test(ins::InstrumentVISA)           = write(ins, "*TST?")
reset(ins::InstrumentVISA)          = write(ins, "*RST")
identify(ins::InstrumentVISA)       = query(ins, "*IDN?")
clearRegisters(ins::InstrumentVISA) = write(ins, "*CLS")
trigger(ins::InstrumentVISA)        = write(ins, "*TRG")
abortTrigger(ins::InstrumentVISA)   = write(ins, "ABOR")

quoted(str::ASCIIString) = "\""*str*"\""
