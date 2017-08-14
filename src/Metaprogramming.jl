import JSON

export insjson
export @generate_all, @generate_instruments
export generate_properties, generate_handlers, generate_configure, generate_inspect
export argsym, argtype, insjson, stripin

"""
    insjson(file::AbstractString)
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
The `instrument` dictionary is described in the [`@generate_instruments`](@ref)
documentation. The `properties` array contains one or more dictionaries, each
with keys:

- `cmd`: Specifies what must be sent to the instrument (it should be terminated
with "?" for query-only commands). The lower-case characters are replaced by
"infixes", which are either numerical arguments or strings
- `type`: Specifies the `InstrumentProperty` subtype to use this command.
- `values`: Specifies the required argument for `setindex!`, which will appear
after `cmd` in the string sent to the instrument.
- `infixes`: Specifies the infix arguments to be put in `cmd`. This key is not
required if there are no infixes.
- `doc`: Specifies documentation for the generated Julia functions. This key
is not required if there is no documentation. This is used not only for
interactive help but also in generating the documentation you are reading.

The value of the `properties.type` field and entries in the `properties.values`
and `properties.infixes` arrays are parsed into expressions or symbols
for further manipulation.
"""
function insjson(file::AbstractString)
    j = JSON.parsefile(file)
    # In all dictionaries below, keys are converted to symbols for metaprogramming purposes
    j = convert(Dict{Symbol,Any}, j)
    !haskey(j, :instrument) && error("Missing instrument information.")
    !haskey(j, :properties) && error("Missing property information.")

    j[:instrument] = convert(Dict{Symbol, Any}, j[:instrument])
    # Define a supertype if one is not specified
    !haskey(j[:instrument], :super) && (j[:instrument][:super] = :Instrument)
    for x in [:module, :type, :super]
        j[:instrument][x] = Symbol(j[:instrument][x]) #convert these values to Symbols
    end

    for i in eachindex(j[:properties])
        j[:properties][i] = convert(Dict{Symbol,Any}, j[:properties][i])
        p = j[:properties][i]
        p[:type] = parse(p[:type]) #parses into an expression; for one word, parsed into a Symbol
        if !isa(p[:values], AbstractArray) #make p[:values] an array if it isn't one
            p[:values] = (p[:values] != "" ? [p[:values]] : [])
        end
        #convert all elements of p[:values] into expressions for metaprogramming
        p[:values] = convert(Array{Expr,1}, map(parse, p[:values]))

        !haskey(p, :infixes) && (p[:infixes] = [])
        !haskey(p, :doc) && (p[:doc] = "")
        #convert all elements of p[:infixes] into expressions for metaprogramming
        p[:infixes] = convert(Array{Expr,1}, map(parse, p[:infixes]))
        for k in p[:infixes]
            # `parse` doesn't recognize we want the equal sign to indicate
            # an optional keyword argument. An equal sign sign in a keyword argument
            # is denoted by the :kw symbol.
            k.head = :kw
        end
    end

    j
end

"""
    @generate_all(metadata)
This macro takes a dictionary of instrument metadata, typically obtained
from a call to [`insjson`](@ref). It will go through the following steps:

1. [`generate_instruments`](@ref) Import required modules and symbols. Define
and export the `Instrument` subtype and the `make` and `model` methods if they
do not exist already (note generic functions `make` and `model` are defined in
`src/Definitions.jl`).
2. [`generate_handlers`](@ref): Generate "handler" methods to convert between
symbols and SCPI string args.
3. [`generate_inspect`](@ref): Generate `getindex` methods for instrument properties.
4. [`generate_configure`](@ref): Generate `setindex!` methods for instrument properties.

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
    @generate_instruments(metadata)
This macro takes a dictionary of metadata, typically obtained from
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

The macro imports required modules and methods, defines and exports the `Instrument`
subtype, and defines and exports and the `make` and `model` methods if they
do not exist already (note generic functions `make` and `model` are defined in
`src/Definitions.jl`).

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
                mutable struct $typsym <: $sup
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

"""
    @generate_properties(metadata)
This macro takes a dictionary of metadata, typically obtained from
a call to [`insjson`](@ref). It operates on the `:properties` field of
the dictionary, which is expected to be a list of dictionaries with information
on each "property" of the instrument. This macro specifically operates on the
`:type` field of each property dictionary; this field contains the name of the
type we would like to assign to a given property of the instrument

