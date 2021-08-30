using CSV
using DataFrames
using Random
using Plots
using StatsBase
using Distances

#Revised Julia version of my GA, written to be effective. Hopefully efficiency will come later.

function shared_fitness(solution, min_dist, share_param, genomes, dist)
	denom = 1

	for i in genomes
		hd = hamming(solution.ID, i.ID)

		if hd < min_dist
			denom += (1 - (hd/share_param))
		end

	end

	return dist/denom
end

function get_dist(df::DataFrame)
	tempdf = df
	first_row = tempdf[1, :]
    tempdf = tempdf[2:end, :]
	tempdf = push!(tempdf, first_row)
	df.dist_to_next = sqrt.((tempdf.x::Array{Float64, 1} - df.x::Array{Float64, 1})::Array{Float64, 1}.^2
	+ (tempdf.y::Array{Float64, 1} - df.y::Array{Float64, 1})::Array{Float64, 1}.^2)
    return df
end

function get_elites(dists, temp_genomes, genomes)
	for e in 1:convert(Int64, length(genomes)/10)
		ec = argmin(dists)
		push!(temp_genomes, genomes[ec])
		deleteat!(dists, ec)
	end
	return temp_genomes
end

function crossover(parents, temp_genomes, c_len::Int64)
	for p in parents
		
		c_point = rand(1:184)
		child1 = p[1][c_point:c_point + c_len - 1, :]::DataFrame
		child2 = p[2][c_point:c_point + c_len - 1, :]::DataFrame

		c1_id = child1.ID
		c2_id = child2.ID
		p1p1 = p[1][1:c_point + c_len - 1, :]::DataFrame
		p1p2 = p[1][c_point + c_len:end, :]
		p2p1 = p[2][1:c_point + c_len - 1, :]::DataFrame
		p2p2 = p[2][c_point + c_len:end, :]
		#println(typeof(isnothing.(indexin(p2p1.ID, c1_id))))
		sect_c1a = p2p1[isnothing.(indexin(p2p1.ID, c1_id)), :]::DataFrame
		sect_c1b = p2p2[isnothing.(indexin(p2p2.ID, c1_id)), :]::DataFrame
		sect_c2a = p1p1[isnothing.(indexin(p1p1.ID, c2_id)), :]::DataFrame
		sect_c2b = p1p2[isnothing.(indexin(p1p2.ID, c2_id)), :]::DataFrame
		child1 = vcat(sect_c1a, child1, sect_c1b)::DataFrame
		child2 = vcat(sect_c2a, child2, sect_c2b)::DataFrame

		#Crowding method
		p1d = sum(get_dist(p[1]).dist_to_next)
		p2d = sum(get_dist(p[2]).dist_to_next)
		c1d = sum(get_dist(child1).dist_to_next)
		c2d = sum(get_dist(child2).dist_to_next)
		if abs(p1d - c1d) + abs(p2d - c2d) < abs(p1d - c2d) + abs(p2d - c1d)
			if p1d < c1d
				push!(temp_genomes, p[1])
			else
				push!(temp_genomes, child1)
			end
			if p2d < c2d
				push!(temp_genomes, p[2])
			else
				push!(temp_genomes, child2)
			end
		else
			if p1d < c2d
				push!(temp_genomes, p[1])
			else
				push!(temp_genomes, child2)
			end
			if p2d < c1d
				push!(temp_genomes, p[2])
			else
				push!(temp_genomes, child1)
			end
		end
		#push!(temp_genomes, child1)
		#push!(temp_genomes, child2)
		
	end
	return temp_genomes
end

function mutate(temp_genomes)
	s = size(temp_genomes[1])[1]
	for k in temp_genomes
		if rand() < 0.01
			r1 = rand(1:s)
			r2 = rand(1:s)
			while r2 == r1
				r2 = rand(1:s)
			end
			temp_row = deepcopy(k[r2, :])
			k[r2, :] = k[r1, :]
			k[r1, :] = temp_row
		end
	end
	return temp_genomes
end

function ga_loop(genomes, dists, short_dists, short_iters, shortest_df, n_gs, avg_fit)
	iters = 3000
	counter = 0
	mind = Inf
	#for i in 1:iters
	i = 1
	while counter < 1000 && mind > 400
		#Calculating shared fitness values
		#shared_fits = []
		#for v in 1:length(genomes)
		#	push!(shared_fits, shared_fitness(genomes[v], 25, 40, genomes, dists[v]))
		#end
		temp_genomes = []
	    temp_dists = []
		recips = 1 ./ dists
		#recips = 1 ./ shared_fits
		normed = [x / sum(recips) for x in recips]
		parents = []
		#temp_genomes = get_elites(shared_fits, temp_genomes, genomes)
		temp_genomes = get_elites(dists, temp_genomes, genomes)
		#Figuring out which genomes will reproduce
		#Parents for each one will be chosen from fitness proportion
		#Parents will produce 2 children
		for j in 1:43*10
			push!(parents, sample(genomes, Weights(normed), 2, replace=false))
		end

		#Recombination
		#Using ordered crossover
		temp_genomes = crossover(parents, temp_genomes, 16)
		
		#Mutations
		temp_genomes = mutate(temp_genomes)
		
		#Adding new genomes to population - 2-4% of population will be new
		for y in 1:4*10
			push!(temp_genomes, genomes[1][shuffle(1:end), :])
		end
		
		println("iteration $i")

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
			println("new shortest distance acquired at iteration $i: $mind")
			counter = 0
		else
			counter += 1
		end
		i += 1
	end
	return short_dists, short_iters, shortest_df, avg_fit, i
end

function tsp_ga()
	#df = CSV.read("C://Users//ahhua//Downloads//tsp.txt", DataFrame)
	df = DataFrame()
	df.x = fill(0.0, 200)
	df.y = shuffle(1.0:200.0)
	df.ID = 1:200
	df.dist_to_next = zeros(200)

	genomes = []
	dists = []
	n_gs = 1000
	iterations = 3000
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

	short_dists, short_iters, shortest_df, avg_fit, iterations = ga_loop(genomes, dists, short_dists, short_iters, shortest_df, n_gs, avg_fit)

	push!(short_dists, short_dists[end])
	push!(short_iters, iterations + 1)
	frs = shortest_df[end][1, :]::DataFrameRow{DataFrame,DataFrames.Index}
	push!(shortest_df[end], frs)

	println("loop ended!")

	println("shortest distance found was: $(short_dists[end])")

	CSV.write("C://Users//ahhua//Documents//jl_ga_shortest.csv", shortest_df)
	ga_short_csv = DataFrame(short_iters = short_iters, short_dists = short_dists)
	CSV.write("C://Users//ahhua//Documents//jl_ga_short_csv.csv", ga_short_csv)
	ga_avgs = DataFrame(generation = 1:iterations, avg_fitness = avg_fit)
	CSV.write("C://Users//ahhua//Documents//jl_avg_fitness.csv", ga_avgs)
	gr()
	evo = plot(short_iters, short_dists, linetype =:steppost, label = "shortest distance")
	xlabel!("iterations")
	ylabel!("distance")
	title!("genetic algorithm")
	display(evo)
	return "Completed algorithm"::String
end
