using LinearAlgebra, ProgressMeter, JLD2
import KitBase

cd(@__DIR__)
D = KitBase.read_dict("naca_coarse.txt")
set = KitBase.set_setup(D)

ps = KitBase.set_geometry(D)
for i in eachindex(ps.cellType)
    if ps.cellType[i] == 1 &&
       -0.5 < ps.cellCenter[i, 1] < 1.5 &&
       -0.1 < ps.cellCenter[i, 2] < 0.1
        ps.cellType[i] = 2

        for j in 1:3
            if ps.faceType[ps.cellFaces[i, j]] == 1
                ps.faceType[ps.cellFaces[i, j]] = 2
            end
        end
    elseif ps.cellType[i] == 1 && ps.cellCenter[i, 1] > 0.5
        ps.cellType[i] = 3

        for j in 1:3
            if ps.faceType[ps.cellFaces[i, j]] == 1
                ps.faceType[ps.cellFaces[i, j]] = 3
            end
        end
    end
end

vs = KitBase.set_velocity(D)
gas = KitBase.set_property(D)
c0 = KitBase.sound_speed(1.0, gas.γ) * gas.Ma
α = π / 180 * 1.25
begin
    primL = [1.0, c0 * cos(α), c0 * sin(α), 1.0]
    wL = KitBase.prim_conserve(primL, gas.γ)
    hL = KitBase.maxwellian(vs.u, vs.v, primL)
    bL = @. hL * gas.K / 2 / primL[end]
    primR = [1.0, 0.0, 0.0, 1.0]
    wR = KitBase.prim_conserve(primR, gas.γ)
    hR = KitBase.maxwellian(vs.u, vs.v, primR)
    bR = @. hR * gas.K / 2 / primR[end]
    ib = KitBase.IB2F(wL, primL, hL, bL, primL, wL, primL, hL, bL, primR)
end

ks = KitBase.SolverSet(set, ps, vs, gas, ib, @__DIR__)
ctr, face = KitBase.init_fvm(ks, ks.ps)

