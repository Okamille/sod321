#/usr/bin/julia

using JuMP
import GLPK
using LinearAlgebra: diag, norm, Symmetric


function run_optimization(model) # FIXME
    optimize!(model)
    solution = value(x)
    optimal_value = objective_value(model)
    return optimal_value, solution
end


function build_model(coordinates, airports_regions, start_id, end_id,
                     n_min_visits, max_flight_distance, subtour_constraint)
    
    n = size(airports_regions)
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
        @constraint(model, dont_arrive_at_end,
                    sum(x[end_id, :]) == 0)
    end
    @constraint(model,
                depart_iff_arrive[id = idx[idx .!= start_id .& .!= start_id]],
                sum(x[id, :]) - sum(x[:, id]) == 0)

    # At least n_min_visits visited airports
    @constraint(model, min_visits,
                sum(x) >= n_min_visits - (start_id == end_id))

    # Visit all regions at least once
    regions = get_regions(airports_regions, start_id, end_id)
    @constraint(
        model, visit_all_regions[r = regions],
        sum(x[airport_regions .== r, :]) + sum(x[:, airport_regions .== r]) >= 1)

    # Can't fly more than max_distance at once
    @constraint(model, max_distance,
                x .* distances .<= max_flight_distance)

    # Subtour
    if subtour_constraint == "polynomial"  # TODO
        @variable(model, u[i = 1:n], Int)
        @constraint(model, subtour,
                    u[j] > u[i] - n * (1 - x[i, j]))
    elseif subtour_constraint == "exponential"  # TODO
        S = []
        @constraint(sum(x[i, j]) <= len(S) - 1)
    else
        println("No subtour constraints, the plane may teleport.")
    end
end


function compute_distances(coordinates)::Symmetric{Float64, Array{Float64, 2}}
    n = size(coordinates, 1)
    distances = zeros(n, n)
    for i=2:n
        for j=1:i-1
            distances[i, j] = norm(coordinates[i, :] - coordinates[j, :])
        end
    end
    return Symmetric(distance_i_j, :L)
end


function get_regions(airports_regions, start_id, end_id)::Array{Int, 1}
    start_region = airport_regions[start_id]
    end_region = airport_regions[end_id]
    regions = unique(airports_regions)
    regions = regions[regions .!= start_region .& regions .!= end_region]
    return regions
end
