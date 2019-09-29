include("model.jl")
include("utils.jl")

using .BreitlingCup: solve_instance
using .Utils: load_instance, recover_path

instance_name  = ARGS[1]

params, regions, coordinates = load_instance(instance_name)
println(params)

solution, objective = solve_instance(coordinates=coordinates,
                                     airports_regions=regions,
                                     start_id=params["start_index"],
                                     end_id=params["end_index"],
                                     n_min_visits=params["Amin"],
                                     max_flight_distance=params["R"])

println(objective)
path = recover_path(solution, params["start_index"], params["end_index"])
println(path)
