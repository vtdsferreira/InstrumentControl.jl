# This file is not a module, which is very apparently important.
#
# If we want instruments to be in their own modules, which makes some sense to
# avoid needlessly polluting the namespace for people who won't use all of the
# instruments, then this code needs to appear inside each instrument's module.
# Otherwise, if this code were in its own module `Metaprogramming`, @eval would
# get called in module `Metaprogramming` rather than the instrument's module.
# This would be a bit problematic.
#
# Nothing is exported as the user should never use these, and we don't want
# instruments to see this if it is used from our PainterQB module.

function generate_inspect{S<:Instrument,T<:InstrumentProperty}(instype::Type{S},
        command::ASCIIString, proptype::Type{T}, returntype...)

    nhash = 0
    for i in command
        i == '#' ? nhash += 1 : nothing
    end

    @eval function inspect(ins::$instype, ::Type{$proptype}, infixes::Int...)
        cmd = $command
        $nhash != length(infixes) && error(cmd," requires ",$nhash," infixes.")

        for infix in infixes
            cmd = replace(cmd,"#",infix,1)
        end

        if cmd[end] != '?'
            cmd = cmd*"?"
        end

        response = ask(ins, cmd)
        res = isa(parse(response), Number) ? parse(response) : response
        length($returntype) > 0 ? ($returntype[1])(res) : ($proptype)(ins,res)
    end

    nothing
end

function generate_configure{S<:Instrument,T<:InstrumentProperty}(instype::Type{S},
        command::ASCIIString, proptype::Type{T}, returntype...)

    nhash = 0
    for i in command
        i == '#' ? nhash += 1 : nothing
    end

    @eval function configure{T<:$proptype}(ins::$instype, x::Type{T}, args...)
        cmd = $command
        if (length($returntype) > 0)     ## configure takes an extra argument
            $nhash + 1 != length(args) &&
                error(cmd," requires a ",$returntype[1],
                    " argument and ",$nhash," infixes.")
            !isa(args[1],$returntype[1]) &&
                error(cmd," requires a ",$returntype[1]," argument.")
            for infix in args
                cmd = replace(cmd,"#",infix,1)
            end

            write(ins, string(cmd," ",isa(args[1],Bool) ? Int(args[1]) : args[1]))
        else
            x == $proptype && error("Pass a subtype of ",string($proptype)," instead.")
            $nhash != length(args) &&
                error(cmd," requires ",$nhash," infixes.")
            for infix in args
                cmd = replace(cmd,"#",infix,1)
            end
            try
                cd = code((x)(ins))
            catch
                error("This subtype not be supported for this instrument.")
            end
            write(ins, string(cmd," ",code((x)(ins))))
        end
    end

    nothing
end
# function generate_configure{S<:Instrument,T<:InstrumentProperty}(instype::Type{S},
#         cmd::ASCIIString, proptype::Type{T}, ::Type{Bool})
#
#     @eval function configure{T<:$proptype}(ins::$instype, x::Type{T}, arg::Bool)
#         write(ins, string($cmd," ",Int(arg)))
#     end
#
#     nothing
# end
#
# function generate_configure{S<:Instrument,T<:InstrumentProperty,
#         U<:Union{AbstractString, Number}}(instype::Type{S}, cmd::ASCIIString,
#         proptype::Type{T}, u::Type{U})
#
#     @eval function configure{T<:$proptype}(ins::$instype, x::Type{T}, arg::$u)
#         write(ins, string($cmd," ",arg))
#     end
#
#     nothing
# end

function createCodeType(subtype::Symbol, supertype::DataType)
    name = string(subtype)
    @eval immutable ($subtype){T} <: $supertype
        ins::Instrument
        code::T
        logicalname::AbstractString

        ($subtype)(a,b) = new(a,b,$name)
    end
    @eval ($subtype){T}(a::Instrument,b::T) = ($subtype){T}(a,b)
    @eval export $subtype
    @eval code{T}(inscode::($subtype){T}) = begin
        inscode.code::T
    end
end

