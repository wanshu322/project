# File name: A1002BC_Plot_v1.0.py
# Author: Wanshu Wang
# Student ID# 1818536
# Date: 03.16.2021
# DSC 430 Assignment 1002
# Honor Statement:
# I have not given or received any unauthorized assistance on this assignment
# Video link: 



import os
import pandas as pd
import matplotlib.pyplot as plt 
import numpy as np

def main():
    os.chdir('/Users/wanshuwang/Documents/CSDS/DS/DSC430/Assignment/A10') 
    d = pd.read_csv('BC_WeeklyData1.csv')  
    fig, ax = plt.subplots()
    ax3 = ax.twinx()
    rspine = ax3.spines['right']
    rspine.set_position(('axes',1.15))
    ax3.set_frame_on(True)
    ax3.patch.set_visible(False)
    fig.subplots_adjust(right=0.7)
    d.BiggWealth.plot(ax = ax, style = "r-",xlabel='Week',ylabel = 'Amount',legend = True,use_index = True)
    d.BribeAmount.plot(ax = ax, style = "g-",xlabel='Week',ylabel = 'Amount',title='The personal wealth of Mr. Bigg and the total amount of bribes given to detectives',legend = True,use_index = True)
    
    
    fig, ax = plt.subplots()
    ax3 = ax.twinx()
    rspine = ax3.spines['right']
    rspine.set_position(('axes',1.15))
    ax3.set_frame_on(True)
    ax3.patch.set_visible(False)
    fig.subplots_adjust(right=0.7)
    d.JailedNum.plot(ax = ax, style = "y-",xlabel='Week',ylabel = 'Number',legend = True,use_index = True)
    d.ActorsNum.plot(ax = ax, style = "b-",xlabel='Week',ylabel = 'Number',title='The number of thieves/lieutenants jailed \n and the total size of Mr. Bigg’s criminal syndicate, excluding those jailed',legend = True,use_index = True)
    plt.show() 

if __name__ == "__main__":
  main()
      