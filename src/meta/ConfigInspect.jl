"Given an expression like `:(x::Integer)` or `:(x::Integer=3)`, will return `Integer`."
function argtype(expr)
    if expr.head == :(::)
        if length(expr.args) == 1
            return eval(expr.args[1])
        else
            return eval(expr.args[2])
        end
    elseif expr.head == :(=) || expr.head == :(kw)
        return argtype(expr.args[1])
    else
        error("Cannot handle this argument.")
    end
end

"""
Given an expression like `:(x::Integer)` or `:(x::Integer=3)`, will return `x`.
Returns :_ if given `:(::Integer)`.
"""
function argsym(expr)
    if expr.head == :(::)
        if length(expr.args) == 1
            return :_
        else
            return expr.args[1]
        end
    elseif expr.head == :(=) || expr.head == :(kw)
        return argsym(expr.args[1])
    else
        error("Cannot handle this argument.")
    end
end

function generate_inspect{S<:Instrument}(instype::Type{S}, p)
        #command::ASCIIString, proptype::Type{T}, args...)

    # Get the instrument property type and assert.
    T = eval(p[:type])

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

    if length(p[:values]) == 1
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

    length(p[:values]) > 1 && error("Not yet implemented.")
    if length(p[:values]) == 0
        # We must be configuring based on subtypes of T.
        method = Expr(:call, Expr(:curly, :configure, Expr(:(<:), :T, p[:type])),
            :(ins::$S), :(::Type{T}), p[:infixes]...)
    else
        # We must be configuring based on values.
        # Begin constructing our definition of `configure`
        method = Expr(:call, :configure,
            :(ins::$S), :(::Type{$T}), p[:values]..., p[:infixes]...)
    end
    configure = Expr(:function, method, Expr(:block))
    fbody = configure.args[2].args

    # In the function body: Define `cmd`
    push!(fbody, :(cmd = $(command*" #")))
    for infix in p[:infixes]
        sym = argsym(infix)
        name = string(sym)
        push!(fbody, :(cmd = replace(cmd, $name, $sym)))
    end

    if length(p[:values]) == 0
        push!(fbody, :(write(ins, cmd, code(ins, T))))
    else
        vsym = argsym(p[:values][1])
        push!(fbody, :(write(ins, cmd, fmt($vsym))))
    end
    eval(configure)

    configure
end
