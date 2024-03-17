module Geometry
    using Makie
    using StaticArrays
    using DataStructures

    include("segments.jl")
    include("grid.jl")

    export Segment, randpoints, create_segment_endpoint_map, 
           order_segments_within_each_group, group_segments_into_polygons, 
           get_points_loop, Grid, vertices, set_values!, get_values, 
           set_edges!, get_value, set_value!, pad, MarchIterator, plotsegs   
end