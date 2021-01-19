# -*- coding: utf-8 -*-
"""
Created on Sun Sep 29 18:04:47 2019

@author: Andy Huang
"""

import matplotlib.pyplot as plt
import pandas as pd

#importing ALL OF THE CSVS
rs_short_dists = pd.read_csv('C://Users//MSI//Documents//rs_short_csv.csv')
rs_long_dists = pd.read_csv('C://Users//MSI//Documents//rs_long_csv.csv')
rs_short = pd.read_csv('C://Users//MSI//Documents//random_search_shortest.csv')
rs_long = pd.read_csv('C://Users//MSI//Documents//random_search_longest.csv')
hc_short_dists = pd.read_csv('C://Users//MSI//Documents//hc_short_csv.csv')
hc_long_dists = pd.read_csv('C://Users//MSI//Documents//hc_long_csv.csv')
hc_short = pd.read_csv('C://Users//MSI//Documents//hill_climber_shortest.csv')
hc_long = pd.read_csv('C://Users//MSI//Documents//hill_climber_longest.csv')
ga_short_dists = pd.read_csv('C://Users//MSI//Documents//genetic_short_csv.csv')
ga_long_dists = pd.read_csv('C://Users//MSI//Documents//genetic_long_csv.csv')
ga_short = pd.read_csv('C://Users//MSI//Documents//genetic_shortest.csv')
ga_long = pd.read_csv('C://Users//MSI//Documents//genetic_longest.csv')
thc_short_dists = pd.read_csv('C://Users//MSI//Documents//thc_short_csv.csv')
thc_long_dists = pd.read_csv('C://Users//MSI//Documents//thc_long_csv.csv')
thc_short = pd.read_csv('C://Users//MSI//Documents//true_hill_climber_shortest.csv')
thc_long = pd.read_csv('C://Users//MSI//Documents//true_hill_climber_longest.csv')
sdot = pd.read_csv('C://Users//MSI//Documents//sdot.csv')
ldot = pd.read_csv('C://Users//MSI//Documents//ldot.csv')

#Plot data was changed with what was needed for the plot

#Distance/Path plots
plt.figure(0, figsize=(8, 6))
plt.xscale("log")
plt.step(rs_short_dists["short_iters"], rs_short_dists["short_dists"], where = 'post', label = 'Random Search')
plt.step(hc_short_dists["short_iters"], hc_short_dists["short_dists"], where = 'post', label = 'Brute Force')
plt.step(ga_short_dists["short_iters"], ga_short_dists["short_dists"], where = 'post', label = 'Genetic Algorithm')
plt.step(thc_short_dists["short_iters"], thc_short_dists["short_dists"], where = 'post', label = 'Hill Climber')
plt.xlabel("iterations")
plt.ylabel("distance")
plt.legend(title = "Search Methods")
plt.title("TSP Shortest Distance Comparisons")
plt.show()

plt.figure(1, figsize=(8, 6))
plt.xscale("log")
plt.step(rs_long_dists["long_iters"], rs_long_dists["long_dists"], where = 'post', label = 'Random Search')
plt.step(hc_long_dists["long_iters"], hc_long_dists["long_dists"], where = 'post', label = 'Brute Force')
plt.step(ga_long_dists["long_iters"], ga_long_dists["long_dists"], where = 'post', label = 'Genetic Algorithm')
plt.step(thc_long_dists["long_iters"], thc_long_dists["long_dists"], where = 'post', label = 'Hill Climber')
plt.xlabel("iterations")
plt.ylabel("distance")
plt.legend(title = "Search Methods")
plt.title("TSP Longest Distance Comparisons")
plt.show()

#Learning plots
plt.figure(2, figsize=(16, 12))
plt.plot(thc_short["x"], thc_short["y"])
plt.xlabel("X")
plt.ylabel("Y")
plt.title("TSP Shortest Path (Hill Climber Method)")
plt.show()

plt.figure(3, figsize=(16, 12))
plt.plot(thc_long["x"], thc_long["y"])
plt.xlabel("X")
plt.ylabel("Y")
plt.title("TSP Longest Path (Hill Climber Method)")
plt.show()

#Dot plot
plt.figure(4, figsize=(8,6))
#plt.xscale("log")
plt.scatter(sdot["x"], sdot["y"], s = 2)
plt.xlabel("Iterations")
plt.ylabel("Path distance")
plt.title("TSP Hill Climber Shortest Path Dot Plot")
plt.show()

plt.figure(5, figsize=(8,6))
#plt.xscale("log")
plt.scatter(ldot["x"], ldot["y"], s = 2)
plt.xlabel("Iterations")
plt.ylabel("Path distance")
plt.title("TSP Hill Climber Longest Path Dot Plot")
plt.show()