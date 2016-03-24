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
Returns :_____ if given `:(::Integer)`.
"""
function argsym(expr)
    if expr.head == :(::)
        if length(expr.args) == 1
            return :_____
        else
            return expr.args[1]
        end
    elseif expr.head == :(=) || expr.head == :(kw)
        return argsym(expr.args[1])
    else
        error("Cannot handle this argument.")
    end
end

function generate_inspect{S<:Instrument,T<:InstrumentProperty}(instype::Type{S},
        command::ASCIIString, proptype::Type{T}, args...)

    infixnames = matchall(r"[a-z]+", command)
    infixsymbs = [symbol(n) for n in infixnames]

    valtypes = DataType[]

    fargs = [:(ins::$S), :(::Type{$T})]
    for a in args
        # The equal sign in an optional function argument is reinterpreted as :kw.
        a.head == :(=) && (a.head = :kw)
        if findfirst(infixsymbs, argsym(a)) == 0
            push!(valtypes, argtype(a))
        else
            push!(fargs, a)
        end
    end

    # If it looks like configure needs two or more parameters to follow the
    # command, the return type for inspect is not obvious
    length(valtypes) > 1 && error("Not yet implemented.")

    method  = Expr(:call, :inspect, fargs...)
    inspect = Expr(:function, method, Expr(:block))
    fbody = inspect.args[2].args

    command[end] != '?' && (command *= "?")
    push!(fbody, :(cmd = $command))

    for name in infixnames
        push!(fbody, :(cmd = replace(cmd, $name, $(symbol(name)))))
    end

    if length(valtypes) == 1
        vtyp = valtypes[1]
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

function generate_configure{S<:Instrument,T<:InstrumentProperty}(instype::Type{S},
    command::ASCIIString, proptype::Type{T}, args...)

    infixnames = matchall(r"[a-z]+", command)
    infixsymbs = [symbol(n) for n in infixnames]

    valtypes = DataType[]
    valsymbs = Symbol[]

    fargs = [:(ins::$S)]

    # See what we have that is not an infix
    for a in args
        # Make optional args
        a.head == :(=) && (a.head = :kw)
        # If not an infix, push to valtypes and valsymbs
        if findfirst(infixsymbs, argsym(a)) == 0
            push!(valtypes, argtype(a))
            push!(valsymbs, argsym(a))
        end
    end

    length(valtypes) > 1 && error("Not yet implemented.")
    if length(valtypes) == 0
        # We must be configuring based on subtypes of T.
        
    else
        # We configure based on a value.
        push!(fargs, :(::Type{$T}))
        method = Expr(:call, :configure, fargs..., args...)
        configure = Expr(:function, method, Expr(:block))
        fbody = configure.args[2].args
        push!(fbody, :(cmd = $command * " #"))
        for name in infixnames
            push!(fbody, :(cmd = replace(cmd, $name, $(symbol(name)))))
        end
        push!(fbody, :(write(ins, cmd, fmt($(valsymbs[1])))))
    end
    eval(configure)

    configure
end
