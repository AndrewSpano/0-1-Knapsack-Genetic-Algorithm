include("algorithms/brute_force.jl")

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

    solution = brute_force_knapsack(weights, values, W)
    println(solution)

end



# guard so that main() is executed only when script is run, not when imported
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
