# ============================================================
# Geometrical Methods
# ============================================================

export global_frame, local_frame, unit_normal, point_distance
export PSpace1D, PSpace2D
export uniform_mesh, ndgrid, meshgrid, find_idx
export UnstructMesh
export read_mesh, mesh_connectivity_2D, mesh_cell_type, mesh_center_2D, mesh_area_2D, mesh_edge_center

include("geo_general.jl")
include("geo_struct.jl")
include("geo_unstruct.jl")