For every property dictionary, the macro first checks if a type with name corresponding
to the dictionary's `:type` field  has already been defined. If not, it then
defines an abstract type with that name, and makes it a subtype of the
`InstrumentProperty` type defined in the ICCommon package. The macro then finally
exports that type
"""
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
    @generate_handlers(instype, p)
This macro takes a symbol `instype` bound to an `Instrument` subtype (i.e. if
the symbol was evaluated, it would return an `Instrument` subtype ), and a property
dictionary `p` located in the `:properties` field of the dictionary of metadata
generated by a call to [`insjson`](@ref). with the auxiliary JSON file described
above.

This macro is written to handle the cases where an instrument command does not
accept numerical arguments, but rather a small set of options. Here is an example
of the property dictionary (prior to parsing) for such a command, which sets/gets
the format for a given channel and trace on the E5071C vector network analyzer:

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
are just ASCII strings to be sent to the instrument. We want to associate these
symbols with the specific ASCII strings because these strings are not very
descriptive, so we would like a more descriptive handle for them, as well as a
handle that could be potentially shared between different instruments with have
different "spellings" for the same command. We make the handles symbols because
they are a more flexible type (which can always be parsed into strings)

`generate_handlers` makes a bidirectional mapping between the symbols and the
strings. For the example above, the macro defines the following functions:

```jl
function symbols(ins::InsE5071C, ::Type{VNAFormat}, v::Symbol)
    if v == :LogMagnitude
      "MLOG"
    else
      if v == :Phase
        "PHAS"
      else...

        else
          error("unexpected input.")
    end
end

function VNAFormat(ins::InsE5071C, s::AbstractString)
    if s == "MLOG"
      :LogMagnitude
    else
      if s == "PHAS"
        :Phase
      else...


        else
          error("unexpected input.")
    end
end
```

The above functions will be defined in the module where the macro is run. Note
that the function `symbols` has its name chosen based on the dictionary name in
the JSON file. Since this function is not exported from the instrument's module
there should be few namespace worries and we maintain future flexibliity.
"""
macro generate_handlers(instype, p)
    quote
        # Look for symbol dictionaries
        for v in $(esc(p))[:values]
          #below: if the expression v has this following structure: v::Symbol in symbols
            if v.head == :(call) && v.args[1] == :(in)
                # in the above example, v.args[3] this corresponds to :symbols
                # so sym is the name of the dictionary referenced in the :values expression
                sym = v.args[3]
                !haskey($(esc(p)), sym) && error("Property $p lacking some information.")
                dict = $(esc(p))[sym] # the dictionary referenced in the :values expression

                # Define a function signature fnsig, e.g.:
                # symbols(ins::InsE5071C, ::Type{VNAFormat}, v::Symbol)
                fnsig = Expr(:call, :symbols,
                    Expr(:(::), :ins, $(esc(instype))),
                    Expr(:(::), Expr(:curly, :Type, $(esc(p))[:type])),
                    Expr(:(::), :v, :Symbol))
                #fnsig= symbols(ins::instype, ::Type{p[:type]}, v::Symbol)
                fndecl = Expr(:function, fnsig)

                # Build up the elseif statements, which make up the body of the
                # function, programmatically through the use of the Expression constructor
                expr = Expr(:if) #initialization of expression
                next2last = expr #will be used for some final editing after loop
                last = expr #used below to recursively nest if statements

                #The loop below works as follows: you add to the args of Expr(:if)
                # a equals to statement, the value in the key-value pair being looped
                #over, and another Expr(:if). Then, in the next iteration of the loop,
                #you add to the args of the LAST Expr(:if) that was pushed in the
                #previous iteration of the loop. In this way, you nest if-else statements
                for (a,b) in dict
                    x = parse(a) #used to convert string to symbol
                    push!(last.args, Expr(:call, :(==), :v, QuoteNode(x))) #v==:x
                    push!(last.args, b)
                    push!(last.args, Expr(:if))
                    next2last = last
                    last = last.args[end]
                end
                pop!(next2last.args) #gets rid of the last :if added
                push!(next2last.args, :(error("Unexpected input."))) #becomes the else clause, no need to explicitly add else to expression
                push!(fndecl.args, expr) #add entire body of nested if-else loops to function

                # Define the function in the module currently running the macro
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
    @generate_inspect(instype, p)
This macro takes a symbol `instype` bound to an `Instrument` subtype (i.e. if
the symbol was evaluated, it would return an `Instrument` subtype ), and a property
dictionary `p` located in the `:properties` field of the dictionary of metadata
generated by a call to [`insjson`](@ref). with the auxiliary JSON file described
above.

