using CSV
using DataFrames
using Random
using Plots




function get_dist(df)
	tempdf = df
	first_row = tempdf[1, :]
    tempdf = tempdf[2:1000, :]
	tempdf = push!(tempdf, first_row)
	df.dist_to_next = sqrt.((tempdf.x::Array{Float64, 1} - df.x::Array{Float64, 1})::Array{Float64, 1}.^2
	+ (tempdf.y::Array{Float64, 1} - df.y::Array{Float64, 1})::Array{Float64, 1}.^2)
    return df
end




function loop(end_loop, new_df, short_dists, short_iters, shortest_df, long_dists, long_iters, longest_df)

	for i in 1:end_loop
		new_df = new_df[shuffle(1:end), :]
		new_df = get_dist(new_df)
		new_dist = sum(new_df.dist_to_next)
		if new_dist < short_dists[end]
			push!(short_dists, new_dist)
			push!(short_iters, i + 1)
			push!(shortest_df, new_df)
			println("new shortest distance acquired at iteration $(i + 1)")
		end
	    if new_dist > long_dists[end]
	        push!(long_dists, new_dist)
	        push!(long_iters, i + 1)
	        push!(longest_df, new_df)
	        println("new longest distance acquired at iteration $(i + 1)")
		end
	end
	return short_dists, short_iters, shortest_df, long_dists, long_iters, longest_df
end


function tsp_rs()
	df = CSV.read("C://Users//ahhua//Downloads//tsp.txt", DataFrame)


	df.ID = 1:1000
	df.dist_to_next = zeros(1000)

	new_df = get_dist(df)
	total_dist = sum(new_df.dist_to_next)::Float64
	short_dists = []
	push!(short_dists, total_dist)
	short_iters = []
	push!(short_iters, 1)
	shortest_df = []
	push!(shortest_df, new_df)
	long_dists = []
	push!(long_dists, total_dist)
	long_iters = []
	push!(long_iters, 1)
	longest_df = []
	push!(longest_df, new_df)

	end_loop = 5000000
	short_dists, short_iters, shortest_df, long_dists, long_iters, longest_df =
	loop(end_loop, new_df, short_dists, short_iters, shortest_df, long_dists, long_iters, longest_df)

	push!(short_dists, short_dists[end])
	push!(short_iters, end_loop + 1)
	frs = shortest_df[end][1, :]::DataFrameRow{DataFrame,DataFrames.Index}
	push!(shortest_df[end], frs)
	push!(long_dists, long_dists[end])
	push!(long_iters, end_loop + 1)
	frl = longest_df[end][1, :]::DataFrameRow{DataFrame,DataFrames.Index}
	push!(longest_df[end], frl)

	println("loop ended!")




	CSV.write("C://Users//ahhua//Documents//jl_random_search_shortest.csv", shortest_df)
	CSV.write("C://Users//ahhua//Documents//jl_random_search_longest.csv", longest_df)
	rs_short_csv = DataFrame(short_iters = short_iters, short_dists = short_dists)
	rs_long_csv = DataFrame(long_iters = long_iters, long_dists = long_dists)
	CSV.write("C://Users//ahhua//Documents//jl_rs_short_csv.csv", rs_short_csv)
	CSV.write("C://Users//ahhua//Documents//jl_rs_long_csv.csv", rs_long_csv)

	gr()
	plot(short_iters, short_dists, linetype =:steppost, label = "shortest distance")
	plot!(long_iters, long_dists, linetype =:steppost, label = "longest distance")
	xlabel!("iterations")
	ylabel!("distance")
	title!("random search algorithm")
	return "Completed algorithm"::String
end
