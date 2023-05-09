#--- continuum ---#
prim = [1.0, 0.0, 1.0]
KitBase.prim_conserve(prim, 3.0)
KitBase.prim_conserve(prim[1], prim[2], prim[3], 3.0)

mprim = hcat(prim, prim)
KitBase.mixture_prim_conserve(mprim, 3.0)

KitBase.conserve_prim(prim[1])
KitBase.conserve_prim(prim[1], 1.0)
KitBase.conserve_prim(prim, 3.0)
KitBase.conserve_prim(prim[1], prim[2], prim[3], 3.0)
KitBase.mixture_conserve_prim(mprim, 3.0)

# Rykov
KitBase.prim_conserve([1.0, 0.0, 1.0, 1.0, 1.0], 5 / 3, 2)
KitBase.prim_conserve([1.0, 0.0, 0.0, 1.0, 1.0, 1.0], 5 / 3, 2)
KitBase.conserve_prim([1.0, 0.0, 1.0, 0.1], 5 / 3, 2)
KitBase.conserve_prim([1.0, 0.0, 0.0, 1.0, 0.1], 5 / 3, 2)

prim = [1.0, 0.2, 0.3, -0.1, 1.0]
mprim = hcat(prim, prim)
KitBase.em_coefficients(mprim, randn(3), randn(3), 100, 0.01, 0.01, 0.001)

KitBase.advection_flux(1.0, -0.1)
KitBase.burgers_flux(1.0)
KitBase.euler_flux(prim, 3.0)
KitBase.euler_jacobi(prim, 3.0)

#--- thermo ---#
KitBase.heat_capacity_ratio(2.0, 1)
KitBase.heat_capacity_ratio(2.0, 2)
KitBase.heat_capacity_ratio(2.0, 3)
KitBase.heat_capacity_ratio(2.0, 2, 1)
KitBase.heat_capacity_ratio(2.0, 2, 2)
KitBase.heat_capacity_ratio(2.0, 2, 3)

KitBase.sound_speed(1.0, 5 / 3)
KitBase.sound_speed([1.0, 0.0, 1.0], 5 / 3)
KitBase.sound_speed(rand(3, 2), 5 / 3)

#--- atom ---#
KitBase.pdf_slope(1.0, 0.1)
KitBase.pdf_slope(prim, randn(5), 0.0)
KitBase.mixture_pdf_slope(mprim, randn(5, 2), 0.0)

u = collect(-5:0.2:5)
ω = ones(51) .* 0.2
prim = [1.0, 0.0, 1.0]

M = KitBase.maxwellian(u, prim)
KitBase.maxwellian(randn(16, 16), randn(16, 16), [1.0, 0.0, 0.0, 1.0])
KitBase.maxwellian(
    randn(8, 8, 8),
    randn(8, 8, 8),
    randn(8, 8, 8),
    [1.0, 0.0, 0.0, 0.0, 1.0],
)

KitBase.energy_maxwellian(M, prim, 2)
KitBase.mixture_energy_maxwellian(hcat(M, M), hcat(prim, prim), 2)
KitBase.mixture_energy_maxwellian(rand(16, 16, 2), hcat(prim, prim), 2)

KitBase.maxwellian!(rand(16), rand(16), prim)
KitBase.maxwellian!(rand(16, 16), randn(16, 16), randn(16, 16), [1.0, 0.0, 0.0, 1.0])
KitBase.maxwellian!(
    rand(8, 8, 8),
    randn(8, 8, 8),
    randn(8, 8, 8),
    randn(8, 8, 8),
    [1.0, 0.0, 0.0, 0.0, 1.0],
)

mprim = hcat(prim, prim)
KitBase.mixture_maxwellian(hcat(u, u), mprim)
KitBase.mixture_maxwellian(randn(8, 8, 2), randn(8, 8, 2), rand(4, 2))
KitBase.mixture_maxwellian(
    randn(8, 8, 8, 2),
    randn(8, 8, 8, 2),
    randn(8, 8, 8, 2),
    rand(5, 2),
)

