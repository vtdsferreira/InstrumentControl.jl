### Basic sweep code

export sweep

"""
This method is slightly more convenient than the other sweep method
but not type stable. The return type depends on the number of arguments.
If for some reason this were executed in a tight loop it might be good to
annotate the return type in the calling function. For most purposes there should
be minimal performance penalty.
"""
function sweep{T}(dep::Response{T},
    indep::Tuple{Stimulus,AbstractArray}...; tstep=0)

    sweep(dep, (indep...,), tstep=tstep)
end

"""
Measures a response as a function of an arbitrary number of stimuli.
Implementation: N `for` loops are built around a simple body programmatically,
given N stimuli. The stimuli are sourced at the start of each for loop.
The body just measures the response with an optional time delay.
"""
@generated function sweep{T<:Real,N}(dep::Response{T},
    indep::NTuple{N,Tuple{Stimulus, AbstractArray}}; tstep=0)

    # Create loop symbols for arbitrary nested loops
    vals = [gensym() for i in 1:N]
    inds = [gensym() for i in 1:N]

    # Begin expression.
    # Preallocate output memory. We want a multidim. array in column-major order.
    expr = quote
        notify(LIVE_NEW_MEAS, (dep, (indep...)) )
        array = Array{T}([length(a) for (stim, a) in indep]...)
    end

    # Make some for loop expressions.
    loops = [quote
                for ($(inds[i]), $(vals[i])) in enumerate(indep[$i][2])
                    source(indep[$i][1], $(vals[i]))
                end
             end for i in 1:N]

    # Make the body of the inner for loop.
    body = quote
        sleep(tstep)
        data = measure(dep)
        array[$(inds...)] = data
        notify(LIVE_DATA, (data, ($(inds...),), ($(vals...),)) )
    end

    # Construct our expression
    for i in collect(1:length(loops))
        if (i == 1)
            # Stick the body in the first for loop
            push!(loops[i].args[2].args[2].args, body)
        else
            # Stick the first for loop in the second, etc.
            push!(loops[i].args[2].args[2].args, loops[i-1])
        end
    end

    # Put the nested for loops into our expression.
    # Signal end of plot
    # Return the array at the end
    push!(expr.args, loops[end])
    push!(expr.args, :(notify(LIVE_DATA, EndOfPlot())))
    push!(expr.args, :array)

    expr
end
