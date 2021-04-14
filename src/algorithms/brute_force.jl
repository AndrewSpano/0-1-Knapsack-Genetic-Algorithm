function brute_force_knapsack(weights::Array, values::Array, knapsack_capacity::Int64)
	#= finds am optimal solution to the 0-1 knapsack problem defined by the
		above parameters, using brute force =#

	num_items = size(weights, 1)
	best_config = 0
	best_value = 0
	m = 2 ^ num_items - 1

	for take = 1 : m
		config = digits(take, base = 2, pad = num_items)
		total_weight = sum(config .* weights)
		if total_weight > knapsack_capacity
			continue
		end
		total_value = sum(config .* values)
		if total_value > best_value
			best_config = take
			best_value = total_value
		end
	end

	return BitArray(digits(best_config, base = 2, pad = num_items))
end


function run_bf(weights::Array, values::Array, knapsack_capacity::Int64)
    #= used to run the brute force algorithm =#
    exe_time = @timed begin
        best_config = brute_force_knapsack(weights, values, knapsack_capacity)
    end
    
    return best_config, exe_time.time
end
