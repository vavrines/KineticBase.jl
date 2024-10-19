"""
$(SIGNATURES)

Initialize Brio-Wu MHD shock tube
"""
function ib_briowu(
    set::AbstractSetup,
    ps::AbstractPhysicalSpace,
    vs::Union{AbstractVelocitySpace,Nothing},
    gas::AbstractProperty,
)

    # upstream
    primL = zeros(5, 2)
    primL[1, 1] = 1.0 * gas.mi
    primL[2, 1] = 0.0
    primL[3, 1] = 0.0
    primL[4, 1] = 0.0
    primL[5, 1] = gas.mi / 1.0
    primL[1, 2] = 1.0 * gas.me
    primL[2, 2] = 0.0
    primL[3, 2] = 0.0
    primL[4, 2] = 0.0
    primL[5, 2] = gas.me / 1.0

    wL = mixture_prim_conserve(primL, gas.γ)
    EL = zeros(3)
    BL = zeros(3)
    BL[1] = 0.75
    BL[2] = 1.0
    lorenzL = zeros(3, 2)

    # downstream
    primR = zeros(5, 2)
    primR[1, 1] = 0.125 * gas.mi
    primR[2, 1] = 0.0
    primR[3, 1] = 0.0
    primR[4, 1] = 0.0
    primR[5, 1] = gas.mi * 1.25
    primR[1, 2] = 0.125 * gas.me
    primR[2, 2] = 0.0
    primR[3, 2] = 0.0
    primR[4, 2] = 0.0
    primR[5, 2] = gas.me * 1.25

    wR = mixture_prim_conserve(primR, gas.γ)
    ER = zeros(3)
    BR = zeros(3)
    BR[1] = 0.75
    BR[2] = -1.0
    lorenzR = zeros(3, 2)

    p = (
        x0=ps.x0,
        x1=ps.x1,
        wL=wL,
        EL=EL,
        BL=BL,
        lorenzL=lorenzL,
        wR=wR,
        ER=ER,
        BR=BR,
        lorenzR=lorenzR,
    )

    fw = function (x, p)
        if x <= (p.x0 + p.x1) / 2
            return p.wL
        else
            return p.wR
        end
    end
    fE = function (x, p)
        if x <= (p.x0 + p.x1) / 2
            return p.EL
        else
            return p.ER
        end
    end
    fB = function (x, p)
        if x <= (p.x0 + p.x1) / 2
            return p.BL
        else
            return p.BR
        end
    end
    fL = function (x, p)
        if x <= (p.x0 + p.x1) / 2
            return p.lorenzL
        else
            return p.lorenzR
        end
    end

    bc = function (x, p)
        if x <= (p.x0 + p.x1) / 2
            return p.primL
        else
            return p.primR
        end
    end

    if set.space[3:end] == "4f1v"
        h0L = mixture_maxwellian(vs.u, primL)
        h1L = similar(h0L)
        h2L = similar(h0L)
        h3L = similar(h0L)
        for j in axes(h0L, 2)
            h1L[:, j] .= primL[3, j] .* h0L[:, j]
            h2L[:, j] .= primL[4, j] .* h0L[:, j]
            h3L[:, j] .=
                (primL[3, j]^2 + primL[4, j]^2 + 2.0 / (2.0 * primL[end, j])) .* h0L[:, j]
        end

        h0R = mixture_maxwellian(vs.u, primR)
        h1R = similar(h0R)
        h2R = similar(h0R)
        h3R = similar(h0R)
        for j in axes(h0L, 2)
            h1R[:, j] .= primR[3, j] .* h0R[:, j]
            h2R[:, j] .= primR[4, j] .* h0R[:, j]
            h3R[:, j] .=
                (primR[3, j]^2 + primR[4, j]^2 + 2.0 / (2.0 * primR[end, j])) .* h0R[:, j]
        end

        p = (p..., h0L=h0L, h1L=h1L, h2L=h2L, h3L=h3L, h0R=h0R, h1R=h1R, h2R=h2R, h3R=h3R)

        ff = function (x, p)
            if x <= (p.x0 + p.x1) / 2
                return p.h0L, p.h1L, p.h2L, p.h3L
            else
                return p.h0R, p.h1R, p.h2R, p.h3R
            end
        end

        return fw, ff, fE, fB, fL, bc, p
    elseif set.space[3:end] == "3f2v"
        h0L = mixture_maxwellian(vs.u, vs.v, primL)
        h1L = similar(h0L)
        h2L = similar(h0L)
        for j in axes(h0L, 3)
            h1L[:, :, j] .= primL[4, j] .* h0L[:, :, j]
            h2L[:, :, j] .= (primL[4, j]^2 + 1.0 / (2.0 * primL[end, j])) .* h0L[:, :, j]
        end

        h0R = mixture_maxwellian(vs.u, vs.v, primR)
        h1R = similar(h0R)
        h2R = similar(h0R)
        for j in axes(h0R, 3)
            h1R[:, :, j] .= primR[4, j] .* h0R[:, :, j]
            h2R[:, :, j] .= (primR[4, j]^2 + 1.0 / (2.0 * primR[end, j])) .* h0R[:, :, j]
        end

        p = (p..., h0L=h0L, h1L=h1L, h2L=h2L, h0R=h0R, h1R=h1R, h2R=h2R)

        ff = function (x, p)
            if x <= (p.x0 + p.x1) / 2
                return p.h0L, p.h1L, p.h2L
            else
                return p.h0R, p.h1R, p.h2R
            end
        end

        return fw, ff, fE, fB, fL, bc, p
    end

    return nothing