KitBase.mixture_maxwellian!(randn(8, 2), randn(8, 2), rand(3, 2))
KitBase.mixture_maxwellian!(randn(8, 8, 2), randn(8, 8, 2), randn(8, 8, 2), rand(4, 2))
KitBase.mixture_maxwellian!(
    randn(8, 8, 8, 2),
    randn(8, 8, 8, 2),
    randn(8, 8, 8, 2),
    randn(8, 8, 8, 2),
    rand(5, 2),
)

KitBase.shakhov(u, M, 0.01, prim, 1.0)
KitBase.shakhov(u, M, M, 0.01, prim, 1.0, 2.0)
KitBase.shakhov(randn(16, 16), randn(16, 16), rand(16, 16), rand(2), [1.0, 0.0, 1.0], 1.0)
KitBase.shakhov(
    randn(16, 16),
    randn(16, 16),
    rand(16, 16),
    rand(16, 16),
    rand(2),
    [1.0, 0.0, 0.0, 1.0],
    1.0,
    1.0,
)
KitBase.shakhov(
    randn(8, 8, 8),
    randn(8, 8, 8),
    rand(8, 8, 8),
    rand(8, 8, 8),
    rand(3),
    [1.0, 0.0, 0.0, 0.0, 1.0],
    1.0,
)

KitBase.shakhov!(randn(16), randn(16), rand(16), 0.01, prim, 1.0)
KitBase.shakhov!(randn(16), randn(16), randn(16), rand(16), rand(16), 0.01, prim, 1.0, 2.0)
KitBase.shakhov!(
    randn(16, 16),
    randn(16, 16),
    randn(16, 16),
    rand(16, 16),
    rand(2),
    [1.0, 0.0, 1.0],
    1.0,
)
KitBase.shakhov!(
    randn(16, 16),
    randn(16, 16),
    randn(16, 16),
    randn(16, 16),
    rand(16, 16),
    rand(16, 16),
    rand(2),
    [1.0, 0.0, 0.0, 1.0],
    1.0,
    1.0,
)
KitBase.shakhov!(
    randn(8, 8, 8),
    randn(8, 8, 8),
    randn(8, 8, 8),
    rand(8, 8, 8),
    rand(8, 8, 8),
    rand(3),
    [1.0, 0.0, 0.0, 0.0, 1.0],
    1.0,
)

# ES-BGK
vs = VSpace1D()
prim = [1.0, 0, 1]
f = maxwellian(vs.u, prim)
KitBase.esbgk_ode!(zero(f), f, (vs.u, vs.weights, prim, 2 / 3, 1), 0.0)

vs = VSpace2D()
prim = [1.0, 0, 0, 1]
f = maxwellian(vs.u, vs.v, prim)
KitBase.esbgk_ode!(zero(f), f, (vs.u, vs.v, vs.weights, prim, 2 / 3, 1), 0.0)

vs = VSpace3D()
prim = [1.0, 0, 0, 0, 1]
f = maxwellian(vs.u, vs.v, vs.w, prim)
KitBase.esbgk_ode!(zero(f), f, (vs.u, vs.v, vs.w, vs.weights, prim, 2 / 3, 1), 0.0)

# Rykov
KitBase.polyatomic_maxwellian!(
    zeros(16),
    zeros(16),
    zeros(16),
    zeros(16),
    zeros(16),
    zeros(16),
    randn(16),
    rand(5),
    4,
    2,
)
KitBase.polyatomic_maxwellian!(
    zeros(8, 8),
    zeros(8, 8),
    zeros(8, 8),
    zeros(8, 8),
    zeros(8, 8),
    zeros(8, 8),
    randn(8, 8),
    randn(8, 8),
    rand(6),
    4,
    2,
)

KitBase.rykov!(
    zeros(16),
    zeros(16),
    zeros(16),
    zeros(16),
    zeros(16),
    zeros(16),
    randn(16),
    rand(16),
    rand(16),
    rand(16),
    rand(16),
    rand(16),
    rand(16),
    rand(2),
    rand(5),
    0.72,
    4,
    1 / 1.55,
    0.2354,
    0.3049,
)
KitBase.rykov!(
    zeros(8, 8),
    zeros(8, 8),
    zeros(8, 8),
    zeros(8, 8),
    zeros(8, 8),
    zeros(8, 8),
    randn(8, 8),
    randn(8, 8),
    rand(8, 8),
    rand(8, 8),
    rand(8, 8),
    rand(8, 8),
    rand(8, 8),
    rand(8, 8),
    rand(4),
    rand(6),
    0.72,
    4,
    1 / 1.55,
    0.2354,
    0.3049,
)

