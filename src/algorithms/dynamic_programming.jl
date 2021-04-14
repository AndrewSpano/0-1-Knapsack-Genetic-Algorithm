function build_config(A::Array{UInt32, 2}, take::BitArray{2}, weights::Array{UInt32, 1}, n_items::Int64, knapsack_capacity::UInt32)
    """ Builds the optimal solution using the results of the DP algorithm """
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


function dynamic_programming_knapsack(weights::Array{UInt32, 1}, values::Array{UInt32, 1}, knapsack_capacity::UInt32)
    """
    Finds an optimal solution to the 0-1 Knapsack problem using Dynamic Programming:

        OPT(n, w) = max(OPT(n-1, w - weights[w]), OPT(n-1, w))
    """
    n_items = size(weights, 1)
    A = zeros(UInt32, n_items + 1, knapsack_capacity + 1)
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


function run_dp(weights::Array{UInt32, 1}, values::Array{UInt32, 1}, knapsack_capacity::UInt32)
	""" runs the above function, while also returning the execution time """
    exe_time = @timed begin
        best_config = dynamic_programming_knapsack(weights, values, knapsack_capacity)
    end
    return best_config, exe_time.time
end
