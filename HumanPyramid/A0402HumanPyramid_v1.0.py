# File name: A0402HumanPyramid_v1.0.py
# Author: Wanshu Wang
# Student ID# 1818536
# Date: 02.01.2021
# DSC 430 Assignment 0402
# Honor Statement:
# I have not given or received any unauthorized assistance on this assignment
# Video link: https://youtu.be/9lu8ipzyngU



def humanPyramid(row, column): 
    """ 
    A human pyramid is a way of stacking people vertically in a triangle. 
    returns the total weight on that person's back. The row and column show the position where the person is
    """
    weight_total = 0
    if row-1 < 0: weight_total = 0  #base case [0,0]
    elif column - 1<0:
        weight_total = 1/2*(humanPyramid(row-1,column)+128) 
    elif column> row -1: 
        weight_total = 1/2*(humanPyramid(row-1,column-1)+128) 
    elif column -1>=0 and column-1<= row:
        weight_total = 1/2*(humanPyramid(row-1,column-1)+128) + 1/2*(humanPyramid(row-1,column)+128)
    return weight_total



  
def main():
    while True:
        exit = input("Do you want to start? Y/N ")
        if exit not in ['Y','N','y','n']:   #check if the input is valid
               print('Please enter letter Y or letter N') #ask to enter a valid input
               continue        
        elif  exit in ['Y','y']: # Yes - to start        
            
              #start
              row = int(input("Please enter an integer as the row number:  "))
              column = int(input("Please enter an integer as the column number:  "))
              weight_total = humanPyramid(row,column)
              print("The weight on the back of the person who is Row ",row, ", Column ", column, "is ",weight_total, "lbs.")

        
        elif exit in ['N','n']: 
            break

if __name__ == "__main__":
  main()