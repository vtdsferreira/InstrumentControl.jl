"""
This method will
generate the following method in the module where `generate_inspect` is defined:

`inspect(ins::instype, ::Type{proptype}, infixes::Int...)`

The `infixes` variable argument allows for numbers to be inserted within the
commands, for instance in `OUTP#:FILT:FREQ`, where the `#` sign should be
replaced by an integer. The replacements are done in the order of the arguments.
Error checking is done on the number of arguments.

For a given property, `inspect` will return either an InstrumentProperty subtype,
a number, a boolean, or a string as appropriate.
"""
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
        # $nhash != length(infixes) && error(cmd," requires ",$nhash," infixes.")

        for infix in infixes
            cmd = replace(cmd,"#",infix,1)  # Replace all '#' chars
        end
        cmd = replace(cmd, "#", "1")   # Replace remaining infixes with ones.

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
This method generates the following method in the module where
`generate_configure` is defined:

```
configure(ins::InsType, ::Type{PropertySubtype}, infixes...)
```
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

        # $nhash != length(args) && error(cmd," requires ",$nhash," infixes.")
        for infix in args
            cmd = replace(cmd,"#",infix,1)
        end
        cmd = replace(cmd, "#", "1")

        try
            cd = code(ins,x)
        catch
            error("This subtype not be supported for this instrument.")
        end

        write(ins, string(cmd," ",code(ins,x)))
    end

    nothing
end

"""
This method generates the following method in the module where
`generate_configure` is defined:

```
configure(ins::InsType, ::Type{PropertySubtype}, infixes...)
```

This particular method will be deprecated soon.
"""
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
        cmd = replace(cmd, "#", "1")

        write(ins, cmd)
    end

    nothing
end

"""
This method generates the following method in the module where
`generate_configure` is defined:

```
configure(ins::InsType, Property, values..., infixes...)
```
"""
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

        # $nhash + 1 != length(args) && error(cmd," requires a ",$returntype[1],
        #     " argument and ",$nhash," infixes.")
        length(args) < 1 && error("Not enough arguments.")

        !isa(args[1],$returntype[1]) &&
            error(cmd," requires a ",$returntype[1]," argument.")

        for infix in args[2:end]
            cmd = replace(cmd,"#",infix,1)
        end
        cmd = replace(cmd, "#", "1")

        write(ins, string(cmd," ",isa(args[1],Bool) ? Int(args[1]) : args[1]))
    end

    nothing
end
