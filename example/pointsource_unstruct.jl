using LinearAlgebra, ProgressMeter
import KitBase

function KitBase.write_vtk(ps, ctr)
    cdata = zeros(length(ctr))
    for i in eachindex(cdata)
        cdata[i] = ctr[i].w
    end
    return KitBase.write_vtk(ps.points, ps.cellid, cdata)
end

begin
    cd(@__DIR__)

    # time
    tspan = (0.0, 0.2)
    cfl = 0.7

    # quadrature
    quadratureorder = 6
    points, triangulation = KitBase.octa_quadrature(quadratureorder)
    weights = KitBase.quadrature_weights(points, triangulation)
    nq = size(points, 1)
    vs = KitBase.UnstructVSpace(-1.0, 1.0, nq, points, weights)

    # geometry
    cells, points = KitBase.read_mesh("../assets/mesh/pointsource.su2")
    cellid = KitBase.extract_cell(cells)
    edgePoints, edgeCells, cellNeighbors = KitBase.mesh_connectivity_2D(cellid)
    cellType = KitBase.mesh_cell_type(cellNeighbors)
    cellArea = KitBase.mesh_area_2D(points, cellid)
    cellCenter = KitBase.mesh_center_2D(points, cellid)
    edgeCenter = KitBase.mesh_edge_center(points, edgePoints)
    cellEdges = KitBase.mesh_cell_edge(cellid, edgeCells)
    ps = KitBase.UnstructPSpace(
        cells,
        points,
        cellid,
        cellType,
        cellNeighbors,
        cellEdges,
        cellCenter,
        cellArea,
        edgePoints,
        edgeCells,
        edgeCenter,
    )

    # particle
    SigmaS = ones(size(cellid, 1))
    SigmaA = zeros(size(cellid, 1))
    SigmaT = SigmaS + SigmaA
end

ctr = Array{KitBase.ControlVolumeUS1F}(undef, size(ps.cellid, 1))
for i in eachindex(ctr)
    n = Vector{Float64}[]
    for j in 1:3
        push!(
            n,
            KitBase.unit_normal(
                ps.points[edgePoints[cellEdges[i, j], 1], :],
                ps.points[edgePoints[cellEdges[i, j], 2], :],
            ),
        )

        if dot(ps.edgeCenter[ps.cellEdges[i, j], :] .- ps.cellCenter[i, :], n[j]) < 0
            n[j] .= -n[j]
        end
    end

    phi = ones(nq) .* 1e-4
    if 0.49 <= ps.cellCenter[i, 1] <= 0.51 && 0.49 <= ps.cellCenter[i, 2] <= 0.51
        phi .= 10.0
    end
    #s2 = 0.03^2
    #phi .= max(1e-4, 1.0 / (4.0 * π * s2) * exp(-((ps.cellCenter[i, 1]-0.5)^2 + (ps.cellCenter[i, 2]-0.5)^2) / 4.0 / s2))

    w = sum(weights .* phi)
    dx = [
        KitBase.point_distance(
            cellCenter[i, :],
            ps.points[ps.cellid[i, 1], :],
            ps.points[ps.cellid[i, 2], :],
        ),
        KitBase.point_distance(
            cellCenter[i, :],
            ps.points[ps.cellid[i, 2], :],
            ps.points[ps.cellid[i, 3], :],
        ),
        KitBase.point_distance(
            cellCenter[i, :],
            ps.points[ps.cellid[i, 3], :],
            ps.points[ps.cellid[i, 1], :],
        ),
    ]

    ctr[i] = KitBase.ControlVolumeUS1F(n, cellCenter[i, :], dx, w, w, phi)
end

face = Array{KitBase.Interface2D1F}(undef, size(ps.edgePoints, 1))
for i in eachindex(face)
    len = norm(ps.points[edgePoints[i, 1], :] .- ps.points[edgePoints[i, 2], :])
    n = KitBase.unit_normal(ps.points[edgePoints[i, 1], :], ps.points[edgePoints[i, 2], :])

    if !(-1 in ps.edgeCells[i, :])
        n0 = ps.cellCenter[ps.edgeCells[i, 2], :] .- ps.cellCenter[ps.edgeCells[i, 1], :]
    else
        n0 = zero(n)
    end
    if dot(n, n0) < 0
        n .= -n
    end

    fw = 0.0
    ff = zeros(nq)

    face[i] = KitBase.Interface2D1F(len, n[1], n[2], fw, ff)
end

dt = 1.0 / 200 * cfl
nt = tspan[2] ÷ dt |> Int
@showprogress for iter in 1:20#nt
    @inbounds Threads.@threads for i in eachindex(face)
        velo = vs.u[:, 1] .* face[i].n[1] + vs.u[:, 2] .* face[i].n[2]
        if !(-1 in ps.edgeCells[i, :])
            KitBase.flux_kfvs!(
                face[i].ff,
                ctr[ps.edgeCells[i, 1]].f,
                ctr[ps.edgeCells[i, 2]].f,
                velo,
                dt,
            )
        end
    end

    @inbounds Threads.@threads for i in eachindex(ctr)
        if ps.cellType[i] == 0
            for j in 1:3
                dirc = sign(dot(ctr[i].n[j], face[ps.cellEdges[i, j]].n))
                @. ctr[i].f -=
                    dirc * face[ps.cellEdges[i, j]].ff * face[ps.cellEdges[i, j]].len /
                    ps.cellArea[i]
            end

            #integral = KitBase.discrete_moments(ctr[i].f, vs.weights)
            #integral /= 4.0 * π
            #@. ctr[i].f += (integral - ctr[i].f) * dt

            ctr[i].w = sum(ctr[i].f .* vs.weights)
        end
    end
end

KitBase.write_vtk(ps, ctr)

@inbounds Threads.@threads for i in eachindex(face)
    velo = vs.u[:, 1] .* face[i].n[1] + vs.u[:, 2] .* face[i].n[2]
    if !(-1 in ps.edgeCells[i, :])
        KitBase.flux_kfvs!(
            face[i].ff,
            ctr[ps.edgeCells[i, 1]].f,
            ctr[ps.edgeCells[i, 2]].f,
            velo,
            dt,
        )
    end
end

@inbounds Threads.@threads for i in eachindex(ctr)
    if ps.cellType[i] == 0
        for j in 1:3
            dirc = sign(dot(ctr[i].n[j], face[ps.cellEdges[i, j]].n))
            @. ctr[i].f -=
                dirc * face[ps.cellEdges[i, j]].ff * face[ps.cellEdges[i, j]].len /
                ps.cellArea[i]
        end

        #integral = KitBase.discrete_moments(ctr[i].f, vs.weights)
        #integral /= 4.0 * π
        #@. ctr[i].f += (integral - ctr[i].f) * dt

        ctr[i].w = sum(ctr[i].f .* vs.weights)
    end
end