# BIP
KitBase.polyatomic_maxwellian!(
    zeros(16),
    zeros(16),
    zeros(16),
    randn(16),
    rand(5),
    2,
    2,
)
KitBase.polyatomic_maxwellian!(
    zeros(16),
    zeros(16),
    zeros(16),
    randn(16),
    randn(16),
    rand(6),
    1,
    2,
)
KitBase.polyatomic_maxwellian!(
    zeros(16),
    zeros(16),
    zeros(16),
    randn(16),
    randn(16),
    randn(16),
    rand(7),
    1,
    2,
)

KitBase.f_maxwellian(rand(16, 2))
KitBase.f_maxwellian(rand(16, 2), rand(16, 2))

KitBase.reduce_distribution(randn(16, 51), ω, 1)
KitBase.reduce_distribution(randn(16, 24, 24), ones(24, 24), 1)
KitBase.reduce_distribution(
    randn(16, 24, 24),
    randn(16, 24, 24),
    randn(16, 24, 24),
    ones(24, 24),
    1,
)
KitBase.full_distribution(M, M, u, ω, ones(51, 24, 24), ones(51, 24, 24), 1.0, 3.0)
KitBase.full_distribution(M, M, u, ω, ones(51, 24, 24), ones(51, 24, 24), prim, 3.0)

KitBase.ref_vhs_vis(1.0, 1.0, 0.5)
KitBase.vhs_collision_time(prim, 1e-3, 0.81)

KitBase.νbgk_relaxation_time(0.1, 1, rand(3), Class{1})
KitBase.νbgk_relaxation_time(0.1, 1, rand(3), Class{2})
KitBase.νbgk_relaxation_time(0.1, 1, 1, rand(4), Class{3})
KitBase.νbgk_relaxation_time(0.1, 1, 1, 1, rand(5), Class{4})

KitBase.νshakhov_relaxation_time(0.1, 1, rand(3))

KitBase.rykov_zr(100, 91.5, 18.1)

KitBase.hs_boltz_kn(1e-3, 1.0)
vs = VSpace3D(-5, 5, 16, -5, 5, 16, -5, 5, 16)
fsm = KitBase.fsm_kernel(vs, 1e-3)
phi, psi, phipsi =
    KitBase.kernel_mode(5, 5.0, 5.0, 5.0, 0.1, 0.1, 0.1, 16, 16, 16, 1.0, quad_num = 16)
KitBase.kernel_mode(5, 5.0, 5.0, 5.0, 16, 16, 16, 1.0, quad_num = 16)
KitBase.kernel_mode(5, 5.0, 5.0, 0.1, 0.1, 16, 16, quad_num = 16)
KitBase.boltzmann_fft(rand(16, 16, 16), fsm)
KitBase.boltzmann_fft!(rand(16, 16, 16), rand(16, 16, 16), fsm)

KitBase.boltzmann_ode!(zeros(16, 16, 16), rand(16, 16, 16), (1.0, 5, phi, psi, phipsi), 0.0)
KitBase.bgk_ode!(zeros(16, 16, 16), rand(16, 16, 16), (rand(16, 16, 16), 1e-2), 0.0)

vs = KitBase.VSpace3D(-5.0, 5.0, 16, -5.0, 5.0, 16, -5.0, 5.0, 16, type = "algebra")
u, v, w = vs.u[:, 1, 1], vs.v[1, :, 1], vs.w[1, 1, :]
vnu = hcat(vs.u[:], vs.v[:], vs.w[:])
uuni1d = linspace(vs.u[1, 1, 1], vs.u[end, 1, 1], 16)
vuni1d = linspace(vs.v[1, 1, 1], vs.v[1, end, 1], 16)
wuni1d = linspace(vs.w[1, 1, 1], vs.w[1, 1, end], 16)
u13d = [uuni1d[i] for i = 1:16, j = 1:16, k = 1:16]
v13d = [vuni1d[j] for i = 1:16, j = 1:16, k = 1:16]
w13d = [wuni1d[k] for i = 1:16, j = 1:16, k = 1:16]
vuni = hcat(u13d[:], v13d[:], w13d[:])
KitBase.boltzmann_nuode!(
    zeros(16, 16, 16),
    rand(16, 16, 16),
    (5.0, 5, phi, psi, phipsi, u, v, w, vnu, uuni1d, vuni1d, wuni1d, vuni),
    0.0,
)

