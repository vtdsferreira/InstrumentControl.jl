import JSON

export insjson
export @generate_all, @generate_instruments
export generate_properties, generate_handlers, generate_configure, generate_inspect
export argsym, argtype, insjson, stripin

"""
```
insjson(file::AbstractString)
```

Parses a JSON file with a standardized schema to describe how to control
an instrument.

Here is an example of a valid JSON file with valid schema for parsing:

```json
{
    "instrument":{
            "module":"E5071C",
            "type":"InsE5071C",
            "make":"Keysight",
            "model":"E5071C",
            "writeterminator":"\\n"
    },
    "properties":[
        {
            "cmd":":CALCch:TRACtr:CORR:EDEL:TIME",
            "type":"VNA.ElectricalDelay",
            "values":[
                "v::Real"
            ],
            "infixes":[
                "ch::Integer=1",
                "tr::Integer=1"
            ],
            "doc": "My documentation"
        }
    ]
}
```

After loading with `JSON.parse`, all dictionary keys are converted to symbols.
The `instrument` dictionary is described in the [`generate_instruments`](@ref)
documentation. The `properties` array contains one or more dictionaries, each
with keys:

- `cmd`: Specifies what must be sent to the instrument (it should be
terminated with "?" for query-only). The lower-case characters are replaced
by infix arguments.
- `type`: Specifies the `InstrumentProperty` subtype to use this command. Will be
parsed and evaluated.
- `values`: Specifies the required arguments for `setindex!` which will
appear after `cmd` in the string sent to the instrument.
- `infixes`: Specifies the infix arguments in `cmd`. Symbol names must match
infix arguments. This key is not required if there are no infixes.
- `doc`: Specifies documentation for the generated Julia functions. This key
is not required if there is no documentation. This is used not only for
interactive help but also in generating the documentation you are reading.

The value of the `properties.type` field and entries in the `properties.values`
and `properties.infixes` arrays are parsed by Julia into expressions or symbols
for further manipulation.
"""
function insjson(file::AbstractString)
    j = JSON.parsefile(file)

    # Prefer symbols as keys instead of strings
    j = convert(Dict{Symbol,Any}, j)

    !haskey(j, :instrument) && error("Missing instrument information.")
    !haskey(j, :properties) && error("Missing property information.")

    # Tidy up (and validate?) the instrument dictionary
    j[:instrument] = convert(Dict{Symbol, Any}, j[:instrument])

    # Define a supertype if one is not specified
    !haskey(j[:instrument], :super) && (j[:instrument][:super] = :Instrument)

    for x in [:module, :type, :super]
        j[:instrument][x] = Symbol(j[:instrument][x])
    end

    # Tidy up (and validate?) the properties dictionary
    for i in eachindex(j[:properties])
        # Prefer symbols instead of strings
        j[:properties][i] = convert(Dict{Symbol,Any}, j[:properties][i])
        p = j[:properties][i]
        p[:type] = parse(p[:type])
        if !isa(p[:values], AbstractArray)
            # Handle the case where p[:values] is just a string
            p[:values] = (p[:values] != "" ? [p[:values]] : [])
        end
        p[:values] = convert(Array{Expr,1}, map(parse, p[:values]))

        !haskey(p, :infixes) && (p[:infixes] = [])
        !haskey(p, :doc) && (p[:doc] = "")
        p[:infixes] = convert(Array{Expr,1}, map(parse, p[:infixes]))
        for k in p[:infixes]
            # `parse` doesn't recognize we want the equal sign to indicate
            # an optional argument, denoted by the :kw symbol.
            k.head = :kw
        end
    end

    j
end

"""
```
generate_all(metadata)
```

This macro takes a dictionary of instrument metadata, typically obtained
from a call to [`insjson`](@ref). It will go through the following steps:

1. [`generate_instruments`](@ref) Import required modules and symbols. Define
and export the `Instrument` subtype and the `make` and `model` methods if they
do not exist already (note generic functions `make` and `model` are defined in
`src/Definitions.jl`).
3. [`generate_properties`](@ref): Generate instrument properties if they do
not exist already, and do any necessary importing and exporting.
4. [`generate_handlers`](@ref): Generate "handler" methods to convert between
symbols and SCPI string args.
5. [`generate_inspect`](@ref): Generate `getindex` methods for instrument properties.
6. [`generate_configure`](@ref): Generate `setindex!` methods for instrument properties.

`generate_all` should be called near the start of an instrument's .jl file,
if one exists. It is not required to have a source file for each instrument if
the automatically generated code is sufficient.
"""
macro generate_all(metadata)
    quote
        @generate_instruments($(esc(metadata)))
        ins = $(esc(metadata))[:instrument][:type]

        for p in $(esc(metadata))[:properties]
            @generate_handlers(ins, p)
            @generate_inspect(ins, p)
            if p[:cmd][end] != '?'
                @generate_configure(ins, p)
            end
        end
    end
