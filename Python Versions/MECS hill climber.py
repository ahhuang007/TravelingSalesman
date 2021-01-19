# -*- coding: utf-8 -*-
"""
Created on Sun Sep 22 22:33:24 2019

@author: Andy Huang
"""

import pandas as pd
import numpy as np

import matplotlib.pyplot as plt

#reading data
data = pd.read_csv("C://Users//MSI//Downloads//tsp.txt", sep = "	", header = None) 
data.columns = ["x", "y"]

#Format dataframe for processing

#Assign each row an ID number
data["ID"] = data.index
#Create column that calculates distance from point in current row to point in next row

data["distance_to_next"] = 0.0

#Calculate total distance and store as variable
def get_dist(df):
    tempdf = df
    tempdf = tempdf.iloc[1:]    
    first_row = tempdf.iloc[0]
    tempdf = tempdf.append(first_row)
    tempdf = tempdf.reset_index(drop = True)
    df = df.reset_index(drop = True)

    df["distance_to_next"] = np.sqrt( (tempdf["x"] - df["x"])**2 + (tempdf["y"] - df["y"])**2 )
    
    return df

#total distance
new_data = get_dist(data)
total_dist = sum(new_data["distance_to_next"])
#set variable for extreme distances
shortest_dist = total_dist
longest_dist = total_dist
#Create something to hold total distance values
short_dists = []
short_dists.append(total_dist)
short_iters = []
short_iters.append(1)
shortest_df = new_data
long_dists = []
long_dists.append(total_dist)
long_iters = []
long_iters.append(1)
longest_df = new_data
l_index = 0
s_index = 0
#Hill climber search algorithm (use nested for loop)
end = 1000
for i in range(0, end):
    #ith row will be "row to optimize"
    l_index = i
    s_index = i
    for j in range(end):
        #jth row will be the "swapee" to see if new dataframe is shorter path
        #Current issue, swapping not functioning correctly
        s_current_row = shortest_df.iloc[i].copy()
        s_swap_row = shortest_df.iloc[j].copy()
        l_current_row = longest_df.iloc[i].copy()
        l_swap_row = longest_df.iloc[j].copy()
        shortest_df.iloc[i] = s_swap_row
        shortest_df.iloc[j] = s_current_row
        longest_df.iloc[i] = l_swap_row
        longest_df.iloc[j] = l_current_row
        
        longest_df = get_dist(longest_df)
        shortest_df = get_dist(shortest_df)
        long_sum = sum(longest_df["distance_to_next"])
        short_sum = sum(shortest_df["distance_to_next"])
        #Compare new distance to previous, keep new value if better
        #comparison for shortest path
        if short_sum < shortest_dist:
            #Recording data if new distance is shorter
            short_dists.append(short_sum)
            short_iters.append((((i) * end) + j + 1))
            shortest_dist = short_sum
            #Keeping track of index
            s_index = j
            print("new shortest distance acquired at iteration " + str(((i) * end) + j + 1))
        if long_sum > longest_dist:
            long_dists.append(long_sum)
            long_iters.append((((i) * end) + j + 1))
            longest_dist = long_sum
            l_index = j
            print("new longest distance acquired at iteration " + str(((i) * end) + j + 1))
        #Revert back to original dataframe
        shortest_df.iloc[i] = s_current_row
        shortest_df.iloc[j] = s_swap_row
        longest_df.iloc[i] = l_current_row
        longest_df.iloc[j] = l_swap_row
        
    #After cycling through each iteration, update dataframes with optimal row
    s_old_row = shortest_df.iloc[i].copy()
    s_new_row = shortest_df.iloc[s_index].copy()
    l_old_row = longest_df.iloc[i].copy()
    l_new_row = longest_df.iloc[l_index].copy()
    shortest_df.iloc[i] = s_new_row
    shortest_df.iloc[s_index] = s_old_row
    longest_df.iloc[i] = l_new_row
    longest_df.iloc[l_index] = l_old_row
#After loop, gather points and plot
        
#To make plot look better and not truncated, and to make salesman return home

short_dists.append(shortest_dist)
short_iters.append(1000000)
shortest_df.append(shortest_df.iloc[0])
long_dists.append(longest_dist)
long_iters.append(1000000)
longest_df.append(longest_df.iloc[0])

print("loop ended!")

shortest_df.to_csv('C://Users//MSI//Documents//hill_climber_shortest.csv')
longest_df.to_csv('C://Users//MSI//Documents//hill_climber_longest.csv')
hc_short_csv = pd.DataFrame(data={"short_iters": short_iters, "short_dists": short_dists}) 
hc_long_csv = pd.DataFrame(data = {"long_iters": long_iters, "long_dists": long_dists})
hc_short_csv.to_csv('C://Users//MSI//Documents//hc_short_csv.csv')
hc_long_csv.to_csv('C://Users//MSI//Documents//hc_long_csv.csv')

#Showing distance changes
plt.figure(0, figsize=(8, 6))
plt.step(short_iters, short_dists, where = 'post', label = 'shortest distance')
plt.step(long_iters, long_dists, where = 'post', label = 'longest distance')
plt.xlabel("iterations")
plt.ylabel("distance")
plt.legend(title = "max/min distance")
plt.title("hill climber algorithm")
plt.show()

#Showing actual paths
plt.figure(1, figsize=(16, 12))
plt.plot(shortest_df["x"], shortest_df["y"])
plt.xlabel("x")
plt.ylabel("y")
plt.title("shortest path")
plt.show()

plt.figure(2, figsize=(16, 12))
plt.plot(longest_df["x"], longest_df["y"])
plt.xlabel("x")
plt.ylabel("y")
plt.title("longest path")

plt.show()