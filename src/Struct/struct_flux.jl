# ============================================================
# Structs of Interface Fluxes
# compatible with solution structs
# ============================================================

struct Flux{T1,T2,ND} <: AbstractFlux
    n::T1
    w::T2
    fw::T2
end

struct Flux1F{T1,T2,T3,ND} <: AbstractFlux
    n::T1
    w::T2
    fw::T2
    ff::T3
end

struct Flux2F{T1,T2,T3,ND} <: AbstractFlux
    n::T1
    w::T2
    fw::T2
    fh::T3
    fb::T3
end

function Flux1D(fw::AA)
    n = ones(axes(fw)[end])
    w = deepcopy(fw)
    if w[1] isa Number
        w .= 0.0
    else
        for e in w
            e .= 0.0
        end
    end

    return Flux{typeof(n),typeof(w),1}(n, w, fw)
end

function Flux1D(fw::AA, ff::AA)
    n = ones(axes(fw)[end])
    w = deepcopy(fw)
    if w[1] isa Number
        w .= 0.0
    else
        for e in w
            e .= 0.0
        end
    end

    return Flux1F{typeof(n),typeof(w),typeof(ff),1}(n, w, fw, ff)
end

function Flux1D(fw::AA, fh::AA, fb::AA)
    n = ones(axes(fw)[end])
    w = deepcopy(fw)
    if w[1] isa Number
        w .= 0.0
    else
        for e in w
            e .= 0.0
        end
    end

    return Flux2F{typeof(n),typeof(w),typeof(fh),1}(n, w, fw, fh, fb)
end

function Flux2D(n::AA, fw::AA)
    w = deepcopy(fw)
    if w[1] isa Number
        w .= 0.0
    else
        for e in w
            e .= 0.0
        end
    end

    return Flux{typeof(n),typeof(w),2}(n, w, fw)
end

function Flux2D(n::AA, fw::AA, ff::AA)
    w = deepcopy(fw)
    if w[1] isa Number
        w .= 0.0
    else
        for e in w
            e .= 0.0
        end
    end

    return Flux1F{typeof(n),typeof(w),typeof(ff),2}(n, w, fw, ff)
end

function Flux2D(n::AA, fw::AA, fh::AA, fb::AA)
    w = deepcopy(fw)
    if w[1] isa Number
        w .= 0.0
    else
        for e in w
            e .= 0.0
        end
    end

    return Flux2F{typeof(n),typeof(w),typeof(fh),2}(n, w, fw, fh, fb)
end
