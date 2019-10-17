include("model.jl")
include("utils.jl")

using .BreitlingCup: build_model, run_optimization!, solve_w_lazy_ILP!
using .Utils: load_instance, recover_path, save_results


function solve_instance(instance_name, subtour_constraint)
    println(instance_name)
    params, regions, coordinates = load_instance(instance_name)

    model = build_model(coordinates=coordinates,
                        airports_regions=regions,
                        start_id=params["start_index"],
                        end_id=params["end_index"],
                        n_min_visits=params["Amin"],
                        max_flight_distance=params["R"],
                        subtour_constraint=subtour_constraint)

    if subtour_constraint == "polynomial"
        @time objective, solution = run_optimization!(model)
    else
        @time objective, solution = solve_w_lazy_ILP!(
            model, params["start_index"], params["end_index"]
        )
    end

    path = recover_path(solution, params["start_index"], params["end_index"])
    solution = Dict("objective"=>objective, "path"=>path)
    return solution
end

subtour_constraint = ARGS[1]
instance_name = ARGS[2]

if instance_name == "all"
    for instance in readdir("instances")
        instance_name = split(instance, ".")[1]
        solution = solve_instance(instance_name, subtour_constraint)
        save_results(solution, instance_name, subtour_constraint)
    end
else
    solution = solve_instance(instance_name, subtour_constraint)
    save_results(solution,instance_name, subtour_constraint)
end