dt = KitBase.timestep(ks, ctr, 0.0)
nt = ks.set.maxTime ÷ dt |> Int
@showprogress for iter in 1:200#nt
    KitBase.reconstruct!(ks, ctr)

    KitBase.evolve!(ks, ctr, face, dt; mode=:kfvs, bc=:maxwell)
    #=
    @inbounds Threads.@threads for i in eachindex(face)
        vn = ks.vs.u .* face[i].n[1] .+ ks.vs.v .* face[i].n[2]
        vt = ks.vs.v .* face[i].n[1] .- ks.vs.u .* face[i].n[2]

        if !(-1 in ps.faceCells[i, :])
            KitBase.flux_kfvs!(
                face[i].fw,
                face[i].fh,
                face[i].fb,
                ctr[ps.faceCells[i, 1]].h .+ ctr[ps.faceCells[i, 1]].sh[:, :, 1] .* (ps.faceCenter[i, 1] - ps.cellCenter[ps.faceCells[i, 1], 1]) .+ ctr[ps.faceCells[i, 1]].sh[:, :, 2] .* (ps.faceCenter[i, 2] - ps.cellCenter[ps.faceCells[i, 1], 2]),
                ctr[ps.faceCells[i, 1]].b .+ ctr[ps.faceCells[i, 1]].sb[:, :, 1] .* (ps.faceCenter[i, 1] - ps.cellCenter[ps.faceCells[i, 1], 1]) .+ ctr[ps.faceCells[i, 1]].sb[:, :, 2] .* (ps.faceCenter[i, 2] - ps.cellCenter[ps.faceCells[i, 1], 2]),
                ctr[ps.faceCells[i, 2]].h .+ ctr[ps.faceCells[i, 2]].sh[:, :, 1] .* (ps.faceCenter[i, 1] - ps.cellCenter[ps.faceCells[i, 2], 1]) .+ ctr[ps.faceCells[i, 2]].sh[:, :, 2] .* (ps.faceCenter[i, 2] - ps.cellCenter[ps.faceCells[i, 2], 2]),
                ctr[ps.faceCells[i, 2]].b .+ ctr[ps.faceCells[i, 2]].sb[:, :, 1] .* (ps.faceCenter[i, 1] - ps.cellCenter[ps.faceCells[i, 2], 1]) .+ ctr[ps.faceCells[i, 2]].sb[:, :, 2] .* (ps.faceCenter[i, 2] - ps.cellCenter[ps.faceCells[i, 2], 2]),
                vn,
                vt,
                ks.vs.weights,
                dt,
                face[i].len,
            )
            face[i].fw .= KitBase.global_frame(face[i].fw, face[i].n[1], face[i].n[2])
        else
            idx = ifelse(ps.faceCells[i, 1] != -1, 1, 2)

            if ps.cellType[ps.faceCells[i, idx]] == 2
                bc = KitBase.local_frame(ks.ib.bcR, face[i].n[1], face[i].n[2])

                KitBase.flux_boundary_maxwell!(
                    face[i].fw,
                    face[i].fh,
                    face[i].fb,
                    bc,
                    ctr[ps.faceCells[i, idx]].h .+ ctr[ps.faceCells[i, idx]].sh[:, :, 1] .* (ps.faceCenter[i, 1] - ps.cellCenter[ps.faceCells[i, idx], 1]) .+ ctr[ps.faceCells[i, idx]].sh[:, :, 2] .* (ps.faceCenter[i, 2] - ps.cellCenter[ps.faceCells[i, idx], 2]),
                    ctr[ps.faceCells[i, idx]].b .+ ctr[ps.faceCells[i, idx]].sb[:, :, 1] .* (ps.faceCenter[i, 1] - ps.cellCenter[ps.faceCells[i, idx], 1]) .+ ctr[ps.faceCells[i, idx]].sb[:, :, 2] .* (ps.faceCenter[i, 2] - ps.cellCenter[ps.faceCells[i, idx], 2]),
                    vn,
                    vt,
                    ks.vs.weights,
                    ks.gas.K,
                    dt,
                    face[i].len,
                )

                face[i].fw .= KitBase.global_frame(face[i].fw, face[i].n[1], face[i].n[2])
            end
        end
    end=#

    res = zeros(4)
    KitBase.update!(ks, ctr, face, dt, res; coll=:bgk, bc=:maxwell)
    #=
    sumres = zeros(4)
    sumavg = zeros(4)
    @inbounds Threads.@threads for i in eachindex(ctr)
        if ps.cellType[i] in (0, 2)
            dirc = [sign(dot(ctr[i].n[j], face[ps.cellFaces[i, j]].n)) for j = 1:3]

            KitBase.step!(
                ctr[i].w,
                ctr[i].prim,
                ctr[i].h,
                ctr[i].b,
                face[ps.cellFaces[i, 1]].fw,
                face[ps.cellFaces[i, 1]].fh,
                face[ps.cellFaces[i, 1]].fb,
                face[ps.cellFaces[i, 2]].fw,
                face[ps.cellFaces[i, 2]].fh,
                face[ps.cellFaces[i, 2]].fb,
                face[ps.cellFaces[i, 3]].fw,
                face[ps.cellFaces[i, 3]].fh,
                face[ps.cellFaces[i, 3]].fb,
                ks.vs.u,
                ks.vs.v,
                ks.vs.weights,
                ks.gas.K,
                ks.gas.γ,
                ks.gas.μᵣ,
                ks.gas.ω,
                ks.gas.Pr,
                ks.ps.cellArea[i],
                dirc,
                dt,
                sumres,
                sumavg,
                :bgk,
            )
        end
    end

    for i in eachindex(ps.cellType)
        if ps.cellType[i] == 3
            ids = ps.cellNeighbors[i, :]
            deleteat!(ids, findall(x->x==-1, ids))
            id1, id2 = ids
            ctr[i].w .= 0.5 .* (ctr[id1].w .+ ctr[id2].w)
            ctr[i].h .= 0.5 .* (ctr[id1].h .+ ctr[id2].h)
            ctr[i].b .= 0.5 .* (ctr[id1].b .+ ctr[id2].b)
            ctr[i].prim .= KitBase.conserve_prim(ctr[i].w, ks.gas.γ)
        end
    end
    res = sqrt.(length(ctr) .* sumres) ./ (sumavg .+ 1e-6)=#

    if iter % 1000 == 0
        println(res)
        @save "ctr.jld2" ctr
        KitBase.write_vtk(ks, ctr)
    end
end

KitBase.write_vtk(ks, ctr)
