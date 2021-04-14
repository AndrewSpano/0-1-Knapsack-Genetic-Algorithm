# using Pkg
# Pkg.add("Plots")

import Plots


function plot_fpg(best_fitness_per_generation::Array{Any, 1}, optimal_fitness::Int64, greedy_fitness::Int64, plot_filepath::String)
    optimal_value = ones(size(best_fitness_per_generation, 1)) * optimal_fitness
    greedy_value = ones(size(best_fitness_per_generation, 1)) * greedy_fitness
    p = Plots.plot(best_fitness_per_generation, title = "Fitness of best Genome per Generation", label = "Genetic",
                   lw = 2, ylims = (0, (11/10) * optimal_fitness), xlabel = "generations", ylabel = "fitness", legend = :right)
    Plots.plot!(p, optimal_value, label = "DP", lw = 2)
    Plots.plot!(p, greedy_value, label = "Greedy", lw = 2)
    Plots.savefig(plot_filepath)
end

function plot_bf(runtimes::Array{Any, 1})
    Plots.plot(runtimes, title = "Brute-Force 0-1 Knapsack Runtime", label = "Brute Force",
               lw = 2, xlabel = "n (number of items)", ylabel = "Seconds", legend = :top)
    Plots.savefig("../plots/bf_knapsack_runtime.png")
end


function plot_dp_vs_genetic(gr_ar::Array{Any, 1}, gr_a_sa::Array{Any, 1}, gr_a_sola::Array{Any, 1},
                            dp_ar::Array{Any, 1}, genetic_ar::Array{Any, 1}, genetic_a_sa::Array{Any, 1}, genetic_a_sola::Array{Any, 1})
    # plot the runtimes and save it
    p = Plots.plot(dp_ar, title = "Greedy vs DP vs Genetic Runtime", label = "DP", lw = 2,
                   xlabel = "n (number of items)", ylabel = "Seconds", legend = :top)
    Plots.plot!(p, gr_ar, label = "Greedy", lw = 2)
    Plots.plot!(p, genetic_ar, label = "Genetic", lw = 2)
    Plots.savefig("../plots/dp_vs_genetic_knapsack_runtime.png")

    # plot average score accuracy
    dp_a_sa = ones(size(genetic_a_sa, 1))
    p = Plots.plot(dp_a_sa, title = "Average Score Accuracy", label = "DP", lw = 2,
                   ylims = (0.0, 1.01), xlabel = "n (number of items)",
                   ylabel = "Average Score Accuracy", legend = :right)
    Plots.plot!(p, gr_a_sa, label = "Greedy", lw = 2)
    Plots.plot!(p, genetic_a_sa, label = "Genetic", lw = 2)
    Plots.savefig("../plots/greedy_dp_genetic_knapsack_score_accuracy.png")

    # plot average solution accuracy
    dp_a_sola = ones(size(genetic_a_sola, 1))
    p = Plots.plot(dp_a_sola, title = "Average Solution Accuracy", label = "DP", lw = 2,
                   ylims = (0.0, 1.01), xlabel = "n (number of items)",
                   ylabel = "Average Solution Accuracy", legend = :right)
    Plots.plot!(p, gr_a_sola, label = "Greedy", lw = 2)
    Plots.plot!(p, genetic_a_sola, label = "Genetic", lw = 2)
    Plots.savefig("../plots/greedy_dp_genetic_knapsack_solution_accuracy.png")
end