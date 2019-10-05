module Utils

export load_instance, recover_path

function load_instance(instance_name)
    lines = readlines(joinpath("instances", "$instance_name.txt"))
    lines_names = [
        "nb_airport",
        "start_index",
        "end_index",
        "Amin",
        "nb_region"
    ]
    params = Dict((name, parse(Int, line))
                  for (name, line) in zip(lines_names, lines[1:5]))
    params["R"] = parse(Int, lines[9])

    regions = [parse(Int, region) for region in split(lines[7])]

    coordinates = [[parse(Int, coo) for coo in split(line)]
                    for line in lines[11:end-1]]

    return params, regions, coordinates
end

function recover_path(solution, start_id, end_id)
    path = [start_id]
    next_airport = start_id
    while next_airport != end_id
        next_airport = argmax(solution[next_airport, :])
        append!(path, next_airport)
    end
    return path
end

end