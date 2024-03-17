using Makie
import Makie.plot

@recipe(Render, obj) do scene
    Attributes(
    )
end

function plot(obj::Union{AbstractVector{Segment}, Segment, Grid{2}, MarchedGrid{2}})
    render(obj)
end

include("geometry.jl")
include("marching.jl")