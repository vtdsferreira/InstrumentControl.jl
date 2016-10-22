export source, measure, scaling
export Stimulus, Response

global scaling

abstract Stimulus
abstract Response

include("averaging.jl")
include("debug.jl")
include("dependent.jl")
include("dummy.jl")
include("property.jl")
include("random.jl")
include("responsestim.jl")
include("time.jl")
include("worker.jl")
