"""
    Grid{D}

A struct representing a grid in D dimensions. 

# Fields
- `lower_limits::NTuple{D, Float64}`: The lower limits in each direction.
- `upper_limits::NTuple{D, Float64}`: The upper limits in each direction.
- `ns::NTuple{D, Int}`: The number of elements in each direction.
- `res_x::Float64`: The span between two points in the x direction.
- `res_y::Float64`: The span between two points in the y direction.
- `values::Observable{AbstractVector{Float64}}`: An observable vector of Float64 values.

# Constructor
- `Grid(ls::NTuple{2, Float64}, us::NTuple{2, Float64}, ns::NTuple{2, Int})`: Constructs a Grid object. 
    - `ls`: Lower limits in (x, y) direction.
    - `us`: Upper limits in (x, y) direction.
    - `ns`: Number of elements in each direction.

# Methods
- `pad(g::Grid{2})`: Returns a new grid that is a padded version of the input grid `g`.
- `vertices(g::Grid{2})`: Returns the vertices of the grid `g`.
"""
struct Grid{D} 
    lower_limits::NTuple{D, Float64} 
    upper_limits::NTuple{D, Float64} 
    ns::NTuple{D, Int} 
    res_x::Float64
    res_y::Float64
    values::Observable{AbstractVector{Float64}} 
end

function Grid(lower_limits::NTuple{2, Float64}, upper_limits::NTuple{2, Float64}, ns::NTuple{2, Int})
    @assert all(upper_limits .> lower_limits)
    @assert all(ns .> 1)
    Grid{2}(
        lower_limits,
        upper_limits,
        ns,
        (upper_limits[1] - lower_limits[1]) / (ns[1]-1),
        (upper_limits[2] - lower_limits[2]) / (ns[2]-1),
        Observable(zeros(prod(ns)))
    )
end

function get_value(g::Grid{2}, i::Int, j::Int)
    @assert all((j, i) .<= g.ns) (i, j)
    g.values[][(i-1)*g.ns[1] + j]
end

function set_value!(g::Grid{2}, i::Int, j::Int, value::Float64)
    @assert all((j, i) .<= g.ns) (i, j)
    g.values[][(i-1)*g.ns[1] + j] = value
end

function pad(g::Grid{2})
    new_g = Grid(
        (g.lower_limits[1]-g.res_x, g.lower_limits[2]-g.res_y),
        (g.upper_limits[1]+g.res_x, g.upper_limits[2]+g.res_y),
        g.ns .+ 2
    )
    for i in 1:g.ns[2]
        for j in 1:g.ns[1]
            set_value!(
                new_g, i+1, j+1,
                get_value(g,i, j)
            )
        end
    end
    new_g
end

function Base.length(g::Grid{2})
    return prod(g.ns)
end

function Base.getindex(g::Grid{2}, i::Int, j::Int)
    @assert 0 < i <= g.ns[2]
    @assert 0 < j <= g.ns[1]
    (g.lower_limits[1] + (j-1) * g.res_x, g.lower_limits[2] + (i-1)*g.res_y)
end

function Base.iterate(g::Grid{2}, state=(1, 1))
    i, j = state
    if i > g.ns[2]
        return nothing
    end
    point = g[i, j]
    if j < g.ns[1]
        next_state = (i, j + 1)
    else
        next_state = (i + 1, 1)
    end
    return (SVector{2, Float64}(point), next_state)
end

function vertices(g::Grid{2})
    collect(SVector{2, Float64}, g)
end

function set_values!(g::Grid, values::AbstractVector{Float64})
    @assert length(values) == length(g)
    g.values[] = values
end

function get_values(g::Grid)
    g.values[]
end

function set_edges!(g::Grid{2}, value::Float64)
    for i in 1:g.ns[1]
        g.values[][(i-1)*g.ns[2]+1] = value
        g.values[][i*g.ns[2]] = value
    end
    for j in 1:g.ns[2]
        g.values[][j] = value
        g.values[][(g.ns[1]-1)*g.ns[2]+j] = value
    end
end

struct MarchIterator{D}
    g::Grid{D}
    key::Symbol
end

function Base.length(mi::MarchIterator)
    prod(mi.g.ns .- 1)
end

function Base.iterate(mi::MarchIterator{2}, state=(1, 1))
    i, j = state
    if i >= mi.g.ns[2] || j >= mi.g.ns[1]
        return nothing
    end
    if mi.key == :position
        square = [mi.g[i, j], mi.g[i, j+1], mi.g[i+1, j+1], mi.g[i+1, j]]
    elseif mi.key == :value
        square = [
                get_value(mi.g, i, j),
                get_value(mi.g, i, j+1),
                get_value(mi.g, i+1, j+1),
                get_value(mi.g, i+1, j),
                
            ]
    else
        throw(ArgumentError("Invalid key: $(mi.key). Valid keys are :position and :value."))
    end
    if j < mi.g.ns[1] - 1
        next_state = (i, j + 1)
    else
        next_state = (i + 1, 1)
    end
    return (square, next_state)
end


function plotsegs(g::Grid{2})
    iter = MarchIterator(g, :position)
    n = length(iter) * 8
    points = tuple.(zeros(n), zeros(n))
    i = 1
    for (p1, p2, p3, p4) in MarchIterator(g, :position)
        points[i:i+7] = [p1, p2, p2, p3, p3, p4, p4, p1]
        i += 8
    end
    linesegments(points)
end