This macro overloads the base method `getindex`. In this implementation of
`getindex`, the instrument acts as the collection, and the key is the
InstrumentProperty type defined from the `:type` field of the `p` dictionary. This
method also takes infix arguments; infixes are currently implemented as keyword
arguments, so the `getindex` method applies some standard infixes if none are
specified by the user.

The method constructs a query command to send to the instrument regarding the
specific instrument property the dictionary `p` corresponds to. It then sends the
command to the instrument with the `ask` method (NOTE: currently only defined in the
VISA module for VISA instruments). The `ask` method returns the value or state
of the instrument property being queried.

The macro accomplishes this by constructing and evaluating
(approximately) the following expression:
```
function getindex(ins::instype, ::Type{p[:type]}, infixes_keyword_args)
  command=p[:cmd]
  command[end] != '?' && (command *= "?")
  cmd = replace(cmd, "infix_name", infix_keyword_arg1)
  cmd = replace(cmd, "infix_name", infix_keyword_arg2)
  ... #etc
  ask(ins,cmd)
  ...further manipulation of output for display
end
```
The function should be defined in the module where the instrument type was defined.
"""
macro generate_inspect(instype, p)
    quote
        # If it looks like configure needs two or more parameters to follow the
        # command, the return type for inspect is not obvious
        length(($(esc(p)))[:values]) > 1 && error("Not yet implemented.")
        !haskey($(esc(p)), :infixes) && ($(esc(p))[:infixes] = [])

        # Collect the arguments for `inspect`
        fargs = [Expr(:(::), :ins, $(esc(instype))),
            Expr(:(::), Expr(:curly, :Type, $(esc(p))[:type]))] #fargs=[ ins::instype , ::Type{p[:type]} ]
        for a in $(esc(p))[:infixes]
            push!(fargs, a)
        end

        # Begin constructing our definition of `inspect`
        method  = Expr(:call, :getindex, fargs...)
        inspect = Expr(:function, method, Expr(:block)) #:block signifies the start of a block expression
        fbody = inspect.args[2].args #inspect.args[2] is the Expr(:block) above

        # Add the question mark for a query
        command = $(esc(p))[:cmd]
        command[end] != '?' && (command *= "?")
        # In the function body: Define `cmd`
        push!(fbody, Expr(:(=), :cmd, command))

        # In cmd, replace the infixes strings with the infix_keyword_arguments
        for infix in ($(esc(p)))[:infixes]
            sym = argsym(infix) #argsym is helper function defined below
            name = string(sym)
            #below we push to fbody   cmd = replace(cmd, "name", sym)
            #sym is a symbol bound to some infix keyword argument (defined in function signature)
            push!(fbody, Expr(:(=), :cmd, Expr(:call, :replace, :cmd, name, sym)))
        end

        #if statement is excluding expressions such as   v::Symbol in symbols
        #such an expression is handled in the else clause of the statement
        if !($(esc(p))[:values][1].head == :(call) &&
                $(esc(p))[:values][1].args[1] == :(in))
            vtyp = argtype($(esc(p))[:values][1])
            if vtyp <: Number
                P,C = current_module().returntype(vtyp)
                # following looks like C(parse(ask(ins,cmd)))::P
                push!(fbody, Expr(:call, C, Expr(:(::), Expr(:call, :parse,
                    Expr(:call, :ask, :ins, :cmd)), P)))
            else
                #following looks like ask(ins,cmd)
                push!(fbody, :(ask(ins, cmd)))
            end
        else
            #following looks like p[:type](ins, ask(ins, cmd))
            #this is a call to the second function defined by @generate_handlers
            push!(fbody, Expr(:call, $(esc(p))[:type], :ins,
                Expr(:call, :ask, :ins, :cmd)))
        end

        # Define the method in the current module.
        eval(current_module(), inspect)
    end
end

"""
    @generate_configure(instype, p)
This macro takes a symbol `instype` bound to an `Instrument` subtype (i.e. if
the symbol was evaluated, it would return an `Instrument` subtype ), and a property
dictionary `p` located in the `:properties` field of the dictionary of metadata
generated by a call to [`insjson`](@ref). with the auxiliary JSON file described
above.

