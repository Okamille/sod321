module BreitlingCup

using LinearAlgebra: diag, norm, Symmetric
using JuMP
import GLPK

export build_model, run_optimization!


function build_model(; coordinates, airports_regions, start_id, end_id,
                     n_min_visits, max_flight_distance,
                     subtour_constraint="polynomial")
    
    n = size(airports_regions, 1)
    distances = compute_distances(coordinates)

    model = Model(with_optimizer(GLPK.Optimizer))
    @variable(model, x[i=1:n, j=1:n], Bin)
    @constraint(model, diag(x) .== 0)  # removes x_ii
    @objective(model, Min, sum(x .* distances))

    idx = [i for i=1:n]  # Useful array for boolean slicing

    # At most one departure / arrival at each airport
    @constraint(model, at_most_one_depart[dep_id = idx[idx .!= end_id]],
                sum(x[dep_id, :]) <= 1)

    @constraint(model, at_most_one_arrival[arr_id = idx[idx .!= start_id]],
                sum(x[:, arr_id]) <= 1)

    # Connectivity
    @constraint(model, depart_from_start,
                sum(x[start_id, :]) == 1)
    @constraint(model, arrive_at_end,
                sum(x[:, end_id]) == 1)
    if start_id != end_id
        @constraint(model, dont_arrive_at_start,
                    sum(x[:, start_id]) == 0)
        @constraint(model, dont_leave_from_end,
                    sum(x[end_id, :]) == 0)
    end
    @constraint(
        model,
        depart_iff_arrive[id in idx[(idx .!= start_id) .& (idx .!= end_id)]],
        sum(x[id, :]) == sum(x[:, id])
    )
    # At least n_min_visits visited airports
    start_neq_end = start_id == end_id ? 0 : 1
    @constraint(model, min_visits,
                sum(x) + start_neq_end >= n_min_visits)

    # Visit all regions at least once
    regions = get_regions(airports_regions, start_id, end_id)
    @constraint(
        model, visit_all_regions[r = regions],
        sum(x[airports_regions .== r, :]) + sum(x[:, airports_regions .== r]) >= 1)

    # Can't fly more than max_distance at once
    @constraint(model, max_distance,
                x .* distances .<= max_flight_distance)

    # Subtour
    if subtour_constraint == "polynomial"
        @variable(model, u[i = 1:n], Int)
        @constraint(model, subtour[i=1:n, j=1:n],
                    u[j] >= u[i] + 1 - n * (1 - x[i, j]))
    # elseif subtour_constraint == "exponential"  # TODO
    #     S = []
    #     @constraint(sum(x[i, j]) <= len(S) - 1)
    else
        println("No subtour constraints, the plane may teleport.")
    end

    return model

end


function run_optimization!(model)
    optimize!(model)

    if termination_status(model) == MOI.OPTIMAL
        optimal_solution = value.(model[:x])
        optimal_objective = objective_value(model)
        return optimal_objective, optimal_solution
    end

    if termination_status(model) == MOI.TIME_LIMIT && has_values(model)
        suboptimal_solution = value.(model[:x])
        suboptimal_objective = objective_value(model)
        return suboptimal_solution, suboptimal_objective
    end

    error("The model was not solved correctly.")
end


function compute_distances(coordinates)::Symmetric{Float64, Array{Float64, 2}}
    n = size(coordinates, 1)
    distances = zeros(n, n)
    for i=2:n
        for j=1:i-1
            distances[i, j] = norm(coordinates[i, :] - coordinates[j, :])
        end
    end
    return Symmetric(distances, :L)
end


function get_regions(airports_regions, start_id, end_id)::Array{Int, 1}
    start_region = airports_regions[start_id]
    end_region = airports_regions[end_id]
    regions = unique(airports_regions)
    regions = regions[(regions .!= start_region) .& (regions .!= end_region) .& (regions .!= 0)]
    return regions
end

end