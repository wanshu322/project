# File name: A0702OverlappingEllipses_v1.0.py
# Author: Wanshu Wang
# Student ID# 1818536
# Date: 02.23.2021
# DSC 430 Assignment 0702
# Honor Statement:
# I have not given or received any unauthorized assistance on this assignment
# Video link: https://youtu.be/j5NpK1qvnjE


import random
import os
import math
from statistics import mean 
import time
import turtle



class Point():
    'a Point class that takes the x and y coordinates of the point'

    def __init__(self, x=0,y=0):
         self.x = x
         self.y = y

    def __repr__(self):
        'canonical string representation Point()'
        return 'Point({},{})'.format(self.x,self.y)


class Ellipse():
    'an Ellipse class that takes two points and the width of the long axis'
    def __init__(self, p1=Point(0,0),p2=Point(0,0),laxis = 0):
         self.p1 = p1
         self.p2 = p2
         self.laxis = laxis

    def __repr__(self):
        'canonical string representation Ellipse()'
        return 'Ellipse({},{},{})'.format(self.p1,self.p2,self.laxis)



class  WarAndPeacePseudoRandomNumberGenerator():
    'generate random numbers by using war-and-peace.txt' 
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
               cOne = self.MyReadCharacter()
        
            elif cOne < cTwo:
                #set bit = 0
                self.bitsList[i] = 0
                i = i+1
                #read the next cOne
                cOne = self.MyReadCharacter()
            else: 
                continue
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

def twoPointDistance(p1,p2):
    'a function that takes two ellipses and returns the area of the overlap'
    d=math.sqrt((p1.x-p2.x)**2 + (p1.y-p2.y)**2)
    return d

def getPF1PF2(point, ecllipse):
    ' the sum of the distances between point and the two focus points of ecllipse'
    PF1PF2 = twoPointDistance(point,ecllipse.p1) + twoPointDistance(point,ecllipse.p2) 
    return PF1PF2

def computeOverlapOfEllipses(e1,e2):
    'a function that takes two ellipses and returns the area of the overlap'
    #get the box t-top, b-bottom, l-left, r-right
    xlist = [e1.p1.x, e1.p2.x, e2.p1.x, e2.p2.x]
    ylist = [e1.p1.y, e1.p2.y, e2.p1.y, e2.p2.y]
    wlist = [e1.laxis, e2.laxis]
    l = min(xlist) - max(wlist)/2
    r = max(xlist) + max(wlist)/2
    t = max(ylist) + max(wlist)/2
    b = min(ylist) - max(wlist)/2
    #area of the Box
    areaBox = (r-l)*(t-b)

    #generate N random points within with the range of box
    N = 10000
    pointBox = [Point()]*N
    PF1PF2_e1   = [0]*N    # record the sum of distances between point and two focus point of e1
    PF1PF2_e2   = [0]*N    # record the sum of distances between point and two focus point of e2
    #overLapPoints = list()
    num_pointOverlap = 0 #the number of point in overlap
    
    rpng = WarAndPeacePseudoRandomNumberGenerator()
    temp_point = Point()
    for i in range(0,N):
        #generate points in the box
        temp_point.x = l + (r - l)*rpng.random()
        temp_point.y = b + (t - b)*rpng.random()
        pointBox[i] = temp_point

        #if this point's  position
        PF1PF2_e1[i] = getPF1PF2(pointBox[i], e1) #get the the sum of the distances between point and the two focus points of ellipse 1
        PF1PF2_e2[i] = getPF1PF2(pointBox[i], e2) #get the the sum of the distances between point and the two focus points of ellipse 2
    

        # if this point in overLap 
        if PF1PF2_e1[i] <= e1.laxis and PF1PF2_e2[i] <= e2.laxis: 
            num_pointOverlap = num_pointOverlap +1

    #calculate the area of overlap
    overlap = num_pointOverlap*areaBox/N
    return overlap





def OverLapPrint(e1,e2):
    'a function to draw the overlap'
    #get the box t-top, b-bottom, l-left, r-right
    xlist = [e1.p1.x, e1.p2.x, e2.p1.x, e2.p2.x]
    ylist = [e1.p1.y, e1.p2.y, e2.p1.y, e2.p2.y]
    wlist = [e1.laxis, e2.laxis]
    l = min(xlist) - max(wlist)/2
    r = max(xlist) + max(wlist)/2
    t = max(ylist) + max(wlist)/2
    b = min(ylist) - max(wlist)/2
    #generate N random points within with the range of box
    N = 10000
    rpng = WarAndPeacePseudoRandomNumberGenerator()
    temp_point = Point()
    #draw the plain
    wn = turtle.Screen()
    drawingT = turtle.Turtle()
    wn.setworldcoordinates(l,b,r,t)

    
    for i in range(0,N):
        #generate points in the box
        temp_point.x = l + (r - l)*rpng.random()
        temp_point.y = b + (t - b)*rpng.random()

        #if this point's  position
        PF1PF2_e1 = getPF1PF2(temp_point, e1)
        PF1PF2_e2 = getPF1PF2(temp_point, e2)

        drawingT.up()
        drawingT.goto(temp_point.x,temp_point.y)

        # if this point in overLap 
        if PF1PF2_e1 <= e1.laxis:
            if PF1PF2_e2 <= e2.laxis: 
                drawingT.color("blue")
            else: #in e1, not in e2
                drawingT.color("red")
        else: 
            if PF1PF2_e2 <= e2.laxis:#in e2, not in e1
                drawingT.color("yellow")
            else: #not in e1, not in e2
                drawingT.color('gray')
        drawingT.dot()
    wn.exitonclick()




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

              #declare an object of class WarAndPeacePseudoRandomNumberGenerator with a seed
              prng2 = WarAndPeacePseudoRandomNumberGenerator(seed)

              N= 10000 #generate N random numbers
              rlist = [0.0]*N  # a list of N random number
              
              #create two ecllipses
              '''x1 = -1
              y1 = 1
              x2 = -1
              y2 = -1
              x3 = 1
              y3 = 1
              x4 = -3
              y4 = -2
              w1 = 8
              w2 = 8'''
              #two circles with r = 2, area should be pi*4 = 12.57
              x1 = 0
              y1 = 0
              x2 = 0
              y2 = 0
              x3 = 0
              y3 = 0
              x4 = 0
              y4 = 0
              w1 = 4
              w2 = 4

              f1 = Point(x1,y1)
              f2 = Point(x2,y2)
              e1 = Ellipse(f1, f2, w1)
              f3 = Point(x3,y3)
              f4 = Point(x4,y4)
              e2 = Ellipse(f3, f4, w2)
              print("The case of two circles:")
              print("e1:",e1)
              print("e2:",e2)
              overlap = computeOverlapOfEllipses(e1,e2)
              print("The area of e1 and e2 is:",overlap)


              # The plot is for this case
              #N = 1000 
              f1 = Point(9,5)
              f2 = Point(4,1)
              e1 = Ellipse(f1, f2, 9)
              f3 = Point(2,6)
              f4 = Point(6,3)
              e2 = Ellipse(f3, f4, 8)
              print("The case of two ellipses:")
              print("e1:",e1)
              print("e2:",e2)
              overlap = computeOverlapOfEllipses(e1,e2)
              print("The area of e1 and e2 is:",overlap)

              #OverLapPrint(e1,e2)

              del prng2  #detructor object, close file
              


             
                  






        elif exit in ['N','n']:  #exit the program
            break

if __name__ == "__main__":
  main()

