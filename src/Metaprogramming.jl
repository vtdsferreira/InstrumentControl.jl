# We don't export these as the user shouldn't need them ever

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
    result = query_ins(ins, "TRIG:REF?")
    InstrumentTriggerSource(AWG5014C,result)
end

function setTriggerSource(ins::AWG5014C, x::Type{InstrumentTriggerSource})
    write_ins(ins, string("TRIG:REF ", x(AWG5014C) |> state) )
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
    write_ins(ins, "AWGC:RUN")
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
        write_ins(ins, string(cmd))
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
        response = query_ins(ins, (cmd[end] == '?' ? cmd : cmd*"?"))
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
        response = query_ins(ins, (cmd[end] == '?' ? cmd : cmd*"?"))
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
        response = query_ins(ins, (cmd[end] == '?' ? cmd : cmd*"?"))
        ($setArgType)($setArgType <: Number ? parse(response) : response)
    end
    @eval export $readNameSymb
end

function createSettingFunction{S<:Instrument, T<:InstrumentCode}(instrumentType::Type{S},
        fnName::ASCIIString, command::ASCIIString, setArgType::Type{T})

    setNameSymb = symbol(string("set",ucfirst(fnName)))

    # Take type as argument
    @eval function ($setNameSymb){T<:$setArgType}(ins::$instrumentType, x::Type{T}, infixes::Int64...)
        cmd = $command
        for (infix in infixes)
            cmd = replace(cmd,"#",infix,1)
        end

        write_ins(ins, string(cmd," ",state((x)($instrumentType))))
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
        write_ins(ins, string(cmd," ",($setArgType === Bool ? Int(x) : x)))
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
