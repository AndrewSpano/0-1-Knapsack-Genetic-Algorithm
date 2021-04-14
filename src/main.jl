include("algorithms/brute_force.jl")
include("algorithms/greedy.jl")
include("algorithms/dynamic_programming.jl")
include("algorithms/genetic.jl")

import Printf
import Random


function main()

    # fix the random seed
    PANATHA = 13
    Random.seed!(PANATHA)

    # random example
    weights = rand(1:15, 10)
    values = rand(1:15, 10)
    W = 50

    bf_solution, bf_runtime = run_bf(weights, values, W)
    println(bf_solution)

    greedy_solution, greedy_runtime = run_greedy(weights, values, W)
    println(greedy_solution)

    dp_solution, dp_runtime = run_dp(weights, values, W)
    println(dp_solution)

    genetic_solution, genetic_runtime = run_genetic(weights, values, W)
    println(genetic_solution)

    bf_score = sum(bf_solution .* values)
    greedy_score = sum(greedy_solution .* values)
    dp_score = sum(dp_solution .* values)
    genetic_score = sum(genetic_solution .* values)
    println("BF score vs Greedy score vs DP score vs Genetic score: ", bf_score, " vs ", greedy_score, " vs ", dp_score, " vs ", genetic_score)

end



# guard so that main() is executed only when script is run, not when imported
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
