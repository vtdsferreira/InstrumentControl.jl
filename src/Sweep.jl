### Basic sweep code

export sweep

function plottype{T<:Real}(dep::Response{T},
    indep::Tuple{Stimulus, AbstractArray}...)

    nstim = length(indep)
    plottype = (nstim > 1 ? HeatmapMeasurement : ScatterMeasurement)


end

"""
Measures a response as a function of an arbitrary number of stimuli.

Implementation: N `for` loops are built around a simple body programmatically,
given N stimuli. The stimuli are sourced at the start of each for loop.
The body just measures the response with an optional time delay.

Not type stable (return type depends on number of arguments). If for some
reason this were executed in a tight loop it might be good to annotate
the return type in the calling function. For most purposes there should be
minimal performance penalty.
"""
function sweep{T}(dep::Response{T},
    indep::Tuple{Stimulus, AbstractArray}...; tstep=0)

    # Notify the live graph task
    notify(live_new_meas, ScatterMeasurement("x","y"))

    # Create loop symbols for arbitrary nested loops
    localvars = [gensym() for i in 1:length(indep)]

    # Preallocate output memory. We want an array in column-major order.
    array = Array{T}([length(a) for (i,a) in indep]...)

    # Describe looping over an independent variable...
    loops = [(expr)->begin
        f = Expr(:for, Expr(:(=), localvars[i], indep[i][2]))
        g = Expr(:block)
        push!(g.args, Expr(:call, :source, indep[i][1], localvars[i]))
        push!(g.args, expr)
        push!(f.args, g)
        f
    end for i in 1:length(indep)]

    # Body of the nested for loop
    body = Expr(:block)
    push!(body.args, Expr(:call, :sleep, tstep))
    assign = Expr(:(=))
    push!(assign.args, Expr(:ref, array, localvars...))
    push!(assign.args, Expr(:call, :measure, dep))
    push!(body.args, assign)

    # Function chaining. |> is the chaining operator.
    # Nest the for loops around the body.
    uate = reduce(|>, [body; loops])

    # Run our for loop
    eval(uate)

    array
end
