using MarchingGeometry
using GLMakie

g = Grid((0., 0.), (1., 1.), (20, 20))
plot(g)
mg = marching_square(g, 0.5, x -> rand())
plot(mg)
segments = mg.segs

@time endpoint_map = create_segment_endpoint_map(segments);
@time polygons = group_segments_into_polygons(segments, endpoint_map);
@time looped = get_points_loop(polygons[1]);

poly = polygons[1]

MarchingGeometry.plot(poly[1:end])
plot(polygons[1])
Polygon(looped)

using Devices
loops = []
cps = CellPolygon[]
for poly in polygons
    loop = get_points_loop(poly)
    push!(cps, CellPolygon(Polygon(loop), GDSMeta()))
end

to_gds("test3", cps)

plot(mg)
function gaussian(center, width)
    x -> exp(-((x[1]-center[1])^2 + (x[2]-center[2])^2) / (2*width^2)) / (2*pi*width^2)
end

gaussian((0.5, 0.5), 0.3)((1, 1))

mg = marching_square(g, 0.5, gaussian((0.5, 0.5), 0.3))

plot(mg)

