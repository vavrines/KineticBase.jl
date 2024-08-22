# ============================================================
# Type Hierarchy
# ============================================================

export Setup, Config, config_ntuple
export Scalar, Radiation, Gas, DiatomicGas, Mixture, PolyatomicMixture, Plasma1D, Plasma2D
export IB, IB1F, IB2F, IB3F, IB4F
export ControlVolume, ControlVolume1F, ControlVolume2F
export ControlVolume1D, ControlVolume1D1F, ControlVolume1D2F
export ControlVolume1D3F, ControlVolume1D4F
export ControlVolume2D, ControlVolume2D1F, ControlVolume2D2F, ControlVolume2D3F
export ControlVolumeUS, ControlVolumeUS1F, ControlVolumeUS2F
export Interface, Interface1F, Interface2F
export Interface1D, Interface1D1F, Interface1D2F, Interface1D3F, Interface1D4F
export Interface2D, Interface2D1F, Interface2D2F
export Solution, Solution1F, Solution2F
export Solution1D, Solution2D
export Flux, Flux1F, Flux2F
export Flux1D, Flux2D

include("struct_abstract.jl")
include("struct_dispatch.jl")
include("struct_setup.jl")
include("struct_property.jl")
include("struct_ib.jl")
include("struct_ctr.jl")
include("struct_face.jl")
include("struct_sol.jl")
include("struct_flux.jl")
include("struct_ptc.jl")

function copy_ctr!(
    ctr::T,
    ctr0::T,
) where {T<:Union{ControlVolume,ControlVolume1D,ControlVolume2D,ControlVolumeUS}}
    ctr.w .= ctr0.w
    ctr.prim .= ctr0.prim
    ctr.sw .= ctr0.sw

    return nothing
end

function copy_ctr!(
    ctr::T,
    ctr0::T,
) where {T<:Union{ControlVolume1F,ControlVolume1D1F,ControlVolume2D1F,ControlVolumeUS1F}}
    ctr.w .= ctr0.w
    ctr.prim .= ctr0.prim
    ctr.sw .= ctr0.sw
    ctr.f .= ctr0.f

    return nothing
end

function copy_ctr!(
    ctr::T,
    ctr0::T,
) where {T<:Union{ControlVolume2F,ControlVolume1D2F,ControlVolume2D2F,ControlVolumeUS2F}}
    ctr.w .= ctr0.w
    ctr.prim .= ctr0.prim
    ctr.sw .= ctr0.sw
    ctr.h .= ctr0.h
    ctr.b .= ctr0.b

    return nothing
end

function copy_ctr!(ctr::T, ctr0::T) where {T<:Union{ControlVolume1D3F,ControlVolume2D3F}}
    ctr.w .= ctr0.w
    ctr.prim .= ctr0.prim
    ctr.sw .= ctr0.sw
    ctr.h0 .= ctr0.h0
    ctr.h1 .= ctr0.h1
    ctr.h2 .= ctr0.h2
    ctr.E .= ctr0.E
    ctr.B .= ctr0.B
    ctr.ϕ = ctr0.ϕ
    ctr.ψ = ctr0.ψ
    ctr.lorenz .= ctr0.lorenz

    return nothing
end

function copy_ctr!(ctr::T, ctr0::T) where {T<:ControlVolume1D4F}
    ctr.w .= ctr0.w
    ctr.prim .= ctr0.prim
    ctr.sw .= ctr0.sw
    ctr.h0 .= ctr0.h0
    ctr.h1 .= ctr0.h1
    ctr.h2 .= ctr0.h2
    ctr.h3 .= ctr0.h3
    ctr.E .= ctr0.E
    ctr.B .= ctr0.B
    ctr.ϕ = ctr0.ϕ
    ctr.ψ = ctr0.ψ
    ctr.lorenz .= ctr0.lorenz

    return nothing
end
