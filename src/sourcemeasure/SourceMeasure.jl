export source, measure, scaling
export Stimulus, Response

export axisname, axislabel
export axisscales, axisnames

global scaling

abstract Stimulus
abstract Response

function axisname(x::Stimulus)
    if :axisname in fieldnames(x) && isdefined(x, :axisname)
        x.axisname
    else
        # Default axis name implementation
        gensym(summary(x))
    end
end

function axislabel(x::Stimulus)
    if :axislabel in fieldnames(x) && isdefined(x, :axislabel)
        x.axislabel
    else
        # Default axis label implementation
        summary(x)
    end
end


# """
# ```
# axisscales(x::Response)
# ```
#
# For a response that returns an `n`-dimensional result array when measured, this
# function returns a tuple of length `n` of `AbstractVector`s. Each vector is the
# axis scaling for the corresponding dimension of the array. Responses which
# return vectors, matrices, and higher-order tensors should implement this method.
# Defaults to `()` for scalar responses.
# """
# axisscales(x::Response) = ()
#
# """
# ```
# axisnames(x::Response)
# ```
#
# For a response that returns an `n`-dimensional result array when measured, this
# function returns a `Vector{String}`. Each string is the axis name for the
# corresponding dimension of the array. Responses which return vectors, matrices,
# and higher-order tensors should implement this method. Defaults to `String[]`
# for scalar responses.
# """
# axisnames(x::Response) = String[]

include("averaging.jl")
include("dependent.jl")
include("dummy.jl")
include("property.jl")
include("random.jl")
include("responsestim.jl")
include("time.jl")
include("worker.jl")

# """
# ```
# axisunits(x::Response)
# ```
#
# For a response that returns an `n`-dimensional result array when measured, this
# function returns a `Vector{String}`. Each string is the axis name for the
# corresponding dimension of the array. Responses which return vectors, matrices,
# and higher-order tensors should implement this method. Defaults to `String[]` for
# scalar responses.
# """
# axisunits(x::Response) = String[]
