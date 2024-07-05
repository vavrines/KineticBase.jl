"""
$(SIGNATURES)

Generate array to store spatial slopes of solutions

## Arguments
* `w`: physical quantities
* `reduction`: reduction true -> 2D, false -> 3D
"""
slope_array(w::Number; kwargs...) = deepcopy(w)

"""
$(SIGNATURES)
"""
function slope_array(w::AA; reduction = true)
    nd = ndims(w)
    ids = []
    for i = 1:nd
        push!(ids, [axes(w, i) |> first, axes(w, i) |> last])
    end

    sw = ifelse(
        reduction == true,
        cat(zero(w), zero(w), dims = ndims(w) + 1),
        cat(zero(w), zero(w), zero(w), dims = ndims(w) + 1),
    )

    if w isa MArray
        sw = static_array(sw)
    end

    if w isa OffsetArray && typeof(w).types[1] <: MArray
        sw = static_array(sw)
        if ndims(sw) == 2
            sw = OffsetArray(sw, ids[1][1]:ids[1][2], axes(sw)[end])
        elseif ndims(sw) == 3
            sw = OffsetArray(sw, ids[1][1]:ids[1][2], ids[2][1]:ids[2][2], axes(sw)[end])
        elseif ndims(sw) == 4
            sw = OffsetArray(
                sw,
                ids[1][1]:ids[1][2],
                ids[2][1]:ids[2][2],
                ids[3][1]:ids[3][2],
                axes(sw)[end],
            )
        end
    end

    return sw
end


"""
$(SIGNATURES)

Extract subarray except the last column
"""
function extract_last(a::AA, idx::Integer; mode = :view::Symbol)
    if mode == :copy
        if ndims(a) == 2
            sw = a[:, idx]
        elseif ndims(a) == 3
            sw = a[:, :, idx]
        elseif ndims(a) == 4
            sw = a[:, :, :, idx]
        elseif ndims(a) == 5
            sw = a[:, :, :, :, idx]
        end
    elseif mode == :view
        if ndims(a) == 2
            sw = @view a[:, idx]
        elseif ndims(a) == 3
            sw = @view a[:, :, idx]
        elseif ndims(a) == 4
            sw = @view a[:, :, :, idx]
        elseif ndims(a) == 5
            sw = @view a[:, :, :, :, idx]
        end
    else
        throw("Error in extraction mode setup")
    end

    return sw
end
