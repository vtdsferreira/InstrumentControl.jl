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
"""
Takes an Instrument type, a VISA command, an InstrumentProperty type, and
possibly an argument.

Supported:
    inspect(Instrument, Property, infixes...)
"""
function generate_inspect{S<:Instrument,T<:InstrumentProperty}(instype::Type{S},
        command::ASCIIString, proptype::Type{T}, ::Type{NoArgs})
    nothing     # don't generate inspect methods for NoArgs
end

function generate_inspect{S<:Instrument,T<:InstrumentProperty}(instype::Type{S},
        command::ASCIIString, proptype::Type{T}, returntype...)

    if (length(returntype) > 1)
        warning("More arguments than supported in generate_inspect.")
    end

    nhash = 0
    for i in command
        i == '#' ? nhash += 1 : nothing     # Count the number of '#' in command
    end

    @eval function inspect(ins::$instype, ::Type{$proptype}, infixes::Int...)
        cmd = $command
        # Bail if we need more infixes
        $nhash != length(infixes) && error(cmd," requires ",$nhash," infixes.")

        for infix in infixes
            cmd = replace(cmd,"#",infix,1)  # Replace all '#' chars
        end

        if cmd[end] != '?'
            cmd = cmd*"?"       # Add question mark if needed
        end

        response = ask(ins, cmd)    # Ask the instrument

        # Parse string into number if appropriate.
        # Note this is insecure if we don't trust our instrument
        # since parse can make arbitrary expressions...
        res = isa(parse(response), Number) ? parse(response) : response

        # If we should return a number/string/Bool do so,
        # otherwise ($proptype)(ins,res) will use a handler from generate_handlers
        # to return an object, a subtype of $proptype.
        length($returntype) > 0 ? ($returntype[1])(res) : ($proptype)(ins,res)
    end

    nothing
end

"""
Takes an Instrument type, a VISA command, an InstrumentProperty type, and possibly
arguments (which the command will take.)

Supported:
    configure(Instrument, PropertySubtype)
    configure(Instrument, Property, values..., infixes...)
"""
function generate_configure{S<:Instrument,T<:InstrumentProperty}(instype::Type{S},
        command::ASCIIString, proptype::Type{T})

    nhash = 0
    for i in command
        i == '#' ? nhash += 1 : nothing
    end

    @eval function configure{T<:$proptype}(ins::$instype, x::Type{T}, args...)
        cmd = $command

        x == $proptype && error("Pass a subtype of ",string($proptype)," instead.")

        $nhash != length(args) && error(cmd," requires ",$nhash," infixes.")
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

    nothing
end

function generate_configure{S<:Instrument,T<:InstrumentProperty}(instype::Type{S},
        command::ASCIIString, proptype::Type{T}, ::Type{NoArgs})

    nhash = 0
    for i in command
        i == '#' ? nhash += 1 : nothing
    end

    @eval function configure{T<:$proptype}(ins::$instype, x::Type{T}, args...)
        cmd = $command

        for infix in args
            cmd = replace(cmd,"#",infix,1)
        end

        write(ins, cmd)
    end

    nothing
end

function generate_configure{S<:Instrument,T<:InstrumentProperty}(instype::Type{S},
        command::ASCIIString, proptype::Type{T}, returntype...)

    if (length(returntype) > 1)
        warning("More arguments than supported in generate_configure.")
    end

    nhash = 0
    for i in command
        i == '#' ? nhash += 1 : nothing
    end

    @eval function configure{T<:$proptype}(ins::$instype, x::Type{T}, args...)
        cmd = $command

        $nhash + 1 != length(args) && error(cmd," requires a ",$returntype[1],
            " argument and ",$nhash," infixes.")

        !isa(args[1],$returntype[1]) &&
            error(cmd," requires a ",$returntype[1]," argument.")

        for infix in args
            cmd = replace(cmd,"#",infix,1)
        end

        write(ins, string(cmd," ",isa(args[1],Bool) ? Int(args[1]) : args[1]))
    end

    nothing
end

"Makes parametric subtypes and gives constructors. Also defines a code method."
function generate_properties{S<:InstrumentProperty}(
    subtype::Symbol, supertype::Type{S})

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
### generate_handlers

`generate_handlers(insType::DataType, responseDict::Dict)`

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

`InternalClock(ins::AWG5014C)` returns an `InternalClock(ins,"INT")` object,
with "INT" encoding how to pass this logical state to the instrument `ins`.
"""
function generate_handlers{T<:Instrument}(insType::Type{T}, responseDict::Dict)

    for (supertypeSymb in keys(responseDict))

        # e.g. InternalClock(ins::AWG5014C) = InternalClock(ins,"INT")
        d = responseDict[supertypeSymb]
        for response in keys(d)
            fnSymb = d[response]
            @eval ($fnSymb)(ins::$insType) = ($fnSymb)(ins,$response)
        end

        # e.g. InstrumentReference(ins::AWG5014C, "INT") =
        #          InstrumentInternal(AWG5014C,"INT")
        @eval ($supertypeSymb)(ins::$insType, res::AbstractString) =
            (typeof(parse(res)) <: Number ?
            Expr(:call, ($d)[parse(res)],  ins, res) :
            Expr(:call, ($d)[res],         ins, res)) |> eval

        @eval ($supertypeSymb)(ins::$insType, res::Number) =
            Expr(:call, ($d)[res], ins, res) |> eval
    end

    nothing
end