"""
### createStateFunction

`createStateFunction{S<:Instrument,T<:Union{InstrumentProperty,Number,AbstractString}}
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
    result = ask(ins, "TRIG:REF?")
    TriggerSource(ins,result)
end

function setTriggerSource(ins::AWG5014C, x::Type{InstrumentTriggerSource})
    write(ins, string("TRIG:REF ", x(ins) |> state) )
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
function createStateFunction{S<:Instrument,T<:Union{InstrumentProperty,Number,AbstractString}}(
        instrumentType::Type{S}, fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

    createGettingFunction(instrumentType,fnName,command,setArgType)

    # Create setting function?
    if (command[end]=='?')
        return
    end

    createSettingFunction(instrumentType,fnName,command,setArgType)

    nothing
end

function createStateFunction{S<:Instrument}(instrumentType::Type{S},
        fnName::ASCIIString, command::ASCIIString, ::Type{NoArgs})
    nameSymb = symbol(fnName)

    @eval function ($nameSymb)(ins::$instrumentType, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
        write(ins, string(cmd))
    end
    @eval export $nameSymb

    nothing
end

function createStateFunction{S<:Instrument}(instrumentType::Type{S},
        fnName::ASCIIString, command::ASCIIString, setArgType::Type{InstrumentException})

    readNameSymb = symbol(fnName)
    @eval function ($readNameSymb)(ins::$instrumentType, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
        response = ask(ins, (cmd[end] == '?' ? cmd : cmd*"?"))
        ($setArgType)(ins,response)
    end
    @eval export $readNameSymb

    nothing
end

function createGettingFunction{S<:Instrument, T<:InstrumentProperty}(instrumentType::Type{S},
        fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

    readNameSymb = symbol(fnName)
    @eval function ($readNameSymb)(ins::$instrumentType, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
        response = ask(ins, (cmd[end] == '?' ? cmd : cmd*"?"))
        ($setArgType)(ins,response)
    end
    @eval export $readNameSymb

    nothing
end

function createGettingFunction{S<:Instrument, T<:Union{Number,AbstractString}}(
        instrumentType::Type{S}, fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

    readNameSymb = symbol(fnName)
    @eval function ($readNameSymb)(ins::$instrumentType, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
        response = ask(ins, (cmd[end] == '?' ? cmd : cmd*"?"))
        ($setArgType)($setArgType <: Number ? parse(response) : response)
    end
    @eval export $readNameSymb

    nothing
end

function createSettingFunction{S<:Instrument, T<:InstrumentProperty}(instrumentType::Type{S},
        fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

    setNameSymb = setnamesymbol(fnName)

    # Take type as argument
    @eval function ($setNameSymb){T<:$setArgType}(ins::$instrumentType, x::Type{T}, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end

        write(ins, string(cmd," ",state((x)(ins))))
    end

    @eval export $setNameSymb

    nothing
end

function createSettingFunction{S<:Instrument, T<:Union{Number,AbstractString}}(
        instrumentType::Type{S}, fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

    setNameSymb = setnamesymbol(fnName)

    @eval function ($setNameSymb)(ins::$instrumentType, x::$setArgType, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end
        write(ins, string(cmd," ",($setArgType === Bool ? Int(x) : x)))
    end

    @eval export $setNameSymb

    nothing
end


function setnamesymbol(fnName::ASCIIString)
    symbol(string("set_",fnName))
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
returns an `InternalClock(ins,"INT")` or `ExternalClock(ins,"EXT")` object as appropriate,
based on the logical meaning of the response.

We also want a function to generate logical states without having to know the way
they are encoded by the instrument.

`InternalClock(ins::AWG5014C)`
returns an `InternalClock(ins,"INT")` object, with "INT" encoding how to pass this logical state
to the instrument `ins`.
"""
function generateResponseHandlers{T<:Instrument}(insType::Type{T}, responseDict::Dict)

    for (supertypeSymb in keys(responseDict))

        # Generate response handlers for concrete InstrumentPropertys to
        # make the correct concrete type.
        #
        # e.g. InternalClock(ins::AWG5014C) = InternalClock(ins,"INT")
        d = responseDict[supertypeSymb]
        for response in keys(d)
            fnSymb = d[response]
            @eval ($fnSymb)(ins::$insType) = ($fnSymb)(ins,$response)
        end

        # Generate response handlers for abstract InstrumentPropertys
        # to make the correct concrete type.
        #
        # e.g. InstrumentReference(AWG5014C, "INT") =
        #          InstrumentInternal{AWG5014C,symbol("INT")}
        @eval ($supertypeSymb)(ins::$insType, res::AbstractString) =
            (typeof(parse(res)) <: Number ?
            Expr(:call, ($d)[parse(res)],  ins, res) :
            Expr(:call, ($d)[res],         ins, res)) |> eval

        @eval ($supertypeSymb)(ins::$insType, res::Number) =
            Expr(:call, ($d)[res], ins, res) |> eval
    end

    nothing
end
