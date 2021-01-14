"""
Optimizer for the entropy closure problem
    
argmin(<η(α*m)> - α*u)

"""
function optimize_closure(α, m, ω, u, η::Function; optimizer=Newton())
    loss(_α) = sum(η.(_α' * m) .* ω) - dot(_α, u)
    res = Optim.optimize(loss, α, optimizer)

    return res
end

function realizable_reconstruct(α, m, ω, η_dual_prime::Function)
    u = zero(α)
    for i in eachindex(u)
        u[i] = sum(η_dual_prime.(α' * m) .* ω .* m[i, :])
    end

    return u
end