end

"""
```
generate_instruments(metadata)
```

This function takes a dictionary of metadata, typically obtained from
a call to [`insjson`](@ref). It operates on the `:instrument` field of the dictionary
which is expected to have the following structure:

- `module`: The module name. Can already exist but is created if it does not.
This field is converted from a string to a `Symbol` by [`insjson`](@ref).
- `type`: The name of the type to create for the new instrument.
This field is converted from a string to a `Symbol` by [`insjson`](@ref).
- `super`: This field is optional. If provided it will be the supertype of
the new instrument type, otherwise the supertype will be `Instrument`.
This field is converted from a string to a `Symbol` by [`insjson`](@ref).
- `make`: The make of the instrument, e.g. Keysight, Tektronix, etc.
- `model`: The model of the instrument, e.g. E5071C, AWG5014C, etc.
- `writeterminator`: Write termination string for sending SCPI commands.

By convention we typically have the module name be the same as the model name,
and the type is just the model prefixed by "Ins", e.g. `InsE5071C`. This is not
required.
"""
macro generate_instruments(metadata)
    esc(quote
        # We must define the module and import necessary definitions
        import Base: getindex, setindex!
        import VISA
        importall InstrumentControl

        # boring assignment for convenience
        md = eval($(metadata)[:instrument][:module])
        typsym = $(metadata)[:instrument][:type]
        sup = $(metadata)[:instrument][:super]
        term = $(metadata)[:instrument][:writeterminator]
        mod = $(metadata)[:instrument][:model]
        mak = $(metadata)[:instrument][:make]

        # Here we define the Instrument subtype.
        if !isdefined(md, typsym)
            eval(quote
                export $typsym
                type $typsym <: $sup
                    vi::(VISA.ViSession)
                    writeTerminator::String
                    ($typsym)(x) = begin
                        ins = new()
                        ins.vi = x
                        ins.writeTerminator = $term
                        ins[WriteTermCharEnable] = true
                        ins
                    end

                    ($typsym)() = new()
                end
            end)
        end

        typ = eval(typsym)
        if !method_exists(make, (typ,))
            make(x::typ) = mak
        end

        if !method_exists(model, (typ,))
            model(x::typ) = mod
        end
    end)
end

macro generate_properties(metadata)
    quote
        for p in $(esc(metadata))[:properties]
            # First check if it is a `Symbol`. Why? Because it could be an `Expr`,
            # in which case it is referring to an InstrumentProperty already
            # defined elsewhere (e.g. `VNA.Format`)
            if isa(p[:type], Symbol) && !isdefined(p[:type])
                sym = p[:type]
                eval(Expr(:abstract, Expr(:(<:), sym, InstrumentProperty)))
                eval(Expr(:export, sym))
            end
        end
    end
end

