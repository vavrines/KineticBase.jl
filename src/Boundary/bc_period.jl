# ============================================================
# Period Functions
# ============================================================

"""
$(SIGNATURES)

Periodic boundary condition
"""
function bc_period!(ctr::AV, ng=1)
    nx = length(ctr) - 2 * ng

    for i in 1:ng
        copy_ctr!(ctr[1-i], ctr[nx+1-i])
        copy_ctr!(ctr[nx+i], ctr[i])
    end

    return nothing
end

"""
$(SIGNATURES)
"""
function bc_period!(ctr::AM, ng; dirc)
    if dirc == :x
        nx = size(ctr, 1) - 2 * ng
        for j in axes(ctr, 2), i in 1:ng
            copy_ctr!(ctr[1-i, j], ctr[nx-i+1, j])
        end
    elseif dirc == :y
        ny = size(ctr, 2) - 2 * ng
        for j in 1:ng, i in axes(ctr, 1)
            copy_ctr!(ctr[i, 1-j], ctr[i, ny-j+1])
        end
    end

    return nothing
end
