# File name: A0701RadomNumbers_v1.0.py
# Author: Wanshu Wang
# Student ID# 1818536
# Date: 02.23.2021
# DSC 430 Assignment 0701
# Honor Statement:
# I have not given or received any unauthorized assistance on this assignment
# Video link: https://youtu.be/SQGBEbXz5aM


import random
import os
import math
from statistics import mean 
import time


class  WarAndPeacePseudoRandomNumberGenerator():
    
    def __init__(self,seed=1000):
      'initialize a random value'
      self.step = 100
      self.bitsList = [0]*32
      self.seed = seed
      self.num = 0
      #open a file 
      self.WarPeaceFile = open('war-and-peace.txt','rb')
       # read seed = 1000, into the file, get a letter
      self.WarPeaceFile.seek(self.seed)
      self.numOfNull = 0
      
      

    def random(self):
        "return the random number"
        #read First Character as cOne
        cOne = self.WarPeaceFile.read(1)
        self.num = 0
        i=0
        while i<32:
            #read Character Two as cTwo
            cTwo = self.MyReadCharacter()
            if cOne > cTwo:
               #set bit = 1
               self.bitsList[i] = 1
               i = i+1
               #read the next cOne
               
        
            elif cOne < cTwo:
                #set bit = 0
                self.bitsList[i] = 0
                i = i+1
                #read the next cOne
                
            else: 
                continue
            cOne = self.MyReadCharacter()
            #calculate the random number
            self.num  = self.num + self.bitsList[i-1]*math.pow(0.5,i)
            
            
        
        return self.num
   

    def MyReadCharacter(self):
       "read a next non-null character"
      
       self.WarPeaceFile.seek(self.step,1)
       c = self.WarPeaceFile.read(1)
    
       while c == b'': # when read at the end of file
         #move the cursor to the beginning with a seed when the cursor is at the end of the file
         self.numOfNull = self.numOfNull +1
         self.WarPeaceFile.seek(0,0)
         self.WarPeaceFile.seek(self.seed+self.numOfNull,1)

         #reread a character 
         c = self.WarPeaceFile.read(1)

       #return c if c!= b'' 
       return c



    def __del__(self):
        ' body of destructor'
        #close file
        self.WarPeaceFile.close()


    def __repr__(self):
        'canonical string representation WarAndPeacePseudoRandomNumberGenerator()'
        return 'WarAndPeacePseudoRandomNumberGenerator(seed = {}) = {}'.format(self.seed,self.num)









def main():
    while True:
        exit = input("Do you want to start? Y/N ")
        if exit not in ['Y', 'N', 'y', 'n']:  # check if the input is valid
               # ask to enter a valid input
               print('Please enter letter Y or letter N')
               continue
        elif exit in ['Y', 'y']:  # Yes - to start

              
              # Change the current working directory
              os.chdir('/Users/wanshuwang/Documents/CSDS/DS/DSC430/Assignment/A07')

              
              seed = 1000 # initialize seed 

              #initial an object of class WarAndPeacePseudoRandomNumberGenerator
              #prng1 = WarAndPeacePseudoRandomNumberGenerator()

              #declare an object of class WarAndPeacePseudoRandomNumberGenerator with a seed
              prng2 = WarAndPeacePseudoRandomNumberGenerator(seed)

              N= 10000 #generate N random numbers
              rlist = [0.0]*N  # a list of N random number
              sum = 0     # sum of all the numbers
              for i in range(0,N):    
                  rlist[i] = prng2.random()          # get a random number
                  print("This is ", i-1, "th number:", rlist[i])
                  sum += rlist[i]                    #add this number to the sum
                  
              
              rlist.sort()        #sort the list of random numbers
              minimum_num = rlist[0]
              maximum_num = rlist[N-1]
              mean_list = sum/N

              #print out the minimum, maximum and mean of the list of random numbers
              print(N, "random numbers were generated. \n The minimum is:",minimum_num)
              print("The maximum is:", maximum_num)
              print("The mean is : ", mean_list)
              
              del prng2  #detructor object, close file
              


             
                  






        elif exit in ['N','n']: 
            break

if __name__ == "__main__":
  main()

