function Makie.plot!(p::Render{<:Tuple{MarchedGrid{2}}})
    mg = p[:obj]
    g = lift(mg -> mg.g, mg)
    segs = lift(mg -> mg.segs, mg)
    render!(p, g)
    render!(p, segs)
    return p
end