τ = KitBase.aap_hs_collision_time(mprim, 1.0, 0.5, 0.5, 0.5, 1.0)
KitBase.aap_hs_prim(mprim, τ, 1.0, 0.5, 0.5, 0.5, 1.0)
KitBase.aap_hs_prim(rand(4, 2), rand(2), 1.0, 0.5, 0.5, 0.5, 1e-2)
KitBase.aap_hs_prim(rand(5, 2), rand(2), 1.0, 0.5, 0.5, 0.5, 1e-2)

KitBase.aap_hs_diffeq!(
    similar(mprim),
    mprim,
    [τ[1], τ[2], 1.0, 0.5, 0.5, 0.5, 1.0, 3.0],
    0.0,
)
KitBase.shift_pdf!(M, 1.0, 1e-4, 1e-4)
KitBase.shift_pdf!(rand(16, 2), randn(2), rand(2), 1e-4)

KitBase.chapman_enskog(rand(16), [1.0, 0.0, 1.0], rand(3), rand(3), 0.1)
KitBase.chapman_enskog(rand(16), [1.0, 0.0, 1.0], zeros(3), 0, 0.1)
KitBase.chapman_enskog(
    rand(16, 16),
    rand(16, 16),
    [1.0, 0.0, 0.0, 1.0],
    rand(4),
    rand(4),
    rand(4),
    0.1,
)
KitBase.chapman_enskog(
    rand(16, 16),
    rand(16, 16),
    [1.0, 0.0, 0.0, 1.0],
    zeros(4),
    zeros(4),
    0.0,
    0.1,
)
KitBase.chapman_enskog(
    rand(16, 16, 16),
    rand(16, 16, 16),
    rand(16, 16, 16),
    [1.0, 0.0, 0.0, 0.0, 1.0],
    rand(5),
    rand(5),
    rand(5),
    rand(5),
    0.1,
)
KitBase.chapman_enskog(
    rand(16, 16, 16),
    rand(16, 16, 16),
    rand(16, 16, 16),
    [1.0, 0.0, 0.0, 0.0, 1.0],
    zeros(5),
    zeros(5),
    zeros(5),
    0.0,
    0.1,
)

vs = KitBase.VSpace1D()
KitBase.collision_invariant(rand(3), vs)
KitBase.collision_invariant(rand(3, 2), vs)
vs2 = KitBase.VSpace2D()
KitBase.collision_invariant(rand(4), vs2)
vs3 = KitBase.VSpace3D()
KitBase.collision_invariant(rand(5), vs3)

#--- quantum ---#
f0 = 0.5 * (1 / π)^0.5 .* (exp.(-(vs.u .- 0.99) .^ 2) .+ exp.(-(vs.u .+ 0.99) .^ 2))
w0 = moments_conserve(f0, vs.u, vs.weights)
prim0 = quantum_conserve_prim(w0, 2, :fd)
quantum_prim_conserve(prim0, 2, :fd)
prim0 = quantum_conserve_prim(w0, 2, :be)
quantum_prim_conserve(prim0, 2, :be)

f0 =
    0.5 * (1 / π)^0.5 .* (exp.(-(vs2.u .- 0.99) .^ 2) .+ exp.(-(vs2.u .+ 0.99) .^ 2)) .*
    exp.(-vs2.v .^ 2)
w0 = moments_conserve(f0, vs2.u, vs2.v, vs2.weights)
prim0 = quantum_conserve_prim(w0, 2, :fd)
quantum_prim_conserve(prim0, 2, :fd)
prim0 = quantum_conserve_prim(w0, 2, :be)
quantum_prim_conserve(prim0, 2, :be)
