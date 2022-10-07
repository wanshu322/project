# File name: A0401GoldbachDeuce_v1.0.py
# Author: Wanshu Wang
# Student ID# 1818536
# Date: 02.01.2021
# DSC 430 Assignment 0401
# Honor Statement:
# I have not given or received any unauthorized assistance on this assignment
# Video link: https://youtu.be/ySKk8d5jHW8


import random
def CreateRadomList(length):
    """generate a list of integers ranging in(0,100)
       arg: length is the length of the list
    """
    List = []
    for i in range(0,length):   # running time O(n)
        random_int = random.randint(0, 100)
        List.append(random_int)
    return List
 
def BinarySearch(num_List, num2): # running time O(log(n))
     """Binary search
        arg: num_List: a sorted list of integers
             num2: the number needed to search for
        return: if num2 in the list, return the index of num2
                else: return -1
     """
     low = 0
     high = len(num_List) - 1
     while low <= high:       # There is still a range to search
        mid = int((low + high)/2 )# Position of middle item
        item = num_List[mid]
        if num2 == item:        # Found it! Return the index
            return mid
        elif num2 < item:       # num2 is in lower half of range
            high = mid - 1   #  move top marker down
        else:                # num2 is in upper half of range
            low = mid + 1    #  move bottom marker up
     return -1                # No range left to search,
                             # num2 is not there

def ifHaveSum(num_List, sumNum):
    """ Find out if there are a pair of numbers in the list which sum to sumNum
        input: num_List: the original list of integers
             sumNum: sum
        return: if there is, return the index of the numbers [index1, index2]
                else, return none
            """
    index2 = -1
    length = len(num_List)
    num_List.sort()
    num_min = num_List[0]       #get the minimum number in the list
    num_max = num_List[length-1] #get the maximum number in the list
    if sumNum  < num_min or sumNum > num_max + num_List[length-2]: return None  #The sum is more than the sum of the two biggest numbers in the list. in this case, it is impossible to find two numbers sum to sumNum
    else: 
        for index1 in range(0,length):   #travel from the minimum number         *** running time O(n)
              num2 = sumNum - num_List[index1]  #find out if the number 2 is in the list
              if num2 < num_min or num2 > num_max:  #if the number is fewer than min or more than max, we know it isn't in the list without searching
                  return None
              else: 
                 index2 = BinarySearch(num_List,num2)   #running time O(log(n))
              if index2!=-1:  #if find this number in the list
                 return [index1, index2]
              else: continue
        return None

def main():
    while True:
        exit = input("Do you want to start? Y/N ")
        if exit not in ['Y','N','y','n']:   #check if the input is valid
               print('Please enter letter Y or letter N') #ask to enter a valid input
               continue        
        elif  exit in ['Y','y']: # Yes - to start

            #start 
            length = int(input("What is the length of your list? Please enter an integer:  "))
            sumNum = int(input("What is the sum? Please enter an integer:  "))
            num_List = CreateRadomList(length)  # running time O(n)
            print("The list is: ",*num_List) 
            if sumNum < 201:  #the max sum could be 201 with the list item range is [0,100]
               res_List = ifHaveSum(num_List,sumNum) #running time O(n.log(n))
            #print result
               if res_List != None: 
                  print("We found a pair of numbers in the list sum to ", sumNum,"." )
                  print(num_List[res_List[0]], "+", num_List[res_List[1]], "=", sumNum, ".")
               else: print("There is not any pair numbers which can sum to", sumNum,".")
            else: print("There is not any pair numbers which can sum to", sumNum,".")
            continue


        
        elif exit in ['N','n']: 
            break

if __name__ == "__main__":
  main()