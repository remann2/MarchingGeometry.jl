function Makie.plot!(p::Render{<:Tuple{Segment}})
    #seg = p[:obj]
    seg = p[1]
    ps = lift(seg -> [seg.P1, seg.P2], seg)
    lines!(p, ps)
    return p
end

function Makie.plot!(p::Render{<:Tuple{AbstractVector{Segment}}})
    segs = p[:obj]
    function to_seg_points(segs)
        n = length(segs) * 2
        points = Point2f.(zeros(n), zeros(n))
        for (i,s) in enumerate(segs)
            points[2i-1:2i] = [s.P1, s.P2]
        end
        points
    end
    points = lift(to_seg_points, segs)
    linesegments!(p, points)
    return p
end

function Makie.plot!(p::Render{<:Tuple{Grid{2}}})
    grid = p[:obj][]
    values = grid.values
    scatter!(p, vertices(grid); color=values)
    p
end

