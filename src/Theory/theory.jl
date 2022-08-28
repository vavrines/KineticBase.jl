# ============================================================
# Theories
# ============================================================

export heat_capacity_ratio, sound_speed
export prim_conserve, conserve_prim, mixture_prim_conserve, mixture_conserve_prim
export gauss_moments, mixture_gauss_moments, discrete_moments
export moments_conserve, diatomic_moments_conserve, mixture_moments_conserve, flux_conserve!
export pdf_slope, mixture_pdf_slope, moments_conserve_slope, mixture_moments_conserve_slope
export pressure, stress, heat_flux
export maxwellian, energy_maxwellian, maxwellian!, f_maxwellian
export mixture_maxwellian, mixture_energy_maxwellian, mixture_maxwellian!
export shakhov, shakhov!, rykov!
export reduce_distribution, full_distribution, shift_pdf!
export ref_vhs_vis, vhs_collision_time, rykov_zr
export aap_hs_collision_time, aap_hs_prim, aap_hs_diffeq!
export hs_boltz_kn, kernel_mode, fsm_kernel, boltzmann_fft, boltzmann_fft!
export boltzmann_ode!, bgk_ode!
export chapman_enskog

include("theory_macro.jl")
include("theory_flux.jl")
include("theory_plasma.jl")
include("theory_maxwellian.jl")
include("theory_shakhov.jl")
include("theory_diatomic.jl")
include("theory_pdf.jl")
include("theory_relaxation.jl")
include("theory_fsm.jl")
include("theory_moments.jl")
include("theory_particle.jl")
