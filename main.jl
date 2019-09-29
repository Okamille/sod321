include("model.jl")
include("utils.jl")

using .BreitlingCup: build_model, run_optimization!
using .Utils: load_instance, recover_path


function solve_instance(instance_name)
    println(instance_name)
    params, regions, coordinates = load_instance(instance_name)

    model = build_model(coordinates=coordinates,
                        airports_regions=regions,
                        start_id=params["start_index"],
                        end_id=params["end_index"],
                        n_min_visits=params["Amin"],
                        max_flight_distance=params["R"])

    objective, solution = run_optimization!(model)
    println(objective)
    path = recover_path(solution, params["start_index"], params["end_index"])
    println(path)
    println()
end

instance_name = ARGS[1]

if instance_name == "all"
    for instance_name in readdir("instances")
        solve_instance(split(instance_name, ".")[1])
    end
else
    solve_instance(instance_name)
end
