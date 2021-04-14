include("../utils/plot_results.jl")

import Random
import StatsBase


function random_genome(dim::Int64, init_zeros::Bool)
    """ produces a new genome by initializing it's values and returning it """
    if init_zeros
        return falses(dim)
    else
        return Random.bitrand(dim)
    end
end


function fitness(genome::BitArray{1}, weights::Array{UInt32, 1}, values::Array{UInt32, 1}, knapsack_capacity::UInt32)
    """ computes the fitness (score) of a given genome """
    total_weight = sum(genome .* weights)
    if total_weight > knapsack_capacity
        return 1e-8
    end
    return max(sum(genome .* values), 1e-8)
end


function random_pair(population::Array{BitArray{1}, 1}, fitnesses::Array{Float64, 1})
    """ pick 2 genomes out of a population, using their fitnesses as weights """
    return StatsBase.sample(population, StatsBase.Weights(fitnesses), 2, replace = false)
end


function random_crossover(genome_a::BitArray{1}, genome_b::BitArray{1}, n_items::Int64)
    """ crossover two genomes at a random points """
    crossover_bit = rand(0:n_items)
    new_genome_a = vcat(genome_a[1 : crossover_bit], genome_b[crossover_bit + 1 : end])
    new_genome_b = vcat(genome_b[1 : crossover_bit], genome_a[crossover_bit + 1 : end])
    return new_genome_a, new_genome_b
end


function random_mutation(genome::BitArray{1}, n_items::Int64, num_mutations::Int64, mutation_probability::Float64)
    """ mutate `num_mutations` bits of a given genome, with probability  `mutation_probability` """
    for _ = 1 : num_mutations
        if rand() < mutation_probability
            random_bit = rand(1:n_items)
            genome[random_bit] = 1 - genome[random_bit]
        end
    end
end


function genetic_knapsack(weights::Array{UInt32, 1}, values::Array{UInt32, 1}, knapsack_capacity::UInt32; kwargs...)
    """
    # Arguments

    - `weights::Array{UInt32, 1}`:
        An array containing the "weight" of each item.

    - `values::Array{UInt32, 1}`:
        An array containing the "value" of each item.
    
    - `knapsack_capacity::UInt32`:
        The maximum sum of weights of selected items, that is, the capacity of the knapsack.

    - `population_size::Int64` = 100:
        The number of genomes to produce to start with and remain for every generation.

    - `init_zeros::Bool` = false:
        If specified, then all the genomes will be initialized with 0s, allowing for more valid combinations.

    - `max_generations::Int64` = 100:
        The maximum number of generations to perform.
    
    - `threshold::Float64` = 0.0:
        The minimum threshold for improvement over a generation.
    
    - `patience::Int64` = 5:
        Number of generations to wait for improvement.

    - `num_mutations::Int64` = 1:
        Number of mutations to perform during the mutation procedure.

    - `mutation_prob::Float64` = 0.5:
        The probabolity that a random bit of a genome gets mutated.
    
    - `verbose::Bool = false`:
        If specified, then information about every generation gets printed in the console.
    
    - `plot_best_fitness_per_generation::Bool = false`:
        If specified, then a plot with the best fitness of every generation will be created.
    
    - `optimal_fitness::Float64 = 0.0`:
        The optimal score (fitness) found from Dynamic Programming.

    - `greedy_fitness::Float64 = 0.0`:
        The score (fitness) found from the greedy algorithm.

    - `plot_filepath::String = ../plots/plot.png`:
        The relative/absolute path to save the plot fitness vs generations.

    Computes a solution for the 0-1 Knapsack problem using a Genetic Algorithm which performs steps of:
        Elitism (survival of the fittest), random selection and crossover, random mutation.
    """

    # get a dictionary from the keyword arguments
    kwargs_dict = Dict(kwargs)

    population_size = get(kwargs_dict, :population_size, 100)
    init_zeros = get(kwargs_dict, :init_zeros, false)
    max_generations = get(kwargs_dict, :max_generations, 100)
    threshold = get(kwargs_dict, :threshold, 0)
    patience = get(kwargs_dict, :patience, 5)
    num_mutations = get(kwargs_dict, :num_mutations, 1)
    mutation_prob = get(kwargs_dict, :mutation_prob, 0.5)
    verbose = get(kwargs_dict, :verbose, false)
    _plot_fpg = get(kwargs_dict, :plot_best_fitness_per_generation, false)
    optimal_fitness = get(kwargs_dict, :optimal_fitness, 0.0)
    greedy_fitness = get(kwargs_dict, :greedy_fitness, 0.0)
    plot_filepath = get(kwargs_dict, :plot_filepath, "../plots/plot.png")

    # create a population of genomes
    n_items = size(weights, 1)
    population = [random_genome(n_items, init_zeros) for _ = 1 : population_size]
    fpg = []

    # keep track of the best genome
    best_config = falses(n_items)
    best_score = 1e-8

    # flag for early stopping
    current_patience = 0

    # perform a maximum number of generations
    for generation = 1 : max_generations

        # compute fitness for each genome of the current population, and sort the array by it
        fitnesses = [fitness(genome, weights, values, knapsack_capacity) for genome in population]
        population_fitnesses = sort(collect(zip(population, fitnesses)), by = last, rev = true)

        population = getindex.(population_fitnesses, 1)
        fitnesses = getindex.(population_fitnesses, 2)
        push!(fpg, fitnesses[1])

        # check for early stopping, but make sure at least 1 legit solution has been found
        if 1e-8 < fitnesses[1] <= best_score + threshold
            current_patience += 1
        elseif fitnesses[1] > best_score + threshold
            current_patience = 0
            best_config = population[1]
            best_score = fitness(population[1], weights, values, knapsack_capacity)
        end
        if current_patience == patience
            if verbose
                println("Stopping at generation ", generation)
            end
            break
        end

        # Elitism
        new_population = population[1:2]

        for _ = 1 : population_size / 2 - 1

            genome_a, genome_b = random_pair(population, fitnesses)
            child_a, child_b = random_crossover(genome_a, genome_b, n_items)
            random_mutation(child_a, n_items, num_mutations, mutation_prob)
            random_mutation(child_b, n_items, num_mutations, mutation_prob)

            push!(new_population, child_a, child_b)
        end

        if verbose
            println("Completed generation ", generation)
        end
        population = new_population
    end

    # plot the generatiovs vs fitness graph if specified
    if _plot_fpg
        plot_fpg(fpg, optimal_fitness, greedy_fitness, plot_filepath)
    end

    return best_config
end


function run_genetic(weights::Array{UInt32, 1}, values::Array{UInt32, 1}, knapsack_capacity::UInt32)
	""" runs the above function, while also returning the execution time """
    exe_time = @timed begin
        best_config = genetic_knapsack(weights, values, knapsack_capacity, population_size = 1000, max_generations = 100, init_zeros = true)
    end
    return best_config, exe_time.time
end