end

"""
$(SIGNATURES)
"""
function ib_briowu(gam, mi, me, uspace::AM)
    # upstream
    primL = zeros(5, 2)
    primL[1, 1] = 1.0 * mi
    primL[2, 1] = 0.0
    primL[3, 1] = 0.0
    primL[4, 1] = 0.0
    primL[5, 1] = mi / 1.0
    primL[1, 2] = 1.0 * me
    primL[2, 2] = 0.0
    primL[3, 2] = 0.0
    primL[4, 2] = 0.0
    primL[5, 2] = me / 1.0

    wL = mixture_prim_conserve(primL, gam)
    h0L = mixture_maxwellian(uspace, primL)

    h1L = similar(h0L)
    h2L = similar(h0L)
    h3L = similar(h0L)
    for j in axes(h0L, 2)
        h1L[:, j] .= primL[3, j] .* h0L[:, j]
        h2L[:, j] .= primL[4, j] .* h0L[:, j]
        h3L[:, j] .=
            (primL[3, j]^2 + primL[4, j]^2 + 2.0 / (2.0 * primL[end, j])) .* h0L[:, j]
    end

    EL = zeros(3)
    BL = zeros(3)
    BL[1] = 0.75
    BL[2] = 1.0

    # downstream
    primR = zeros(5, 2)
    primR[1, 1] = 0.125 * mi
    primR[2, 1] = 0.0
    primR[3, 1] = 0.0
    primR[4, 1] = 0.0
    primR[5, 1] = mi * 1.25
    primR[1, 2] = 0.125 * me
    primR[2, 2] = 0.0
    primR[3, 2] = 0.0
    primR[4, 2] = 0.0
    primR[5, 2] = me * 1.25

    wR = mixture_prim_conserve(primR, gam)
    h0R = mixture_maxwellian(uspace, primR)

    h1R = similar(h0R)
    h2R = similar(h0R)
    h3R = similar(h0R)
    for j in axes(h0L, 2)
        h1R[:, j] .= primR[3, j] .* h0R[:, j]
        h2R[:, j] .= primR[4, j] .* h0R[:, j]
        h3R[:, j] .=
            (primR[3, j]^2 + primR[4, j]^2 + 2.0 / (2.0 * primR[end, j])) .* h0R[:, j]
    end

    ER = zeros(3)
    BR = zeros(3)
    BR[1] = 0.75
    BR[2] = -1.0

    lorenzL = zeros(3, 2)
    lorenzR = zeros(3, 2)

    return wL,
    primL,
    h0L,
    h1L,
    h2L,
    h3L,
    EL,
    BL,
    lorenzL,
    wR,
    primR,
    h0R,
    h1R,
    h2R,
    h3R,
    ER,
    BR,
    lorenzR
end

"""
$(SIGNATURES)
"""
function ib_briowu(gam, mi, me, uspace::T, vspace::T) where {T<:AA3}
    # upstream
    primL = zeros(5, 2)
    primL[1, 1] = 1.0 * mi
    primL[2, 1] = 0.0
    primL[3, 1] = 0.0
    primL[4, 1] = 0.0
    primL[5, 1] = mi / 1.0
    primL[1, 2] = 1.0 * me
    primL[2, 2] = 0.0
    primL[3, 2] = 0.0
    primL[4, 2] = 0.0
    primL[5, 2] = me / 1.0

    wL = mixture_prim_conserve(primL, gam)
    h0L = mixture_maxwellian(uspace, vspace, primL)

    h1L = similar(h0L)
    h2L = similar(h0L)
    for j in axes(h0L, 3)
        h1L[:, :, j] .= primL[4, j] .* h0L[:, :, j]
        h2L[:, :, j] .= (primL[4, j]^2 + 1.0 / (2.0 * primL[end, j])) .* h0L[:, :, j]
    end

    EL = zeros(3)
    BL = zeros(3)
    BL[1] = 0.75
    BL[2] = 1.0

    # downstream
    primR = zeros(5, 2)
    primR[1, 1] = 0.125 * mi
    primR[2, 1] = 0.0
    primR[3, 1] = 0.0
    primR[4, 1] = 0.0
    primR[5, 1] = mi * 1.25
    primR[1, 2] = 0.125 * me
    primR[2, 2] = 0.0
    primR[3, 2] = 0.0
    primR[4, 2] = 0.0
    primR[5, 2] = me * 1.25

    wR = mixture_prim_conserve(primR, gam)
    h0R = mixture_maxwellian(uspace, vspace, primR)

    h1R = similar(h0R)
    h2R = similar(h0R)
    for j in axes(h0R, 3)
        h1R[:, :, j] .= primR[4, j] .* h0R[:, :, j]
        h2R[:, :, j] .= (primR[4, j]^2 + 1.0 / (2.0 * primR[end, j])) .* h0R[:, :, j]
    end

    ER = zeros(3)
    BR = zeros(3)
    BR[1] = 0.75
    BR[2] = -1.0

    lorenzL = zeros(3, 2)
    lorenzR = zeros(3, 2)

    return wL,
    primL,
    h0L,
    h1L,
    h2L,
    EL,
    BL,
    lorenzL,
    wR,
    primR,
    h0R,
    h1R,
    h2R,
    ER,
    BR,
    lorenzR
end
