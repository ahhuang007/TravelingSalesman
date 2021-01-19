using CSV
using DataFrames
using Random
using Plots
#Note: this version is supposed to be worse than julia_tsp_rs.jl since it has 4 more global variables,
#but during the 5000000 iteration tests it's just as good if not better. However, when benchmarking
#at 50000 iterations it's outperformed (1.998 vs 2.467 secondss). Idk man.
df = CSV.read("C://Users//ahhua//Downloads//tsp.txt", DataFrame) 


df.ID = 1:1000
df.dist_to_next = zeros(1000)


function get_dist(df)
	tempdf = df
	first_row = tempdf[1, :]
    tempdf = tempdf[2:1000, :]
	tempdf = push!(tempdf, first_row)
	df.dist_to_next = sqrt.((tempdf.x - df.x).^2 
					+ (tempdf.y - df.y).^2)
    return df
end 

new_df = get_dist(df)
total_dist = sum(new_df.dist_to_next)
shortest_dist = total_dist
longest_dist = total_dist
short_dists = []
push!(short_dists, total_dist)
short_iters = []
push!(short_iters, 1)
shortest_df = new_df
long_dists = []
push!(long_dists, total_dist)
long_iters = []
push!(long_iters, 1)
longest_df = new_df

end_loop = 50000


for i in 1:end_loop
	global new_df = new_df[shuffle(1:end), :]
	new_df = get_dist(new_df)
	new_dist = sum(new_df.dist_to_next)
	if new_dist < shortest_dist
		push!(short_dists, new_dist)
		push!(short_iters, i + 1)
		global shortest_dist = new_dist
		global shortest_df = new_df
		println("new shortest distance acquired at iteration $(i + 1)")
	end
    if new_dist > longest_dist
        push!(long_dists, new_dist)
        push!(long_iters, i + 1)
        global longest_dist = new_dist
        global longest_df = new_df
        println("new longest distance acquired at iteration $(i + 1)")
	end
end 


push!(short_dists, shortest_dist)
push!(short_iters, end_loop + 1)
frs = shortest_df[1, :]
push!(shortest_df, frs)
push!(long_dists, longest_dist)
push!(long_iters, end_loop + 1)
frl = longest_df[1, :]
push!(longest_df, frl)

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