This macro overloads the base method `setindex!`. In this implementation of
`setindex!`, the instrument acts as the collection, the key is the InstrumentProperty
type defined from the `:type` field of the `p` dictionary, and the value is specified
by the user. This method also takes infix arguments; infixes are currently implemented as
keyword arguments, so the `setindex!` method applies some standard infixes if none
are specified by the user.

The method constructs a configuration command to send to the instrument to change the
specific instrument property the dictionary `p` corresponds to (with user specified
infixes). The command has "#" in place of the (user specified) value the property
will be set to. It then sends the command to the instrument with the `write`
method (NOTE: currently only defined in the VISA module for VISA instruments) where
the command and the user-specified property value are passed to it. The `write`
method replaces "#" with the proper value, and sends the command to the instrument

The macro accomplishes this by constructing and evaluating
(approximately) the following expression:
```
function setindex!(ins::instype, v::values_Type, ::Type{p[:type]}, infixes_keyword_args)
  command=p[:cmd]
  command*" #"
  cmd = replace(cmd, "infix_name", infix_keyword_arg1)
  cmd = replace(cmd, "infix_name", infix_keyword_arg2)
  ... #etc
  ...manipulation of input v into format instrument accepts
  write(ins,cmd,v)
end
```
The function should be defined in the module where the instrument type was defined.
"""
macro generate_configure(instype, p)
    quote
        !haskey($(esc(p)), :infixes) && ($(esc(p))[:infixes] = [])
        length($(esc(p))[:values]) > 1 && error("Not yet implemented.")

        # makes function signature
        #setindex!(ins::instype, v::values_Type, ::Type{p[:type]}, infixes_args)
        method = Expr(:call, :setindex!, Expr(:(::), :ins, $(esc(instype))),
            map(stripin, $(esc(p))[:values])..., #stripin is helper function defined below
            Expr(:(::), Expr(:curly, :Type, $(esc(p))[:type])),
            $(esc(p))[:infixes]...)
        configure = Expr(:function, method, Expr(:block))
        fbody = configure.args[2].args

        # In the function body: Define `cmd`
        command = $(esc(p))[:cmd]
        push!(fbody, Expr(:(=), :cmd, command*" #"))

        # In cmd, replace the infixes strings with the infix_keyword_arguments
        for infix in $(esc(p))[:infixes]
            sym = argsym(infix)
            name = string(sym)
            #below we push to fbody   cmd = replace(cmd, "name", sym)
            #sym is a symbol bound to some infix keyword argument (defined in function signature)
            push!(fbody, Expr(:(=), :cmd, Expr(:call, :replace, :cmd, name, sym)))
        end

        vsym = argsym($(esc(p))[:values][1])
        #if statement handles expressions such as   v::Symbol in symbols
        if $(esc(p))[:values][1].head == :(call) &&
                $(esc(p))[:values][1].args[1] == :(in)
            # dictname is name of referenced dictionary
            #in the above example, dictname is bound to the symbol :symbols
            dictname = $(esc(p))[:values][1].args[3]
            #below we push to fbody    write(ins, cmd, symbols(ins, p[:type], vsym))
            #symbols is a the first function defined in @generate_handlers
            push!(fbody, Expr(:call, :write, :ins, :cmd,
                Expr(:call, dictname, :ins, $(esc(p))[:type], vsym)))
        #handles other kinds of expressions in p[:values]
        else
            #below we push to fbody    write(ins, cmd, fmt(v))
            push!(fbody, Expr(:call, :write, :ins, :cmd,
                Expr(:call, :fmt, vsym)))
        end

        # Define the method in the current module.
        eval(current_module(), configure)
    end
end

#### Helper functions ####

"""
    argtype(expr)
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
    elseif expr.head == :(=) || expr.head == :(kw)
        return argtype(expr.args[1])
    elseif expr.head == :call && expr.args[1] == :in
        return argtype(expr.args[2])
    else
        error("Cannot handle this argument.")
    end
end

"""
    argsym(expr)
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
    elseif expr.head == :(=) || expr.head == :(kw)
        return argsym(expr.args[1])
    elseif expr.head == :call && expr.args[1] == :in
        return argsym(expr.args[2])
    else
        error("Cannot handle this argument.")
    end
end

"""
    stripin(expr)
Return the same expression in most cases, except:

- `:(x::Symbol in symbols)` → `:(x::Symbol)`
- `:(x in symbols)` → `:x`
"""
function stripin(expr)
    isa(expr, Symbol) && return expr
    if expr.head == :call && expr.args[1] == :(in)
        return expr.args[2]
    else
        return expr
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
