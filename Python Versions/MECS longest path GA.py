# -*- coding: utf-8 -*-
"""
Created on Sun Sep 29 19:54:47 2019

@author: MSI
"""

import pandas as pd
import numpy as np
from sklearn.utils import shuffle
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


#Make new starting population here
#Must also initiate groupings here
genomes = []
dists = []
#One iteration = one sample
for q in range(50):
        
    new_df = shuffle(data)
    new_df = get_dist(new_df)
    genomes.append(new_df)
    dists.append(sum(new_df["distance_to_next"]))

data = get_dist(data)
total_dist = sum(data["distance_to_next"])
longest_dist = total_dist
#Create something to hold total distance values

long_dists = []
long_dists.append(total_dist)
long_iters = []
long_iters.append(1)
longest_df = data


#Now we have our starting populations and their total distances - the evolution begins
mutate_prob = 0.75
iters = 3000
for n in range(iters):
    temp_genomes = []
    temp_dists = []
    avg_fit = sum(dists) / 50
    
    #list of samples that will recombine
    recom = []
    
    #determining whether the sample will recombine
    for m in range(50):
        prob = dists[m] / avg_fit
        
        if prob >= 1:
            recom.append(m)
        else:
            num = random.random()
            if num <= prob:
                recom.append(m)
        
    
    #RECOMBINATION
    #length of data string taken from parent 1
    length = 400
    recombines = int(len(recom) - 1)
    
    for p in range(recombines):
        par1 = genomes[p]
        rando = random.randint(0, recombines)
        if rando == p:
            rando = random.randint(0, recombines)
        par2 = genomes[rando]
        
        start = random.randint(0, 599)
        end = start + length
       
        child = par1.iloc[start:end]
        child = child.reset_index(drop = True)
        #Need to delete all ID's from par2 that overlap with section from par1
        par1_id = list(par1[start:end]["ID"])
        
        
        sect = par2[~par2["ID"].isin(par1_id)]
        
        sect = sect.reset_index(drop = True)
        sect1 = sect.iloc[0:start].reset_index(drop = True)
        sect2 = sect.iloc[(end - 400):600].reset_index(drop = True)
        sect3 = sect1.append(child)
        sect3 = sect3.append(sect2)
        new_seq = sect3.reset_index(drop = True)
        temp_genomes.append(new_seq)
    
    #Now handle other samples
    samps = list(range(0, 50))
    set1 = set(recom)
    mutates = [x for x in samps if x not in set1]
    mutated = []
    
    
    #Completely random shuffle the rest
    shuf = mutates
    set2 = mutated
    shuf = [x for x in shuf if x not in set2]
    print("iteration " + str(n))
    for y in range(len(shuf)):
        temp_genomes.append(shuffle(genomes[shuf[y]]))
    
    #Duplicate best samples from generation to get back up to 50
    needed = 50 - len(temp_genomes)
    tem = dists
    tem.sort(reverse = False)
    for g in range(needed):
        distance = tem[g]
        index = dists.index(distance)
        temp_genomes.append(genomes[index])
    
    #Mutate new genomes (maybe)
    for w in range(50):
        probm = random.random()
        #Probability of mutation is 0.75
        if probm <= 0.75:
            r1 = random.randint(0, 999)
            r2 = random.randint(0, 999)
            row1 = temp_genomes[w].iloc[r1].copy()
            row2 = temp_genomes[w].iloc[r2].copy()
            temp_genomes[w].iloc[r2] = row1
            temp_genomes[w].iloc[r1] = row2
        
    #Evaluate new sequences, save improvements for plotting
    genomes = temp_genomes
    for z in range(50):
        genomes[z] = get_dist(genomes[z])
        temp_dists.append(1)
        temp_dists[z] = sum(genomes[z]["distance_to_next"])
    dists = temp_dists
    
    maxd = max(dists)
    maxdi = np.argmax(dists)
   
    if maxd > longest_dist:
        long_dists.append(maxd)
        long_iters.append(n + 2)
        longest_dist = maxd
        longest_df = genomes[maxdi]
        print("new longest distance acquired at iteration " + str(n + 2))
    
        
#To make plot look better and not truncated
long_dists.append(longest_dist)
long_iters.append(iters + 1)
longest_df.append(longest_df.iloc[0])
print("loop ended!")

#Showing actual paths

print("longest distance found was: " + str(longest_dist))

longest_df.to_csv('C://Users//MSI//Documents//genetic_longest.csv')
genetic_long_csv = pd.DataFrame(data={"long_iters": long_iters, "long_dists": long_dists}) 
genetic_long_csv.to_csv('C://Users//MSI//Documents//genetic_long_csv.csv')

