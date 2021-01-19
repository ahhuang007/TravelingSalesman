# -*- coding: utf-8 -*-
"""
Created on Sun Sep 29 19:25:17 2019

@author: Andy Huang
"""

import pandas as pd
import numpy as np
import random

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
sdotx = []
sdoty = []
ldotx = []
ldoty = []
#Hill climber search algorithm (use nested for loop)
end = 100000
for i in range(end):
    
    n1 = random.randint(0,999)
    n2 = random.randint(0,999)
    s_current_row = shortest_df.iloc[n1].copy()
    s_swap_row = shortest_df.iloc[n2].copy()
    l_current_row = longest_df.iloc[n1].copy()
    l_swap_row = longest_df.iloc[n2].copy()
    shortest_df.iloc[n1] = s_swap_row
    shortest_df.iloc[n2] = s_current_row
    longest_df.iloc[n1] = l_swap_row
    longest_df.iloc[n2] = l_current_row
    longest_df = get_dist(longest_df)
    shortest_df = get_dist(shortest_df)
    long_sum = sum(longest_df["distance_to_next"])
    short_sum = sum(shortest_df["distance_to_next"])
    if i % 1000 == 0:
        sdotx.append(i)
        sdoty.append(short_sum)
        ldotx.append(i)
        ldoty.append(long_sum)
    #Compare new distance to previous, keep new value if better
    #comparison for shortest path
    
    if short_sum < shortest_dist:
        #Recording data if new distance is shorter
        short_dists.append(short_sum)
        short_iters.append(i)
        shortest_dist = short_sum
        print("new shortest distance acquired at iteration " + str(i))
    else:
        #revert
        shortest_df.iloc[n1] = s_current_row
        shortest_df.iloc[n2] = s_swap_row
    if long_sum > longest_dist:
        long_dists.append(long_sum)
        long_iters.append(i)
        longest_dist = long_sum
        print("new longest distance acquired at iteration " + str(i))
    else:
        #revert
        longest_df.iloc[n1] = l_current_row
        longest_df.iloc[n2] = l_swap_row
#After loop, gather points and plot
        
#To make plot look better and not truncated, and to make salesman return home

short_dists.append(shortest_dist)
short_iters.append(end)
shortest_df.append(shortest_df.iloc[0])
long_dists.append(longest_dist)
long_iters.append(end)
longest_df.append(longest_df.iloc[0])

print("loop ended!")

shortest_df.to_csv('C://Users//MSI//Documents//true_hill_climber_shortest.csv')
longest_df.to_csv('C://Users//MSI//Documents//true_hill_climber_longest.csv')
hc_short_csv = pd.DataFrame(data={"short_iters": short_iters, "short_dists": short_dists}) 
hc_long_csv = pd.DataFrame(data = {"long_iters": long_iters, "long_dists": long_dists})
hc_short_csv.to_csv('C://Users//MSI//Documents//thc_short_csv.csv')
hc_long_csv.to_csv('C://Users//MSI//Documents//thc_long_csv.csv')

sdot = pd.DataFrame(data = {"x": sdotx, "y": sdoty})
ldot = pd.DataFrame(data = {"x": ldotx, "y": ldoty})
sdot.to_csv('C://Users//MSI//Documents//sdot.csv')
ldot.to_csv('C://Users//MSI//Documents//ldot.csv')

