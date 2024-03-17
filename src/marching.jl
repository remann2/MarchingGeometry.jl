using MarchingGeometry.Geometry

struct MarchedGrid{D}
    g::Grid{D}
    segs::AbstractVector{Segment}
end

function get_case(values, isovalue)
    values = values .> isovalue
    values[1] * 8 + values[2] * 4 + values[3] * 2 + values[4]
end

function get_middle(p1, p2)
    return @. (p1 + p2) / 2
end

function marching_square(g::Grid{2}, isovalue::Float64)
    g = pad(g)
    set_edges!(g, -Inf)
    g.values[] = g.values[] .> isovalue
    segs = Segment[]
    for (ps, values) in zip(MarchIterator(g, :position), MarchIterator(g, :value))
        case = get_case(values, isovalue)
        if case in [0, 15]
            # no intersections
        elseif case in [1, 14]
            push!(segs, Segment(get_middle(ps[3], ps[4]), get_middle(ps[1], ps[4])))
        elseif case in [2, 13]
            push!(segs, Segment(get_middle(ps[2], ps[3]), get_middle(ps[3], ps[4])))
        elseif case in [3, 12]
            push!(segs, Segment(get_middle(ps[2], ps[3]), get_middle(ps[1], ps[4])))
        elseif case in [4, 11]
            push!(segs, Segment(get_middle(ps[2], ps[1]), get_middle(ps[2], ps[3])))
        elseif case in [5, 10]
            push!(segs, Segment(get_middle(ps[2], ps[1]), get_middle(ps[1], ps[4])))
            push!(segs, Segment(get_middle(ps[2], ps[3]), get_middle(ps[3], ps[4])))
        elseif case in [6, 9]
            push!(segs, Segment(get_middle(ps[2], ps[1]), get_middle(ps[3], ps[4])))
        elseif case in [7, 8]
            push!(segs, Segment(get_middle(ps[2], ps[1]), get_middle(ps[1], ps[4])))
        end
    end
    return MarchedGrid(g, segs)   
end

function marching_square(g::Grid{2}, isovalue::Float64, f::Function)
    g.values[] = f.(collect(g))
    marching_square(g, isovalue)
end

export get_middle, marching_square, MarchedGrid
