using Devices, Devices.PreferMicrons, FileIO
DPoint = Devices.Point
import Devices.Polygon

function to_gds(name::AbstractString, points::AbstractVector{<:DPoint})
    c = Cell(basename(name))
    file = File{format"GDS"}("$name.gds")
    p = CellPolygon(Polygon(points), GDSMeta())
    push!(c.elements, p)
    save(file, c)
end

function to_gds(name::AbstractString, cell_polygons::AbstractVector{CellPolygon})
    c = Cell(basename(name))
    file = File{format"GDS"}("$name.gds")
    append!(c.elements, cell_polygons)
    save(file, c)   
end

function Polygon(points::AbstractVector{NTuple{2, Float64}})
    Polygon(DPoint.(points))
end

export to_gds