"""
```
@generate_handlers(instype, p)
```

This macro takes a symbol `instype` bound to an `Instrument` subtype, and a
symbol `p` bound to a property dictionary. The property dictionary is built out
of an auxiliary JSON file described above.

In some cases, an instrument command does not except numerical arguments but
rather a small set of options. Here is an example of the property dictionary
(prior to parsing) for such a command, which sets/gets the format for a given
channel and trace on the E5071C vector network analyzer:

```json
{
    "cmd":":CALCch:TRACtr:FORM",
    "type":"VNAFormat",
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

`generate_handlers` makes a bidirectional mapping between the symbols and the
strings. In this example, the macro defines the following functions:

```jl
function symbols(ins::InsE5071C, ::Type{VNAFormat}, v::Symbol)
    if v == :LogMagnitude
        "MLOG"
    elseif v == :Phase
        "PHAS"
    elseif ...

    else
        error("unexpected input.")
    end
end

function VNAFormat(ins::InsE5071C, s::AbstractString)
    if s == "MLOG"
        :LogMagnitude
    elseif s == "PHAS"
        :Phase
    elseif ...

    else
        error("unexpected input.")
    end
end
```

The above functions will be defined in the E5071C module. Note that the function
`symbols` has its name chosen based on the dictionary name in the JSON file.
Since this function is not exported from the instrument's module there should be
few namespace worries and we maintain future flexibliity.
"""
macro generate_handlers(instype, p)
    quote
        # Look for symbol dictionaries
        for v in $(esc(p))[:values]
            if v.head == :(call) && v.args[1] == :(in)
                # Looks like we have a symbol dictionary
                sym = v.args[3]     # name of dictionary
                !haskey($(esc(p)), sym) && error("Property $p lacking some information.")
                dict = $(esc(p))[sym]      # the dictionary

                # Define a function signature fnsig, e.g.:
                # symbols(ins::InsE5071C, ::Type{VNAFormat}, v::Symbol)
                fnsig = Expr(:call, :symbols,
                    Expr(:(::), :ins, $(esc(instype))),
                    Expr(:(::), Expr(:curly, :Type, $(esc(p))[:type])),
                    Expr(:(::), :v, :Symbol))
                fndecl = Expr(:function, fnsig)

                # Build up the if-elses programmatically
                expr = Expr(:if)
                next2last = expr
                last = expr
                for (a,b) in dict
                    x = parse(a)
                    push!(last.args, Expr(:call, :(==), :v, QuoteNode(x)))
                    push!(last.args, b)
                    push!(last.args, Expr(:if))
                    next2last = last
                    last = last.args[end]
                end
                pop!(next2last.args)
                push!(next2last.args, :(error("Unexpected input.")))
                push!(fndecl.args, expr)

                # Define the function
                eval(current_module(), fndecl)

                # Define a function signature fnsig, e.g.:
                # VNAFormat(ins::InsE5071C, s::AbstractString)
                fnsig = Expr(:call, $(esc(p))[:type],
                    Expr(:(::), :ins, $(esc(instype))),
                    Expr(:(::), :s, :AbstractString))
                fndecl = Expr(:function, fnsig)

                # Build up the if-elses programmatically
                expr = Expr(:if)
                next2last = expr
                last = expr
                for (a,b) in dict
                    x = parse(a)
                    push!(last.args, Expr(:call, :(==), :s, b))
                    push!(last.args, QuoteNode(x))
                    push!(last.args, Expr(:if))
                    next2last = last
                    last = last.args[end]
                end
                pop!(next2last.args)
                push!(next2last.args, :(error("Unexpected input.")))
                push!(fndecl.args, expr)

                # Define the function
                eval(current_module(), fndecl)
            end
        end
    end
end

"""
```
generate_inspect(instype, p)
```

This macro takes a symbol `instype` bound to an `Instrument` subtype and a
symbol `p` bound to a property dictionary. The property dictionary is built out
of an auxiliary JSON file described above.

This function generates and documents a method for `getindex`. The method is
defined in the module where the instrument type was defined.
"""
macro generate_inspect(instype, p)
    quote
        # Get the instrument property type and assert.
        !haskey($(esc(p)), :infixes) && ($(esc(p))[:infixes] = [])

        # Collect the arguments for `inspect`
        fargs = [Expr(:(::), :ins, $(esc(instype))),
            Expr(:(::), Expr(:curly, :Type, $(esc(p))[:type]))]
        for a in $(esc(p))[:infixes]
            push!(fargs, a)
        end

        # If it looks like configure needs two or more parameters to follow the
        # command, the return type for inspect is not obvious
        length(($(esc(p)))[:values]) > 1 && error("Not yet implemented.")

        # Begin constructing our definition of `inspect`
        method  = Expr(:call, :getindex, fargs...)
        inspect = Expr(:function, method, Expr(:block))
        fbody = inspect.args[2].args

        # Add the question mark for a query
        command = $(esc(p))[:cmd]
        command[end] != '?' && (command *= "?")

        # In the function body: Define `cmd`
        push!(fbody, Expr(:(=), :cmd, command))

        # In the function body: Replace the infixes with the `getindex` arguments
        for infix in ($(esc(p)))[:infixes]
            sym = argsym(infix)
            name = string(sym)
            push!(fbody, Expr(:(=), :cmd, Expr(:call, :replace, :cmd, name, sym)))
        end

        if !($(esc(p))[:values][1].head == :(call) &&
                $(esc(p))[:values][1].args[1] == :(in))
            vtyp = argtype($(esc(p))[:values][1])
            if vtyp <: Number
                P,C = current_module().returntype(vtyp)
                # following looks like C(parse(ask(ins,cmd)))::P
                push!(fbody, Expr(:call, C, Expr(:(::), Expr(:call, :parse,
                    Expr(:call, :ask, :ins, :cmd)), P)))
            else
                push!(fbody, :(ask(ins, cmd)))
            end
        else
            push!(fbody, Expr(:call, $(esc(p))[:type], :ins,
                Expr(:call, :ask, :ins, :cmd)))
        end

        # Define the method in the current module.
        eval(current_module(), inspect)
    end
