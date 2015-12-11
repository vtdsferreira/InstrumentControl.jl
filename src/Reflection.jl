export configurable
export inspectable

function configurable{T<:Instrument}(instype::Type{T})
    signatures(instype, configure)
end

function inspectable{T<:Instrument}(instype::Type{T})
    signatures(instype, inspect)
end

function signatures{T<:Instrument}(instype::Type{T}, f::Function)
    metharray = methods(f, Tuple{instype, Vararg{Any}})
    start = "::"*string(instype.name.name)
    cmds = Array{ASCIIString,1}()

    for m in metharray
        cmd = start
        p = m.sig.parameters[2:end]
        for i in 1:length(p)
            cmd = cmd*", ::"*string(p[i])
        end
        push!(cmds, cmd)
    end
    for x in cmds
        println(x)
    end
    nothing
end
