using MarchingGeometry.Geometry
using DataStructures

struct MarchedGrid{D}
    g::Grid{D}
    segs::AbstractVector{Segment}
end

function get_case_rect(values, isovalue)
    values = values .> isovalue
    values[1] * 8 + values[2] * 4 + values[3] * 2 + values[4]
end

function get_middle(p1, p2)
    return @. (p1 + p2) / 2
end

function get_middle(p1, p2, v1, v2, isovalue)
    t = (isovalue - v1) / (v2 - v1)
    return @. p1 + t * (p2 - p1)   
end

function march_square(g::Grid{2}, isovalue::Float64, interpolate::Bool=false)
    # todo use the interpolation
    g = pad(g)
    set_edges!(g, -Inf)
    g.values[] = g.values[] .> isovalue
    segs = Segment[]
    for (ps, values) in zip(MarchIterator(g, :position), MarchIterator(g, :value))
        case = get_case_rect(values, isovalue)
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

function march_square(g::Grid{2}, isovalue::Float64, f::Function)
    g.values[] = f.(collect(g))
    march_square(g, isovalue)
end

function get_case_tri(vs)
    return vs[1]*4 + vs[2]*2 + vs[3]
end

function zero_value_nodes_dict(nodes::AbstractVector{NTuple{2, Float64}}, default)
    d = DefaultDict{NTuple{2, Float64}, Float64}(default)
    for n in nodes
        d[n] = 0.
    end
    d
end

function march_triangle(t::TriangleMesh, isovalue::Float64, values)
    segs = Segment[]
    d = zero_value_nodes_dict(t.bound_nodes, 1.)
    for (t, vs) in zip(t.tris, values)
        p1, p2, p3 = get_nodes(t)
        dvals = [d[p1], d[p2], d[p3]]
        vs = @. ifelse(dvals == 0., dvals, vs)
        case = get_case_tri(vs .> isovalue)
        v1, v2, v3 = vs
        if case in [0, 7]
        elseif case in [3,4]
            push!(
                segs, 
                Segment(
                    get_middle(p1, p2, v1, v2, isovalue), 
                    get_middle(p1, p3, v1, v3, isovalue)
                    )
                )
        elseif case in [5,2]
            push!(
                segs, 
                Segment(
                    get_middle(p1, p2, v1, v2, isovalue), 
                    get_middle(p2, p3, v2, v3, isovalue)
                    )
                )
        else
            push!(
                segs, 
                Segment(
                    get_middle(p1, p3, v1, v3, isovalue), 
                    get_middle(p2, p3, v2, v3, isovalue)
                    )
                )
        end
    end
    return segs
end

export get_middle, march_square, MarchedGrid, march_triangle
