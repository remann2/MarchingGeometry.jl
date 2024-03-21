function get_bound_nodes(model::Gridap.Geometry.Grid)
    B = BoundaryTriangulation(model)
    bs = get_cell_coordinates(B)
    collect(Set(Tuple.(c for cs in bs for c in cs)))
end

function read_msh(msh_file::String, f::Function)
    model = GmshDiscreteModel(msh_file)
    reffe = ReferenceFE(lagrangian, Float64 , 1)
    V = FESpace(model, reffe)
    uh = interpolate_everywhere(f, V)
    T = Triangulation(model)
    bounds = get_bound_nodes(model)
    read_msh(T, bounds, uh)
end

function read_msh(msh_file::String, uh::CellField)
    model = GmshDiscreteModel(msh_file)
    T = Triangulation(model)
    bounds = get_bound_nodes(model)
    read_msh(T, bounds, uh)
end

function read_msh(trian::Gridap.Geometry.Grid, bound_nodes::Vector{NTuple{2, Float64}}, uh::CellField)
    vd = first(visualization_data(trian, "value", cellfields=["value"=>uh]))
    nodes = get_cell_coordinates(trian)
    tri_mesh = TriangleMesh(
        [Triangle(Tuple.(_nodes)...) for _nodes in nodes],
        bound_nodes
    )
    nodevals = partition(vd.nodaldata["value"], 3)
    return tri_mesh, nodevals
end

function read_msh(uh::CellField)
    trian = uh.trian
    bounds = get_bound_nodes(trian)
    read_msh(trian, bounds, uh)
end

struct Triangle
    p1::NTuple{2, Float64}
    p2::NTuple{2, Float64}
    p3::NTuple{2, Float64}
end
    
function edges(t::Triangle)
    [
        Segment(t.p1, t.p2),
        Segment(t.p2, t.p3),
        Segment(t.p3, t.p1)
    ]
end

function seg_nodes(t::Triangle)
    [
        (t.p1, t.p2),
        (t.p2, t.p3),
        (t.p3, t.p1)
    ]
end

function get_nodes(t::Triangle)
    t.p1, t.p2, t.p3
end

struct TriangleMesh
    tris::Vector{Triangle}
    bound_nodes::Vector{NTuple{2, Float64}}
end



