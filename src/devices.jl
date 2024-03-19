using Devices, Devices.PreferMicrons, FileIO
DPoint = Devices.Point
import Devices.Polygon

function to_gds(name::AbstractString, points::AbstractVector{<:DPoint})
    file = File{format"GDS"}("$name.gds")
    p = CellPolygon(Polygon(points), GDSMeta())
    c = Cell(name)
    push!(c.elements, p)
    save(file, c)
end

function to_gds(name::AbstractString, cell_polygons::AbstractVector{CellPolygon})
    file = File{format"GDS"}("$name.gds")
    c = Cell(name)
    append!(c.elements, cell_polygons)
    save(file, c)   
end

function Polygon(points::AbstractVector{NTuple{2, Float64}})
    Polygon(DPoint.(points))
end

export to_gds