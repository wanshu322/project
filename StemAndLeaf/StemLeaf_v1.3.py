# DSC 430 A0202
# File name: StemLeaf_v1.3.py
# Author: Wanshu Wang
# Student ID# 1818536
# Date: 01.20.2021
# Honor Statement:
# I have not given or received any unauthorized assistance on this assignment
# Video link: https://youtu.be/0m3phrX-CgQ

import math
def getInputs():
    """get the number of the file
       return int nFile"""
    while True:
        try:
            nFile = int(input("Please choose a file: 1, 2, 3 or 4  "))
        except ValueError: continue
        if nFile in [1,2,3,4]: break
        else: continue
    return nFile

def readFile(nFile):
    """read the certain File to get the data
    arg: int nFile
    return: List[int] dataList"""
    
    if nFile == 1: filename = "/Users/wanshuwang/Documents/CSDS/DS/DSC430/Assignment/A02/StemAndLeaf1.txt"
    elif nFile == 2: filename = "/Users/wanshuwang/Documents/CSDS/DS/DSC430/Assignment/A02/StemAndLeaf2.txt"
    elif nFile == 3: filename = "/Users/wanshuwang/Documents/CSDS/DS/DSC430/Assignment/A02/StemAndLeaf3.txt"
    elif nFile == 4: filename ="/Users/wanshuwang/Documents/CSDS/DS/DSC430/Assignment/A02/StemAndLeaf4.txt"
    else: filename = None
    infile = open(filename, "r") 
    lineList = infile.readlines() 
    dataList = [""]*len(lineList)
    i = 0
    while i in range ( 0, len(lineList) ):  #read data to dataList
            try:
              dataList[i] = int(lineList[i].strip()) 
              i = i+1
            except ValueError: 
              dataList = [0] #not valid data
              break
    if dataList == [0]:  
        print("This is not a valid file. Please choose another one. ")
    infile.close()
    return dataList


def findMinStem(dataList,nLeaf):
    """ to find the minimum number of the Stem number list 
    """
    if findNumDigits(dataList[0])<= nLeaf: # if the minimum number has less nLeaf number of digits, set MinS ZERO
        MinS ="0"
    else:  MinS = deleteNLowDigit(dataList[0], nLeaf)   #get the minimum number in Stem
    return str(MinS)


def findMaxStem(dataList,nLeaf):
    """ to find the maximum number of the Stem number list 
    """
    N = len(dataList)
    nDigits = findNumDigits(dataList[N-1])
    MaxS = deleteNLowDigit(dataList[N-1], nLeaf)   #get the maimum number in Stem
    #MaxS = deleteNLowDigit(dataList[N-1], nLeaf)   #get the maimum number in Stem
    return str(MaxS)

def findNumDigits(n):
    """ to find the number of the digits of a number
        return digits
    """
    if n > 0:
        digits = int(math.log10(n))+1
    elif n == 0:
        digits = 1
    else:
        digits = int(math.log10(-n))+2 # +1 if you don't count the '-'
    return digits


def getDigitN(number, N):
    'get the n-th digit number(from right to left)'
    return int(number // 10**(N-1) % 10  )

def getDigitN2(number,N):
    'get the n-th digit to 1st digit number(from right to left)'
    strDigits = ""
    while N>0:
        n= getDigitN(number,N)
        strN = str(n)
        strDigits = strDigits + strN
        N=N-1
    return strDigits

def deleteNLowDigit(number,n):
    'delete the n loweset digit number, return string strDigits'
    number = number/10**n
    return int(number)

def findStemList(MinS, MaxS):
    'generate the Stem List (string list)'
    nMinS = int(MinS)
    nMaxS = int(MaxS)
    StemList = [""]*(nMaxS-nMinS+1)
    for i in range (0, nMaxS-nMinS+1):
       StemList[i] = str(nMinS+i)
    return StemList
    



def findLeafList(dataList, StemList,nLeaf):
    """ get the Leaf list
        agr: list(int) dataList, list(str) StemList, int nLeaf
    """
    LeafList = [""] * len(StemList)
    matchDigits = ""
    #if nLeaf ==1 
    if nLeaf == 1:
      for j in range (0, len(StemList)):
        for i in range (0, len(dataList)):
           digit = getDigitN(dataList[i], nLeaf)  #get the leaf string
           matchDigits = str(deleteNLowDigit(dataList[i],nLeaf))
           if matchDigits == StemList[j]:  #match the stem
               LeafList[j]=LeafList[j]+str(digit)+" "
    else: #nLeaf !=1
         count = 0 
         for i in range (0, len(dataList)):
           for j in range (0, len(StemList)):  
             nDigits = findNumDigits(dataList[i])
             if nDigits > nLeaf: # if the number of digits of the current number less than nLeaf, set it as the leaf of the Stem "0"digit = getDigitN(dataList[i], nLeaf)  #get the leaf string
                digit = getDigitN2(dataList[i], nLeaf)  #get the leaf string
                matchDigits = str(deleteNLowDigit(dataList[i],nLeaf))
                if matchDigits == StemList[j]:  #match the stem
                   LeafList[j]=LeafList[j]+str(digit)+" "
             else:
                if j==0: 
                    LeafList[0]=LeafList[0]+"0"*int(nLeaf - nDigits)+str(dataList[i])+" "
            
    return LeafList



def printStemLeaf(dataList):
    """ to print out the Stem Leaf display
        arg: List[int]
    """
    LeafList = list()
    StemList = list()

    #decide the digits in stem
    dataList.sort()    #sort the dataList ascending 
    print("Sorted Data:\n",dataList)
    #print(type(dataList))
    nMaxDigits = 0
    nMinDigits = 0
    N = len(dataList)
    nMaxDigits = findNumDigits(dataList[N-1])     #get the number of digits of the maximum number in the list
    nMinDigits = findNumDigits(dataList[0])       #get the number of digits of the minimum number in the list
    #nMedDigits = findNumDigits(dataList[int(N/2)])
    #set the leaf digit ONE, compute the MinS-the minimum number in Stem, MaxS - the maximum number in Stem 
    #nLeaf = 1 # set the default number of leaf is ONE

    #update version
    #set nLeaf adaptable
    d = (dataList[N-1]-dataList[0])/N-1 # get the averange difference
    if d > 100: 
        nLeaf = math.log10(d)
        nLeaf = round(nLeaf,0)
    else: nLeaf = 1
     

    #find MinS & MaxS
    MinS = findMinStem(dataList,nLeaf)
    MaxS = findMaxStem(dataList,nLeaf)  #get the maximum number in Stem
    StemList = findStemList(MinS,MaxS)  #get the stem List
    LeafList = findLeafList(dataList, StemList,nLeaf)  #get the Leaf List
    
    #print stem and leaf
    print("Stem Leaf Display: ")
    for i in range ( 0, len(StemList) ): 
        print(StemList[i],"|", LeafList[i])




def main():
    while True:
        exit = input("Do you want to start? Y/N ")
        if exit not in ['Y','N','y','n']:   #check if the input is valid
               print('Please enter letter Y or letter N') #ask to enter a valid input
               continue        
        elif  exit in ['Y','y']: # Yes - to start
          print("Choose the file to create Stem-Leaf display! ")  #Greetings
          nFile = getInputs()
          dataList = readFile(nFile)
          if dataList != [0]: 
              printStemLeaf(dataList)
          continue
        elif exit in ['N','n']: 
          break



if __name__ == "__main__":
    main()
   
