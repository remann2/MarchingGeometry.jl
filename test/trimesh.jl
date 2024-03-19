using MarchingGeometry
using CairoMakie
f(x) = sqrt(x[1]^2 + x[2]^2) 
g(x) = 1 - f(x .- 0.5) - 0.1


tm, vals = read_msh("rectangle.msh", g)
@time segments = march_triangle(tm, 0.5, vals)
cords = [c for tri in tm.tris for c in get_nodes(tri)]
vs = [s for v in vcat(collect(vals)) for s in v]

# fig = plot([s for t in tm.tris for s in edges(t)])
fig = plot(segs)

@time endpoint_map = create_segment_endpoint_map(segments);
@time polygons = group_segments_into_polygons(segments, endpoint_map);
@time looped = get_points_loop(polygons[1]);

using Devices
loops = []
cps = CellPolygon[]
for poly in polygons
    loop = get_points_loop(poly)
    push!(cps, CellPolygon(Polygon(loop), GDSMeta()))
end

to_gds("test1", cps)