end

"""
```
generate_configure(instype, p)
```

This macro takes a symbol `instype` bound to an `Instrument` subtype `instype`,
and a symbol `p` bound to a property dictionary. The property dictionary is
built out of an auxiliary JSON file described above.

This function generates and documents a method for `getindex`. The method is
defined in the module where the instrument type was defined.
"""
macro generate_configure(instype, p)
    quote
        command = $(esc(p))[:cmd]
        !haskey($(esc(p)), :infixes) && ($(esc(p))[:infixes] = [])

        length($(esc(p))[:values]) > 1 && error("Not yet implemented.")

        method = Expr(:call, :setindex!, Expr(:(::), :ins, $(esc(instype))),
            map(stripin, $(esc(p))[:values])...,
            Expr(:(::), Expr(:curly, :Type, $(esc(p))[:type])),
            $(esc(p))[:infixes]...)

        configure = Expr(:function, method, Expr(:block))
        fbody = configure.args[2].args

        # In the function body: Define `cmd`
        push!(fbody, Expr(:(=), :cmd, command*" #"))
        for infix in $(esc(p))[:infixes]
            sym = argsym(infix)
            name = string(sym)
            push!(fbody, Expr(:(=), :cmd, Expr(:call, :replace, :cmd, name, sym)))
        end

        vsym = argsym($(esc(p))[:values][1])
        if $(esc(p))[:values][1].head == :(call) &&
                $(esc(p))[:values][1].args[1] == :(in)
            dictname = $(esc(p))[:values][1].args[3]
            push!(fbody, Expr(:call, :write, :ins, :cmd,
                Expr(:call, dictname, :ins, $(esc(p))[:type], vsym)))
        else
            push!(fbody, Expr(:call, :write, :ins, :cmd,
                Expr(:call, :fmt, vsym)))
        end

        # Define the method in the current module.
        eval(current_module(), configure)
    end
end

#### Helper functions ####

"""
```
argtype(expr)
```

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
    if VERSION < v"0.5.0-pre"
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
    else
        if isa(expr, Symbol)
            return Any
        elseif expr.head == :(::)
            if length(expr.args) == 1
                return eval(expr.args[1])
            else
                return eval(expr.args[2])
            end
        elseif expr.head == :(=) || expr.head == :(kw)
            return argtype(expr.args[1])
        elseif expr.head == :call && expr.args[1] == :in
            return argtype(expr.args[2])
        else
            error("Cannot handle this argument.")
        end
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
    if VERSION < v"0.5.0-pre"
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
    else
        if isa(expr, Symbol)
            return expr
        elseif expr.head == :(::)
            if length(expr.args) == 1
                return :_
            else
                return expr.args[1]
            end
        elseif expr.head == :(=) || expr.head == :(kw)
            return argsym(expr.args[1])
        elseif expr.head == :call && expr.args[1] == :in
            return argsym(expr.args[2])
        else
            error("Cannot handle this argument.")
        end
    end
end

"""
```
stripin(expr)
```

Return the same expression in most cases, except:

- `:(x::Symbol in symbols)` → `:(x::Symbol)`
- `:(x in symbols)` → `:x`
"""
function stripin(expr)
    isa(expr, Symbol) && return expr
    if VERSION < v"0.5.0-pre"
        if expr.head == :(in)
            return expr.args[1]
        else
            return expr
        end
    else
        if expr.head == :call && expr.args[1] == :(in)
            return expr.args[2]
        else
            return expr
        end
    end
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
#     base = joinpath(Pkg.dir("InstrumentControl"),"docs","src",name)
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
