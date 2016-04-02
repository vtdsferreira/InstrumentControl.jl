export sweep
using Base.Cartesian

"""
`sweep{T}(dep::Response{T}, indep::Tuple{Stimulus, AbstractArray}...)`

Measures a response as a function of an arbitrary number of stimuli, and returns
an appropriately-sized and typed Array object. The implementation uses `@generated`
and macros from [Base.Cartesian](http://docs.julialang.org/en/release-0.4/devdocs/cartesian/).
The stimuli are sourced only when they need to be, at the start of each
`for` loop level.
"""
@generated function sweep{T}(dep::Response{T}, indep::Tuple{Stimulus, AbstractArray}...)

    N = length(indep)

    quote
        # notify(LIVE_NEW_MEAS, (dep, (indep...)) )
        array = Array{T}([length(a) for (stim, a) in indep]...)
        @nloops $N i array j->(source(indep[j][1], indep[j][2][i_j])) begin
            # @nexprs $N
            data = measure(dep)
            (@nref $N array i) = data
            # notify(LIVE_DATA, (data, ($(inds...),), ($(vals...),)) )
        end
        # notify(LIVE_DATA, EndOfPlot())
        array
    end
end
