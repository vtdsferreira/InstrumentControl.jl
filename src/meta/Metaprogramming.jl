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

import JSON

"""
`argtype(expr)`

Given function arguments, will return types:

- `:(x::Integer)` → `Integer`
- `:(x::Integer=3)` → `Integer`
- `:(x)` → `Any`
- `:(x=3)` → `Any`

Some package-specific cases:

- `:(x in symbols)` → `Any`
- `:(x::Symbol in symbols)` → `Symbol`
"""
function argtype(expr)
    if isa(expr, Symbol)
        return Any
    elseif expr.head == :(::)
        if length(expr.args) == 1
            return eval(expr.args[1])
        else
            return eval(expr.args[2])
        end
    elseif expr.head == :(=) || expr.head == :(kw) || expr.head == :(in)
        return argtype(expr.args[1])
    else
        error("Cannot handle this argument.")
    end
end

"""
`argsym(expr)`

Given function arguments, will return symbols:

- `:(x::Integer)` → `:x`
- `:(x::Integer=3)` → `:x`
- `:(x)` → `:x`
- `:(x=3)` → `:x`

Some package-specific syntax:

- `:(x in symbols)` → `:x`
- `:(x::Symbol in symbols)` → `:x`
"""
function argsym(expr)
    if isa(expr, Symbol)
        return expr
    elseif expr.head == :(::)
        if length(expr.args) == 1
            return :_
        else
            return expr.args[1]
        end
    elseif expr.head == :(=) || expr.head == :(kw) || expr.head == :(in)
        return argsym(expr.args[1])
    else
        error("Cannot handle this argument.")
    end
end

"""
`stripin(expr)`

Return the same expression in most cases, except:

- `:(x::Symbol in symbols)` → `:(x::Symbol)`
- `:(x in symbols)` → `:x`
"""
function stripin(expr)
    isa(expr, Symbol) && return expr
    if expr.head == :(in)
        return expr.args[1]
    else
        return expr
    end
end

function generate_all{S<:Instrument}(ins::Type{S}, metadata)
    for p in metadata[:properties]
        generate_handlers(ins, p)
        generate_inspect(ins, p)
        if p[:cmd][end] != '?'
            generate_configure(ins, p)
        end
    end
end

