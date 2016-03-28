"""
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
Return the same expression in most cases except:
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

function generate_handlers{S<:Instrument}(instype::Type{S}, p)

    T = eval(p[:type])

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
            @eval ($sym)(ins::$instype, ::Type{$T}, $(v.args[1])) =
                ($sym)(ins, $T, Val{$(argsym(v))})
            @eval ($(p[:type]))(ins::$instype, s::AbstractString) =
                ($(p[:type]))(ins, Val{symbol(s)})

            # Now define the methods that use the Val types
            # e.g. symbols(ins::AWG5014C, ::Type{ClockSource}, Val{:Internal}) = "INT"
            # and  ClockSource(ins::AWG5014C, Val{:INT}) = :Internal
            for (a,b) in dict
                @eval ($sym)(ins::$instype, ::Type{$T}, ::Type{Val{parse($a)}}) = $b
                @eval ($(p[:type]))(ins::$instype, ::Type{Val{symbol($b)}}) = parse($a)
            end
        end
    end

    nothing
end

function generate_inspect{S<:Instrument}(instype::Type{S}, p)
        #command::ASCIIString, proptype::Type{T}, args...)

    # Get the instrument property type and assert.
    T = eval(p[:type])
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
    method  = Expr(:call, :inspect, fargs...)
    inspect = Expr(:function, method, Expr(:block))
    fbody = inspect.args[2].args

    # Add the question mark for a query
    command = p[:cmd]
    command[end] != '?' && (command *= "?")

    # In the function body: Define `cmd`
    push!(fbody, :(cmd = $command))

    # In the function body: Replace the infixes with the `inspect` arguments
    for infix in p[:infixes]
        sym = argsym(infix)
        name = string(sym)
        push!(fbody, :(cmd = replace(cmd, $name, $sym)))
    end

    if p[:values][1].head != :(in)
        vtyp = argtype(p[:values][1])
        if vtyp <: Number
            P,C = returntype(vtyp)
            push!(fbody, :(($C)(parse(ask(ins, cmd))::($P))) )
        else
            push!(fbody, :(ask(ins, cmd)) )
        end
    else
        push!(fbody, :(($T)(ins, ask(ins, cmd))))
    end
    eval(inspect)

    inspect
end

function generate_configure{S<:Instrument}(instype::Type{S}, p)

    # Get the instrument property type and assert.
    T = eval(p[:type])

    command = p[:cmd]
    !haskey(p, :infixes) && (p[:infixes] = [])

    length(p[:values]) > 1 && error("Not yet implemented.")

    method = Expr(:call, :configure,
        :(ins::$S), :(::Type{$T}), map(stripin, p[:values])..., p[:infixes]...)

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
    eval(configure)

    configure
end
