struct Segment
    P1::NTuple{2, Float64}
    P2::NTuple{2, Float64}
end

randpoints() = begin
    xs = rand(10)
    ys = rand(10)
    @. Segment(tuple(xs, ys), tuple(xs + rand(), ys + rand()))
end

function create_segment_endpoint_map(segments)
    endpoint_map = DefaultDict{NTuple{2, Float64}, Vector{Segment}}(Vector{Segment})
    for segment in segments
        push!(endpoint_map[segment.P1], segment)
        push!(endpoint_map[segment.P2], segment)
    end
    return endpoint_map
end

function group_segments_into_polygons(segments, endpoint_map)
    visited = Dict{Segment, Bool}()
    for segment in segments
        visited[segment] = false
    end

    polygons = []
    while any(value -> value == false, values(visited))
        start_segment = findfirst(value -> value == false, visited)
        polygon = [start_segment]
        visited[start_segment] = true

        current_segment = start_segment
        while true
            tmp_segments = [endpoint_map[current_segment.P1]... endpoint_map[current_segment.P2]...]
            next_segment_idx = findfirst(segment -> segment != current_segment && !visited[segment], tmp_segments)
            if next_segment_idx === nothing
                break
            end
            next_segment = tmp_segments[next_segment_idx]
            if next_segment == start_segment
                break
            end
            push!(polygon, next_segment)
            visited[next_segment] = true
            current_segment = next_segment
        end
        push!(polygons, polygon)
    end
    return polygons
end

function get_common_point(seg1::Segment, seg2::Segment)
    if seg1.P1 == seg2.P1 || seg1.P1 == seg2.P2
        return seg1.P1
    elseif seg1.P2 == seg2.P1 || seg1.P2 == seg2.P2
        return seg1.P2
    else
        throw(DomainError("no common point found for ($seg1, $seg2)"))
    end
end

function get_other_end(seg::Segment, p::NTuple{2, Float64})
    if seg.P1 == p 
        return seg.P2
    elseif seg.P2 == p
        return seg.P1
    else
        throw(DomainError("Point $p doesn't belong to segment $seg"))
    end
end

function get_points_loop(polygon::AbstractVector{Segment})
    loop = NTuple{2, Float64}[]
    for i in 1:(length(polygon)-1)
        seg_1 = polygon[i]
        seg_2 = polygon[i+1]
        cp = get_common_point(seg_1, seg_2)
        push!(loop, get_other_end(seg_1, cp))   
        if i == length(polygon) - 1
            push!(loop, cp)
            push!(loop, get_other_end(seg_2, cp))
        end
    end
    return loop
end
    

function order_segments_within_each_group(polygons, endpoint_map)
    for polygon in polygons
        ordered_polygon = [polygon[1]]
        current_segment = polygon[1]
        while length(ordered_polygon) < length(polygon)
            segs = endpoint_map[current_segment.P2]
            next_segment = segs[findfirst(segment -> segment != current_segment && segment in polygon, segs)]
            push!(ordered_polygon, next_segment)
            current_segment = next_segment
        end
        polygon = ordered_polygon
    end
end


# osegs = Observable(randpoints())
# 
# fig, ax, plt = plot(osegs)
# n = 1000
# @time for i in 1:n
#     osegs[] = randpoints(); autolimits!(ax)
#     sleep(1/n)
# end
# 
# s = Observable(Segment((1., 1.), (2., 2.)))
# fig, ax, plt = plot(s)
# s[] = Segment(rand(2), rand(2))
# 
# for i in 1:10
#     s[] = Segment(rand(2), rand(2))
#     autolimits!(ax)
#     sleep(1)
# end