"""
`generate_handlers{S<:Instrument}(instype::Type{S}, p)`

This function takes an `Instrument` subtype `instype`, and a property dictionary
`p`. The property dictionary is built out of an auxiliary JSON file described above.

In some cases, an instrument command does not except numerical arguments but
rather a small set of options. Here is an example of the JSON template for such
a command, which sets/gets the format for a given channel and trace on the E5071C
vector network analyzer:

```json
{
    "cmd":":CALCch:TRACtr:FORM",
    "type":"VNA.Format",
    "values":[
        "v::Symbol in symbols"
    ],
    "symbols":{
        "LogMagnitude":"MLOG",
        "Phase":"PHAS",
        "GroupDelay":"GDEL",
        "SmithLinear":"SLIN",
        "SmithLog":"SLOG",
        "SmithComplex":"SCOM",
        "Smith":"SMIT",
        "SmithAdmittance":"SADM",
        "PolarLinear":"PLIN",
        "PolarLog":"PLOG",
        "PolarComplex":"POL",
        "LinearMagnitude":"MLIN",
        "SWR":"SWR",
        "RealPart":"REAL",
        "ImagPart":"IMAG",
        "ExpandedPhase":"UPH",
        "PositivePhase":"PPH"
    },
    "infixes":[
        "ch::Integer=1",
        "tr::Integer=1"
    ],
    "doc":"Hey"
}
```

We see here that the `values` key is saying that we are only going to accept
`Symbol` type for our `setindex!` method and the symbol has to come out of `symbols`,
a dictionary that is defined on the next line. The keys of this dictionary
are going to be interpreted as symbols (e.g. `:LogMagnitude`) and the values
are just ASCII strings to be sent to the instrument.

`generate_handlers` makes a bidirectional mapping between the symbols and the strings.
In this example, this is accomplished as follows:

```jl
symbols(ins::E5071C, ::Type{VNA.Format}, v::Symbol) = symbols(ins, VNA.Format, Val{v})
symbols(ins::E5071C, ::Type{VNA.Format}, ::Type{Val{:LogMagnitude}}) = "MLOG" # ... etc. for each symbol.

VNA.Format(ins::E5071C, s::AbstractString) = VNA.Format(ins, Val{symbol(s)})
VNA.Format(ins::E5071C, ::Type{Val{symbol("MLOG")}}) = :LogMagnitude # ... etc. for each symbol.
```

The above methods will be defined in the E5071C module. Note that the function `symbols`
has its name chosen based on the dictionary name in the JSON file. This was done
for future flexibliity.
"""
function generate_handlers{S<:Instrument}(instype::Type{S}, p)

    md = instype.name.module
    T = eval(md, p[:type])

    # Look for symbol dictionaries
    for v in p[:values]
        if v.head == :(in)
            # Looks like we have a dictionary of symbols
            sym = v.args[2]     # name of dictionary
            !haskey(p, sym) && error("Property $p lacking some information.")
            dict = p[sym]       # the dictionary

            # Define methods to dispatch based on Val types
            # e.g. symbols(ins::AWG5014C, ::Type{ClockSource}, v::Symbol) =
            #       symbols(ins, ClockSource, Val{v})
            # and  ClockSource(ins::AWG5014C, s::AbstractString) =
            #       ClockSource(ins, Val{symbol(s)})
            eval(md, :(($sym)(ins::$instype, ::Type{$T}, $(v.args[1])) =
                ($sym)(ins, $T, Val{$(argsym(v))})))
            eval(md, :(($(p[:type]))(ins::$instype, s::AbstractString) =
                ($(p[:type]))(ins, Val{symbol(s)})))

            # Now define the methods that use the Val types
            # e.g. symbols(ins::AWG5014C, ::Type{ClockSource}, Val{:Internal}) = "INT"
            # and  ClockSource(ins::AWG5014C, Val{:INT}) = :Internal
            for (a,b) in dict
                eval(md, :(($sym)(ins::$instype, ::Type{$T}, ::Type{Val{parse($a)}}) = $b))
                eval(md, :(($(p[:type]))(ins::$instype, ::Type{Val{symbol($b)}}) = parse($a)))
            end
        end
    end

    nothing
end

"""
`generate_inspect{S<:Instrument}(instype::Type{S}, p)`

This function takes an `Instrument` subtype `instype`, and a property dictionary
`p`. The property dictionary is built out of an auxiliary JSON file described above.

This function generates and documents a method for `getindex`. The method is
defined in the module where the instrument type was defined.
"""
function generate_inspect{S<:Instrument}(instype::Type{S}, p)

    # Get the instrument property type and assert.
    md = instype.name.module
    T = eval(md, p[:type])
    !haskey(p, :infixes) && (p[:infixes] = [])

    # Collect the arguments for `inspect`
    fargs = [:(ins::$S), :(::Type{$T})]
    for a in p[:infixes]
        push!(fargs, a)
    end

    # If it looks like configure needs two or more parameters to follow the
    # command, the return type for inspect is not obvious
    length(p[:values]) > 1 && error("Not yet implemented.")

    # Begin constructing our definition of `inspect`
    method  = Expr(:call, :getindex, fargs...)
    inspect = Expr(:function, method, Expr(:block))
    fbody = inspect.args[2].args

    # Add the question mark for a query
    command = p[:cmd]
    command[end] != '?' && (command *= "?")

    # In the function body: Define `cmd`
    push!(fbody, :(cmd = $command))

    # In the function body: Replace the infixes with the `getindex` arguments
    for infix in p[:infixes]
        sym = argsym(infix)
        name = string(sym)
        push!(fbody, :(cmd = replace(cmd, $name, $sym)))
    end

    if p[:values][1].head != :(in)
        vtyp = argtype(p[:values][1])
        if vtyp <: Number
            P,C = md.returntype(vtyp)
            push!(fbody, :(($C)(parse(ask(ins, cmd))::($P))) )
        else
            push!(fbody, :(ask(ins, cmd)) )
        end
    else
        push!(fbody, :(($T)(ins, ask(ins, cmd))))
    end

    # Define the method in the current module.
    eval(md, inspect)

    # Document the method.
    p[:doc] = string("```jl\n",method,"\n```\n\n") * "\n\n" * p[:doc]  # Prepend with method signature
    eval(md, :(@doc $(p[:doc]) $method))             # ...and document it.

    # Return a method signature without variable names, optional argument defaults, etc.
    method # = Expr(:call, :getindex, map(typesig, fargs)...)
