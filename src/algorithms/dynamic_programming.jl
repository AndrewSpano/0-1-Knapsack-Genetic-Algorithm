function build_config(A, take, weights, n_items, knapsack_capacity)

    best_config = falses(n_items)
    weight = knapsack_capacity

    for item = n_items : -1 : 1
        if take[item + 1, weight + 1] == 1
            best_config[item] = 1
            weight -= weights[item]
        end
    end

    return best_config
end


function dynamic_programming_knapsack(weights, values, knapsack_capacity)

    n_items = size(weights, 1)
    A = zeros(Int64, n_items + 1, knapsack_capacity + 1)
    take = falses(n_items + 1, knapsack_capacity + 1)

    for item = 2 : n_items + 1
        for weight = 2 : knapsack_capacity + 1
            if weights[item - 1] < weight
                if values[item - 1] + A[item - 1, weight - weights[item - 1]] > A[item - 1, weight]
                    A[item, weight] = values[item - 1] + A[item - 1, weight - weights[item - 1]]
                    take[item, weight] = 1
                else
                    A[item, weight] = A[item - 1, weight]
                end
            else
                A[item, weight] = A[item - 1, weight]
            end
        end
    end

    return build_config(A, take, weights, n_items, knapsack_capacity)
end