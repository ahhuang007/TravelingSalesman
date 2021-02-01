using CSV
using DataFrames
using Random
using Plots
using StatsBase

#Revised Julia version of my GA, written to be effective and efficient.

function get_dist(df)
	tempdf = df
	first_row = tempdf[1, :]
    tempdf = tempdf[2:1000, :]
	tempdf = push!(tempdf, first_row)
	df.dist_to_next = sqrt.((tempdf.x::Array{Float64, 1} - df.x::Array{Float64, 1})::Array{Float64, 1}.^2
	+ (tempdf.y::Array{Float64, 1} - df.y::Array{Float64, 1})::Array{Float64, 1}.^2)
    return df
end

function ga_loop(genomes, dists, short_dists, short_iters, shortest_df, n_gs, avg_fit)
	iters = 50000
	mutate_prob = 0.2
	for i in 1:iters
		temp_genomes = []
	    temp_dists = []
		recips = 1 ./ dists
		normed = [x / sum(recips) for x in recips]
		parents = []
		#Figuring out which genomes will reproduce
		#What if I have a set number of reproduced genomes every gen
		#Parents for each one will be chosen from fitness proportion
		#Parents will produce 2 children

		for j in 1:23
			push!(parents, sample(genomes, Weights(normed), 2, replace=false))
		end

		#Recombination
		#probability of crossover is 0.7
		#If this doesn't work, consider lowering range of crossover to 400-600
		#maybe make 4 children instead of 2?
		#increase mutation rate?
		#super inefficient - start with p1, compare between p1 and p2 which path 
		#is shorter, then add to new child
		#example - 142935687, 261349578
		#See if 4 or 9 (or maybe 7 or 6 too) is shorter, let's say 4 is shorter
		#Now new child is 14-------
		#See if 2 or 9 is shorter, repeat
		#A less intensive and more random way is to just always alternate
		#between choosing P1 and P2 to create new child, creating 2 children
		#Could maybe save time and just hack off a 400 length piece of one parent
		#(maybe choose depending on which length is shorter), then continue
		for p in parents
			if rand() < 0.7
				c_len = rand(1:800)
				c_point = rand(1:1000 - c_len)
				child1 = p[1][c_point:c_point + c_len - 1, :]
				child2 = p[2][c_point:c_point + c_len - 1, :]

				c1_id = child1[:, "ID"]
				c2_id = child2[:, "ID"]

				secta = p[2][isnothing.(indexin(p[2].ID, c1_id)), :]
				sectb = p[1][isnothing.(indexin(p[1].ID, c2_id)), :]
				child1 = vcat(child1, secta)
				child2 = vcat(child2, sectb)
				push!(temp_genomes, child1)
				push!(temp_genomes, child2)
			else
				push!(temp_genomes, p[1])
				push!(temp_genomes, p[2])
			end
		end

		#Mutations
		for k in temp_genomes
			if rand() < 0.2
				r1 = rand(1:1000)
				r2 = rand(1:1000)
				temp_row = deepcopy(k[r1, :])
				k[r2, :] = k[r2, :]
				k[r1, :] = temp_row
			end
		end

		#Adding 4 new genomes to population
		println("iteration $i")
		for y in 1:4
			push!(temp_genomes, genomes[1][shuffle(1:end), :])
		end

		genomes = temp_genomes
		for z in 1:n_gs
			genomes[z] = get_dist(genomes[z])
			push!(temp_dists, sum(genomes[z].dist_to_next))
		end
		dists = temp_dists
		mind = minimum(dists)
		mindi = argmin(dists)
		push!(avg_fit, mean(dists))
		if mind < short_dists[end]
			push!(short_dists, mind)
			push!(short_iters, i+2)
			push!(shortest_df, genomes[mindi])
			println("new shortest distance acquired at iteration $i")
		end

	end
	return short_dists, short_iters, shortest_df, avg_fit
end

function tsp_ga()
	df = CSV.read("C://Users//ahhua//Downloads//tsp.txt", DataFrame)

	df.ID = 1:1000
	df.dist_to_next = zeros(1000)

	genomes = []
	dists = []
	n_gs = 50
	for i in 1:n_gs
		new_df = df[shuffle(1:end), :]
		new_df = get_dist(new_df)
		push!(genomes, new_df)
		push!(dists, sum(new_df.dist_to_next))
	end

	new_df = get_dist(df)
	total_dist = sum(new_df.dist_to_next)::Float64
	short_dists = []
	push!(short_dists, total_dist)
	short_iters = []
	push!(short_iters, 1)
	shortest_df = []
	push!(shortest_df, new_df)
	avg_fit = []
	push!(avg_fit, mean(dists))

	short_dists, short_iters, shortest_df = ga_loop(genomes, dists, short_dists, short_iters, shortest_df, n_gs, avg_fit)

	push!(short_dists, short_dists[end])
	push!(short_iters, 50000 + 1)
	frs = shortest_df[end][1, :]::DataFrameRow{DataFrame,DataFrames.Index}
	push!(shortest_df[end], frs)

	println("loop ended!")

	println("shortest distance found was: $(short_dists[end])")

	CSV.write("C://Users//ahhua//Documents//jl_ga_shortest.csv", shortest_df)
	ga_short_csv = DataFrame(short_iters = short_iters, short_dists = short_dists)
	CSV.write("C://Users//ahhua//Documents//jl_ga_short_csv.csv", ga_short_csv)
	ga_avgs = DataFrame(generation = 1:50001, avg_fitness = avg_fit)
	CSV.write("C://Users//ahhua//Documents//jl_avg_fitness.csv", ga_avgs)
	gr()
	plot(short_iters, short_dists, linetype =:steppost, label = "shortest distance")
	xlabel!("iterations")
	ylabel!("distance")
	title!("genetic algorithm")
	return "Completed algorithm"::String
end