end

"""
`generate_configure{S<:Instrument}(instype::Type{S}, p)`

This function takes an `Instrument` subtype `instype`, and a property dictionary
`p`. The property dictionary is built out of an auxiliary JSON file described above.

This function generates and documents a method for `getindex`. The method is
defined in the module where the instrument type was defined.
"""
function generate_configure{S<:Instrument}(instype::Type{S}, p)

    # Get the instrument property type and assert.
    md = instype.name.module
    T = eval(md, p[:type])

    command = p[:cmd]
    !haskey(p, :infixes) && (p[:infixes] = [])

    length(p[:values]) > 1 && error("Not yet implemented.")

    method = Expr(:call, :setindex!,
        :(ins::$S), map(stripin, p[:values])..., :(::Type{$T}), p[:infixes]...)

    configure = Expr(:function, method, Expr(:block))
    fbody = configure.args[2].args

    # In the function body: Define `cmd`
    push!(fbody, :(cmd = $(command*" #")))
    for infix in p[:infixes]
        sym = argsym(infix)
        name = string(sym)
        push!(fbody, :(cmd = replace(cmd, $name, $sym)))
    end

    if p[:values][1].head == :(in)
        dictname = p[:values][1].args[2]
        push!(fbody, :(write(ins, cmd, ($dictname)(ins, $T, $(argsym(p[:values][1]))))))
    else
        vsym = argsym(p[:values][1])
        push!(fbody, :(write(ins, cmd, fmt($vsym))))
    end

    # Define the method in the current module.
    eval(md, configure)

    # Document the method.
    p[:doc] = string("```jl\n",method,"\n```\n\n") * "\n\n" * p[:doc]  # Prepend with method signature
    eval(md, :(@doc $(p[:doc]) $method))             # ...and document it.

    method  # = Expr(:call, :setindex!, :(::$S),
    #    map(typesig, p[:values])..., :(::Type{$T}), map(typesig, p[:infixes])...)
end

# If you want to generate method signatures explicitly in the docs...
#
# typesig(expr) = Expr(:(::), symbol(argtype(expr)))
#
# function generate_all{S<:Instrument}(ins::Type{S})
#     g,s,b = generate_docs_template(ins)
#     open(g, "a") do io
#         for p in metadata[:properties]
#             generate_handlers(ins, p)
#             method = generate_inspect(ins, p)
#             write(io, "\t$method\n")
#         end
#     end
#     open(s, "a") do io
#         for p in metadata[:properties]
#             if p[:cmd][end] != '?'
#                 method = generate_configure(ins, p)
#                 write(io, "\t$method\n")
#             end
#         end
#     end
# end
#
# function generate_docs_template{S<:Instrument}(ins::Type{S})
#     name = lowercase(split(string(ins.name),".")[end])
#     base = joinpath(Pkg.dir("PainterQB"),"docs","src",name)
#     gpath = joinpath(base, "getindex.md")
#     spath = joinpath(base, "setindex.md")
#     bpath = joinpath(base, "body.md")
#     for p in (gpath, spath)
#         open(p, "w") do io
#             # write(io, "\t{index}\n\n")
#             write(io, "\t{docs}\n")
#         end
#     end
#     gpath, spath, bpath
# end
