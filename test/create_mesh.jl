using Gmsh

gmsh.initialize()

gmsh.model.geo.addPoint(0, 0, 0, 0.01, 1)
gmsh.model.geo.addPoint(1, 0, 0, 0.01, 2)
gmsh.model.geo.addPoint(1, 1, 0, 0.01, 3)
gmsh.model.geo.addPoint(0, 1, 0, 0.01, 4)

gmsh.model.geo.addLine(1, 2, 1)
gmsh.model.geo.addLine(2, 3, 2)
gmsh.model.geo.addLine(3, 4, 3)
gmsh.model.geo.addLine(4, 1, 4)

gmsh.model.geo.addCurveLoop([1, 2, 3, 4], 1)
gmsh.model.geo.addPlaneSurface([1], 1)

gmsh.model.geo.synchronize()

gmsh.model.mesh.generate(2)

gmsh.write("rectangle.msh")

gmsh.finalize()

