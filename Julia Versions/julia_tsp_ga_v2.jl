using CSV
using DataFrames
using Random
using Plots

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

function ga_loop(genomes, dists, short_dists, short_iters, shortest_df, n_gs)
	iters = 100000
	mutate_prob = 0.75
	for i in 1:iters
		temp_genomes = []
	    temp_dists = []
		total_fit = sum(dists)

		#Figuring out which genomes will reproduce
		recom = []

		for j in 1:n_gs
			prob = dists[j] / total_fit

			if prob >= 1
				push!(recom, j)
			else
				num = rand()
				if num <= mutate_prob
					push!(recom, j)
				end
			end
		end

		#Recombination
		lengt = 400
		recombines = length(recom)

		for p in 1:recombines
			par1 = genomes[p]
			rando = rand(1:recombines)
			if rando == p
				random = rand(1:recombines)
			end
			par2 = genomes[rando]

			start = rand(1:600)
			endl = start + lengt
			child = par1[start:endl-1, :]

			par1_id = par1[start:endl - 1, "ID"]

			sect = par2[isnothing.(indexin(par2.ID, par1_id)), :]
			sect1 = sect[1:start, :]
			sect2 = sect[(endl - lengt + 1):600, :]
			sect3 = vcat(sect1, child)
			sect3 = vcat(sect3, sect2)
			#println(size(sect3))
			push!(temp_genomes, sect3)
		end

		samps = 1:n_gs
		set1 = Set(recom)
		mutates = [x for x in samps if x ∉ set1]
		mutated = []

		shuf = mutates
		set2 = mutated
		shuf = [x for x in shuf if x ∉ set2]
		println("iteration $i")
		for y in 1:length(shuf)
			push!(temp_genomes, genomes[shuf[y]][shuffle(1:end), :])
		end

		needed = n_gs - length(temp_genomes)
		tem = dists
		sort!(tem)
		for g in 1:needed
			distance = tem[g]
			index = findall(x->x==distance, dists)[1]
			push!(temp_genomes, genomes[index])
		end

		for w in 1:n_gs
			probm = rand()
			if probm <= mutate_prob
				r1 = rand(1:1000)
				r2 = rand(1:1000)
				temp_row = deepcopy(temp_genomes[w][r1, :])
				temp_genomes[w][r2, :] = temp_genomes[w][r2, :]
				temp_genomes[w][r1, :] = temp_row
			end
		end

		genomes = temp_genomes
		for z in 1:n_gs
			genomes[z] = get_dist(genomes[z])
			push!(temp_dists, 1)
			temp_dists[z] = sum(genomes[z].dist_to_next)
		end
		dists = temp_dists
		mind = minimum(dists)
		mindi = argmin(dists)

		if mind < short_dists[end]
			push!(short_dists, mind)
			push!(short_iters, i+2)
			push!(shortest_df, genomes[mindi])
			println("new shortest distance acquired at iteration $i")
		end

	end
	return short_dists, short_iters, shortest_df
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


	short_dists, short_iters, shortest_df = ga_loop(genomes, dists, short_dists, short_iters, shortest_df, n_gs)

	push!(short_dists, short_dists[end])
	push!(short_iters, n_gs + 1)
	frs = shortest_df[end][1, :]::DataFrameRow{DataFrame,DataFrames.Index}
	push!(shortest_df[end], frs)

	println("loop ended!")

	println("shortest distance found was: $(short_dists[end])")

	CSV.write("C://Users//ahhua//Documents//jl_ga_shortest.csv", shortest_df)
	ga_short_csv = DataFrame(short_iters = short_iters, short_dists = short_dists)
	CSV.write("C://Users//ahhua//Documents//jl_ga_short_csv.csv", ga_short_csv)

	gr()
	plot(short_iters, short_dists, linetype =:steppost, label = "shortest distance")
	xlabel!("iterations")
	ylabel!("distance")
	title!("genetic algorithm")
	return "Completed algorithm"::String
end
