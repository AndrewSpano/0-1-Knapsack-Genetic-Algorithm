include("utils/experiments.jl")

import Printf
import Random


function main()

    # fix the random seed
    PANATHA = 13
    Random.seed!(PANATHA)

    # run the brute force algorithm just to get a feel of how slow it is
    W = 10000
    min_items = 1
    max_items = 30
    bf_experiment(W, min_items, max_items, true)

    # now run both the DP and genetic algorotihms to compare them
    W = 10000
    min_items = 1
    max_items = 200
    iterations_per_n = 10
    greedy_dp_genetic_experiment(W, min_items, max_items, iterations_per_n, true)

    # run some experiments for the genetic
    W = 10000
    n_items = 100
    plot_dir = "../plots/"
    genetic_score_comparison(W, n_items, 1000, plot_dir * "W_10000_items_100_population_1000.png")
    genetic_score_comparison(W, n_items, 10000, plot_dir * "W_10000_items_100_population_10000.png")
    W = 500
    n_items = 1000
    genetic_score_comparison(W, n_items, 1000, plot_dir * "W_500_items_1000_population_1000.png")
    genetic_score_comparison(W, n_items, 10000, plot_dir * "W_500_items_1000_population_10000.png")
end



# guard so that main() is executed only when script is run, not when imported
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
