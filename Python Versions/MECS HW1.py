# -*- coding: utf-8 -*-
"""
Created on Fri Sep 20 17:08:39 2019

@author: Andy Huang
"""

import pandas as pd
import numpy as np
from sklearn.utils import shuffle
import matplotlib.pyplot as plt
import time

start = time.time()

#reading data
data = pd.read_csv("C://Users//ahhua//Downloads//tsp.txt", sep = "	", header = None) 
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
#Random search algorithm (use for/while loop)
end = 5000000
for i in range(0, end):
    
    
    #Map new sequence to dataframe, recalculate distances
    new_data = shuffle(data)
    new_data = get_dist(new_data)
    new_dist = sum(new_data["distance_to_next"])
    #Compare new distance to previous, keep new value if better
    if new_dist < shortest_dist:
        short_dists.append(new_dist)
        short_iters.append(i + 1)
        shortest_dist = new_dist
        shortest_df = new_data
        print("new shortest distance acquired at iteration " + str(i + 2))
    if new_dist > longest_dist:
        long_dists.append(new_dist)
        long_iters.append(i + 1)
        longest_dist = new_dist
        longest_df = new_data
        print("new longest distance acquired at iteration " + str(i + 2))

#After loop, gather points and plot
        
#To make plot look better and not truncated, and to make salesman return home
short_dists.append(shortest_dist)
short_iters.append(end + 1)
shortest_df.append(shortest_df.iloc[0])
long_dists.append(longest_dist)
long_iters.append(end + 1)
longest_df.append(longest_df.iloc[0])

print("loop ended!")

shortest_df.to_csv('C://Users//ahhua//Documents//random_search_shortest.csv')
longest_df.to_csv('C://Users//ahhua//Documents//random_search_longest.csv')
rs_short_csv = pd.DataFrame(data={"short_iters": short_iters, "short_dists": short_dists}) 
rs_long_csv = pd.DataFrame(data = {"long_iters": long_iters, "long_dists": long_dists})
rs_short_csv.to_csv('C://Users//ahhua//Documents//rs_short_csv.csv')
rs_long_csv.to_csv('C://Users//ahhua//Documents//rs_long_csv.csv')


#Showing distance changes
plt.figure(0, figsize=(8, 6))
plt.step(short_iters, short_dists, where = 'post', label = 'shortest distance')
plt.step(long_iters, long_dists, where = 'post', label = 'longest distance')
plt.xlabel("iterations")
plt.ylabel("distance")
plt.legend(title = "max/min distance")
plt.title("random search algorithm")
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

end = time.time()
print(end - start)
plt.show()



