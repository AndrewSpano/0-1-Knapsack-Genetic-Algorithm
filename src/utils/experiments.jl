include("../algorithms/brute_force.jl")
include("../algorithms/greedy.jl")
include("../algorithms/dynamic_programming.jl")
include("../algorithms/genetic.jl")
include("plot_results.jl")


function bf_experiment(benchmark_W::UInt32, min_items::Int64, max_items::Int64, log_results::Bool = false, plot_results::Bool = true)
    """ Performs an experiment for the brute force algorithm, just to show it's slowness. """

    runtimes = []

    for n_items = min_items : max_items

        knapsack_capacity = UInt32(benchmark_W * n_items)
        max_weight = benchmark_W * n_items / 2
        max_value = benchmark_W

        weights = Array{UInt32}(rand(1:max_weight, n_items))
        values = Array{UInt32}(rand(1:max_value, n_items))
        best_config, exe_time = run_bf(weights, values, knapsack_capacity)

        if log_results
            Printf.println("For n = ", n_items, ", time taken was: ", exe_time, "s.")
        end

        push!(runtimes, exe_time)
    end

    if plot_results
        plot_bf(runtimes)
    end

    return runtimes
end


function score_accuracy(target, output)
    return 1 - abs(target - output) / target
end


function solution_accuracy(targets, outputs)
    return sum(targets .== outputs) / size(targets, 1)
end


function greedy_dp_genetic_experiment(benchmark_W::UInt32, min_items::Int64, max_items::Int64, iter_per_n::Int64, log_results::Bool = false, plot_results::Bool = true)
    """ Performs an experiment for the Genetic Algorithm. It compares it's results and runtime with DP and greedy """

    # metrics to be returned
    greedy_average_runtimes = []
    greedy_average_score_accuracies = []
    greedy_average_solution_accuracies = []
    dp_average_runtimes = []
    genetic_average_runtimes = []
    genetic_average_score_accuracies = []
    genetic_average_solution_accuracies = []

    # for every number of items in the range
    for n_items = min_items : max_items

        # define the values of the experiment
        knapsack_capacity = UInt32(benchmark_W * n_items)
        max_weight = UInt32(benchmark_W * n_items / 2)
        max_value = benchmark_W

        # initialize sums
        greedy_sum_runtimes = 0.0
        greedy_sum_score_accuracy = 0.0
        greedy_sum_solution_accuracy = 0.0
        dp_sum_runtimes = 0.0
        genetic_sum_runtimes = 0.0
        genetic_sum_score_accuracy = 0.0
        genetic_sum_solution_accuracy = 0.0

        # perform "iter_per_n" experiments for the above values
        for _ = 1 : iter_per_n

            # compute random weights and values
            weights = Array{UInt32}(rand(1:max_weight, n_items))
            values = Array{UInt32}(rand(1:max_value, n_items))

            # run the algorithms
            greedy_config, greedy_runtime = run_greedy(weights, values, knapsack_capacity)
            best_config, dp_runtime = run_dp(weights, values, knapsack_capacity)
            genetic_config, genetic_runtime = run_genetic(weights, values, knapsack_capacity)

            # compute their scores
            greedy_score = sum(greedy_config .* values)
            dp_score = sum(best_config .* values)
            genetic_score = sum(genetic_config .* values)

            # update values
            greedy_sum_runtimes += greedy_runtime
            greedy_sum_score_accuracy += score_accuracy(dp_score, greedy_score)
            greedy_sum_solution_accuracy += solution_accuracy(best_config, greedy_config)
            dp_sum_runtimes += dp_runtime
            genetic_sum_runtimes += genetic_runtime
            genetic_sum_score_accuracy += score_accuracy(dp_score, genetic_score)
            genetic_sum_solution_accuracy += solution_accuracy(best_config, genetic_config)

        end
        
        # push them in the arrays
        push!(greedy_average_runtimes, greedy_sum_runtimes / iter_per_n)
        push!(greedy_average_score_accuracies, greedy_sum_score_accuracy / iter_per_n)
        push!(greedy_average_solution_accuracies, greedy_sum_solution_accuracy / iter_per_n)
        push!(dp_average_runtimes, dp_sum_runtimes / iter_per_n)
        push!(genetic_average_runtimes, genetic_sum_runtimes / iter_per_n)
        push!(genetic_average_score_accuracies, genetic_sum_score_accuracy / iter_per_n)
        push!(genetic_average_solution_accuracies, genetic_sum_solution_accuracy / iter_per_n)

        if log_results
            Printf.println("For n = ", n_items, ":")
            Printf.println("\taverage Greedy runtime: ", greedy_sum_runtimes / iter_per_n, "s.")
            Printf.println("\taverage Greedy Score Accuracy: ", greedy_sum_score_accuracy / iter_per_n)
            Printf.println("\taverage Greedy Solution Accuracy: ", greedy_sum_solution_accuracy / iter_per_n)
            Printf.println("\taverage DP runtime: ", dp_sum_runtimes / iter_per_n, "s.")
            Printf.println("\taverage Genetic runtime: ", genetic_sum_runtimes / iter_per_n, "s.")
            Printf.println("\taverage Genetic Score Accuracy: ", genetic_sum_score_accuracy / iter_per_n)
            Printf.println("\taverage Genetic Solution Accuracy: ", genetic_sum_solution_accuracy / iter_per_n)
            Printf.println()
        end

    end

    if plot_results
        plot_dp_vs_genetic(
            greedy_average_runtimes,
            greedy_average_score_accuracies,
            greedy_average_solution_accuracies,
            dp_average_runtimes,
            genetic_average_runtimes,
            genetic_average_score_accuracies,
            genetic_average_solution_accuracies
        )
    end

    return dp_average_runtimes, genetic_average_runtimes, genetic_average_score_accuracies, genetic_average_solution_accuracies
end



function genetic_score_comparison(benchmark_W::UInt32, n_items::Int64, population_size::Int64, plot_filepath::String)
    """ Performs an experiment for the Genetic Algorithm in order to find good hyperparameters """

    # define the values of the experiment
    knapsack_capacity = UInt32(benchmark_W * n_items)
    max_weight = UInt32(benchmark_W * n_items * 2)
    max_value = benchmark_W

    # compute random weights and values
    weights = Array{UInt32}(rand(1:max_weight, n_items))
    values = Array{UInt32}(rand(1:max_value, n_items))

    # run the algorithms
    greedy_config = greedy_knapsack(weights, values, knapsack_capacity)
    greedy_score = sum(greedy_config .* values)
    dp_config = dynamic_programming_knapsack(weights, values, knapsack_capacity)
    dp_score = sum(dp_config .* values)

    genetic_knapsack(weights, values, knapsack_capacity, population_size = population_size, init_zeros = true, max_generations = 1000,
                     patience = 25, plot_best_fitness_per_generation = true, optimal_fitness = dp_score, greedy_fitness = greedy_score,
                     plot_filepath = plot_filepath)
end