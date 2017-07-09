import ZMQ
using JSON

export plotserver

function plotobj(dep::Response,
    indep::NTuple{1,Tuple{Stimulus, AbstractArray}})

    PlotSetup(size(indep[1][2]), Base.return_type(measure, (typeof(dep),)[1]);
        xlabel = plotlabel(indep[1]),
        ylabel = plotlabel(dep),
        series_type = :scatter
    )
end

function plotobj{N}(dep::Response,
    indep::NTuple{N,Tuple{Stimulus, AbstractArray}})

    nothing
end

function dataobj(inds, v)
    PlotPoint(inds, v)
end

function dataobj(data, inds::NTuple{2,Int}, vals)
    # HeatmapPoint(inds[1], inds[2], data)
end

function plotlabel(dep::Response)
    return "Response"
end

function plotlabel(dep::Tuple{Stimulus, AbstractArray})
    return "Stimulus"
end
