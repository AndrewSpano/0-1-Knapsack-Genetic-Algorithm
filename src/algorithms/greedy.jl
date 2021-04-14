function greedy_knapsack(weights, values, knapsack_capacity)

    n_items = size(weights, 1)
    indices = collect(1 : n_items)
    greedy_config = falses(n_items)

    fraction(v_i_w_tuple) = first(v_i_w_tuple) / last(v_i_w_tuple)
    values_weights_sorted = sort(collect(zip(values, indices, weights)), by = fraction, rev = true)
    indices_sorted = getindex.(values_weights_sorted, 2)

    current_weight = 0
    for item = 1 : n_items
        next_item = indices_sorted[item]
        if current_weight + weights[next_item] <= knapsack_capacity
            greedy_config[next_item] = 1
            current_weight += weights[next_item]
        end
    end

    return greedy_config
end