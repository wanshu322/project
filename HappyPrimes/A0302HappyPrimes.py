# File name: A0302HappyPrimes.py
# Author: Wanshu Wang
# Student ID# 1818536
# Date: 01.26.2021
# DSC 430 Assignment 0302
# Honor Statement:
# I have not given or received any unauthorized assistance on this assignment
# Video link: https://youtu.be/AbtHC1WzyAU

import math

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
    return int(number // 10**(N-1) % 10)


#define isPrime function
def isPrime(num):
    """ to find out if a number is a prime
    return true or false"""
    for i in range(2,num):
        if (num%i == 0):
            return False
    return True

#define isHappy function
def isHappy(num):
    """ to find out if a number is happy
    return true or false"""
    numDic = {num:True}  #define a temp number dictionary to storage the number that has already been computed
    while(num!=1):
        nDigits = findNumDigits(num)    # get how many digits the number has
        numList = nDigits*[0]           #initiate a list with each digit number
        tempNum = 0                     #initiate a temp number to pass the result to the next number 
        for i in range(0,nDigits):      #in the loop, to get each digit number and sum their square
            numList[i] = getDigitN(num,i+1)
            tempNum = tempNum + numList[i]**2 
        if tempNum == 1: return True    #once the result shows 1, it will return true
        elif tempNum in numDic: return False  # if this number has been already computed before, it means the loop will be endless. It never gets to one. Return false
        else: 
            numDic.update({tempNum:True}) #save the number that has been computed in the temp number dictionary
            num = tempNum               #set the result as the next number to be ready
            continue
       






def main():
   while True:
    #whether it is a happy prime, sad prime, happy non-prime, or sad non-prime.
    num = int(input("Please enter a number: "))
    isprime = isPrime(num)
    ishappy = isHappy(num)
    #print the results
    if isprime == True and ishappy == True: print(num," is a happy prime.")
    elif isprime == True and ishappy == False: print(num," is a sad prime.")
    elif isprime == False and ishappy == True: print(num," is a happy non-prime.")
    else: print(num," is a sad non-prime.")
   
     


if __name__ == "__main__":
    main()