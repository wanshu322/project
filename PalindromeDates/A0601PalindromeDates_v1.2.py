# File name: A0601PalindromeDates_v1.2.py
# Author: Wanshu Wang
# Student ID# 1818536
# Date: 02.10.2021
# DSC 430 Assignment 0601
# Honor Statement:
# I have not given or received any unauthorized assistance on this assignment
# Video link: https://youtu.be/gk1mCn899Kg





# This file is going to find all the Palindrome Dates with the given year range
# There is ONE date at most which is in ONE year, because we want the reversed Y1Y2Y3Y4 to be D1D2/M1M2 
# So we firstly find the reverse date in the given year, and then to find out if this date is valid. 

import os

def FindReverseDate(Year):
    """find the reverse date in the given year  YYYY -> DDMM
    arg: Year: int
    return: ReverseDate: str  format: 'DDMM'  """
    ReverseDate = str()
    Year_str = str(Year)
    ReverseDate = Year_str[::-1] #reverse the date string
    return ReverseDate

def ValidateDate(reverseDate):
    """find out if a reverse date is a valid date
    arg: reverseDate  str
    return: True if it is valid, False if it is not valid """
    reverseDD = reverseDate[0] + reverseDate[1] #get the first two digits which are date: DD
    reverseMM= reverseDate[2] + reverseDate[3]  #get the last two digits which are month: MM 


    reverseDD_int = int(reverseDD)
    reverseMM_int = int(reverseMM)
    if reverseMM_int == 2 and reverseDD_int>0 and reverseDD_int<29: #a valid date in Februrary (28days, don't consider a leap year)
        return True
    elif reverseDD_int>0 and reverseDD_int<32 and reverseMM_int >0 and reverseMM_int <13: #a valid date is between 1-31, a valid month between 1-12
        return True
    else: return False #not a valid date





def main():
    while True:
        exit = input("Do you want to start? Y/N ")
        if exit not in ['Y', 'N', 'y', 'n']:  # check if the input is valid
               # ask to enter a valid input
               print('Please enter letter Y or letter N')
               continue
        elif exit in ['Y', 'y']:  # Yes - to start

              # OPTION Setup current working directory
              # print("Current working directory: {0}".format(os.getcwd()))

              # Change the current working directory
              os.chdir('/Users/wanshuwang/Documents/CSDS/DS/DSC430/Assignment/A06')

              while True:
                
                    beginningYear = input("Please enter the beginning year(1000-9999): ") #get beginning and ending years from input
                    endingYear = input("Please enter the ending year(1000-9999): ")
                    beginningYear_int = int(beginningYear)
                    endingYear_int = int(endingYear)
                    
                    dYear = endingYear_int -beginningYear_int  #calculate the difference between beginning and ending

                    if dYear >= 0 and endingYear_int < 10000 and beginningYear_int>=1000:# check out the inputs are valid, this program only supports 4-digit year
                        outfile = open('Dates', 'w')                                     #open a file with write mode

                        for Year in range(beginningYear_int,endingYear_int+1):
                            reverseDate = FindReverseDate(Year) #reverseDate: DDMM
                            if ValidateDate(reverseDate) == True:
                               # Write the Palindrome date into the File
                               strDate = reverseDate[0]+reverseDate[1]+'/'+reverseDate[2]+reverseDate[3] +'/'+str(Year) +'\n' #set the format DD/MM/YYYY
                               outfile.write(strDate)
                        outfile.close()
                        break
                    else: continue

              outfile.close()
              print("PalindromeDates have been written in a text file.")
              Read_str = open('Dates').read()
              print(Read_str)
              outfile.close()

              

        
        elif exit in ['N','n']: 
            break

if __name__ == "__main__":
  main()

