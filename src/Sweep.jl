export sweep
using Base.Cartesian
using Common
import Compat.view

import ZMQ
const ctx = ZMQ.Context()
const s = ZMQ.Socket(ctx, ZMQ.PUB)
ZMQ.bind(s, "tcp://127.0.0.1:50001")

"""
```
sweep(dep::Response, indep::Tuple{Stimulus, AbstractVector}...)
```

Measures a response as a function of an arbitrary number of stimuli, and returns
an appropriately-sized and typed Array object. The implementation uses
`@generated` and macros from
[Base.Cartesian](http://docs.julialang.org/en/release-0.5/devdocs/cartesian/).
The stimuli are sourced only when they need to be, at the start of each
`for` loop level.
"""
function sweep(dep::Response, indep::Tuple{Stimulus, AbstractVector}...)
    t = Task(()->_sweep(dep, indep...))
    for x in t
        ZMQ.send(s, ZMQ.Message(x))
    end
    consume(t)
end

@generated function _sweep(dep::Response, indep::Tuple{Stimulus, AbstractVector}...)
    N = length(indep)
    quote
        T = returntype(measure, (typeof(dep),))
        array = Array{T}([length(a) for (stim, a) in indep]...)

        io = IOBuffer()
        serialize(io, PlotSetup(Array{T}, size(array)))
        produce(io)

        @nloops $N i array j->(source(indep[j][1], indep[j][2][i_j])) begin
            data = measure(dep)
            (@nref $N array i) = data

            io = IOBuffer()
            serialize(io, PlotPoint((@ntuple $N i), data))
            produce(io)
        end

        array
    end
end
