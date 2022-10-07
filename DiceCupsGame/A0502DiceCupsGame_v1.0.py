# File name: A0502DiceCupsGame_v1.0.py
# Author: Wanshu Wang
# Student ID# 1818536
# Date: 02.10.2021
# DSC 430 Assignment 0502
# Honor Statement:
# I have not given or received any unauthorized assistance on this assignment
# Video link: https://youtu.be/5gi1HnlekOk


import random
class SixSidedDie():
    "class reprent a six sided die"
    def __init__(self):
        'initialize face_value in range (1,6)'
        self.N = 6 # face value range: [1,N]
        self.face_value = random.randint(1,self.N)

    def roll(self):
        face_value = random.randint(1,self.N)
        return self.face_value 

    def getFaceValue(self):
        return self.face_value


    def __repr__(self):
        'canonical string representation SixSideDie()'
        return 'SixSidedDie({})'.format(self.face_value)

       
class TenSidedDie(SixSidedDie): 
    """class reprent a ten sided die
    inheirts roll(), getFaceValue() from class SixSideDie"""
    def __init__(self):
        'initialize face_value in range (1,10)'
        self.N = 10 # face value range: [1,N]
        self.face_value = random.randint(1,self.N)

    def __repr__(self):
        'canonical string representation TenSideDie()'
        return 'TenSidedDie({})'.format(self.face_value)

class TwentySidedDie(SixSidedDie): 
    """class reprent a twenty sided die
      inheirts roll(), getFaceValue() from class SixSideDie"""
    def __init__(self):
        'initialize face_value in range (1,20)'
        self.N = 20 # face value range: [1,N]
        self.face_value = random.randint(1,self.N)
        
    def __repr__(self):
        'canonical string representation TwentySideDie()'
        return 'TwentySidedDie({})'.format(self.face_value)

class Cup():
    """class reprent a cup"""
    def __init__(self,num_SixSidedDie=1,num_TenSidedDie=1,num_TwentySidedDie=1):#the default number of each kind of die is 1
        'initialize num_SixSidedDie, num_TenSidedDie, num_TwentySidedDie'
        self.num_SixSidedDie = num_SixSidedDie
        self.num_TenSidedDie = num_TenSidedDie
        self.num_TwentySidedDie = num_TwentySidedDie
        self.num_sum = num_SixSidedDie+num_TenSidedDie+num_TwentySidedDie

        #initialize die classes
        self.s6 = [SixSidedDie()]*self.num_SixSidedDie 
        self.s10 = [TenSidedDie()]*self.num_TenSidedDie
        self.s20 = [TwentySidedDie()]*self.num_TwentySidedDie


    def roll(self):
        'roll each kind of dice and get the sum'
        self.sum =0
        for i in range(0,self.num_SixSidedDie):#roll all the six sided dice and #get the sum 
            self.sum += self.s6[i].roll()

        for i in range(0,self.num_TenSidedDie):#roll all the ten sided dice and #get the sum 
            self.sum += self.s10[i].roll()

        for i in range(0,self.num_TwentySidedDie):#roll all the twenty sided dice and #get the sum 
            self.sum += self.s20[i].roll()

        return self.sum

    def getSum(self):
        "get the sum of all the dice in the cup"
        self.sum = 0
        for i in range(0,self.num_SixSidedDie):#get the sum of face value of all six sided dice
            self.sum += self.s6[i].getFaceValue()
        for i in range(0,self.num_TenSidedDie):#get the sum of face value of all ten sided dice
            self.sum += self.s10[i].getFaceValue()
        for i in range(0,self.num_TwentySidedDie):#get the sum of face value of all twenty sided dice
            self.sum += self.s20[i].getFaceValue()
        return self.sum


    def __repr__(self):
        'canonical string representation Cup()'
        "SixSidedDie(3),TenSidedDie(5),TenSidedDie(3),TwentySidedDie(17)"
        
        return 'Cup('+ ('{},'*self.num_sum).format(*self.s6, *self.s10, *self.s20) +')'

def main():
    while True:
        exit = input("Do you want to start? Y/N ")
        if exit not in ['Y','N','y','n']:   #check if the input is valid
               print('Please enter letter Y or letter N') #ask to enter a valid input
               continue        
        elif  exit in ['Y','y']: # Yes - to start        
            
              #start
              #greeting
              user_name=input("Welcome to Dice and Cups Game! Please enter your name first: ")
              print("Hello,",user_name, ".You have 100 dollars in your balance.")
              balance_amount = 100
              print("We will set a radom number between 0 and 100 as the goal. You may roll the dice and try to make a sum of rolling result close to the goal!")
              
              
              #primary loop
              while True: 
                  start_play = input("Do you want to play? Y/N ")
                  if exit not in ['Y','N','y','n']:   #check if the input is valid
                       print('Please enter letter Y or letter N') #ask to enter a valid input
                       continue        
                  elif  exit in ['Y','y']: # Yes - to start  
                      
                      
                      #Input bet amount 
                      print("Great! Let's play! ")
                      goal_num = random.randint(1,100)
                      print("Your current balance is :$",balance_amount,".The rolling goal is",goal_num,"now.")
                      while True:
                          bet_amount = int(input("How much would you like to bet? Please enter a number between 0 and 100: "))
                          if bet_amount>0 and bet_amount <=100:
                             balance_amount = balance_amount - bet_amount
                             print("Thank you. Your current balance is $:",balance_amount)
                             break
                          else: continue #ask user to enter again if the bet is out of range

                      #Input how many dice for each kind
                      num_s6 = int(input("Thank you. We have three kinds of dice. Six sided, ten sided, and twenty sided. How many six sided dice do you want to roll? "))
                      num_s10 = int(input("How many ten sided dice do you want to roll? "))
                      num_s20 = int(input("How many twenty sided dice do you want to roll? "))
                      user_cup = Cup(num_s6,num_s10,num_s20)#create a cup with the above numbers
                      
                      
                      #Roll all the dice in the cup
                                            
                      user_sum = user_cup.roll() 
                      print("The sum of your rolling is :", user_sum, " .")



                      # check out the result and show the balance 
                      if user_sum == goal_num:              #If the rolling result exactly matches the goal, the user receives 10x bet
                          balance_amount = balance_amount + 10*bet_amount
                          print("Congratulations, ",user_name," !" ,"The sum matches the goal! You have $",10*bet_amount," added in your balance. Your current balance is :$",balance_amount," .")
                          continue

                      elif abs(user_sum - goal_num) <= 3:   #if the rolling result is within 3 of the goal but not over, the user receives 5x bet 
                          balance_amount = balance_amount + 5*bet_amount
                          print("Congratulations, ",user_name," !" ,"The sum is within 3 of the goal! You have $",5*bet_amount," added in your balance. Your current balance is :$",balance_amount," .")
                          continue
                      elif abs(user_sum - goal_num) <= 10:  #if the rolling result is within 10 of the goal but not over, the user receives 5x bet 
                          balance_amount = balance_amount + 2*bet_amount
                          print("Congratulations, ",user_name," !" ,"The sum is within 10 of the goal! You have $",2*bet_amount," added in your balance. Your current balance is :$",balance_amount," .")
                          continue
                      else: 
                          #if the rolling result is over 10 of the goal
                          if balance_amount>0:
                              print("Oh, bad luck, ",user_name," you lose your bet. Your current balance is $",balance_amount, " .")
                              continue
                          else: 
                              print("Oh, bad luck, ",user_name," you lose your bet. You have no balance.")
                              break


                        
                          
                      
                      




                  elif exit in ['N','n']: 
                       print("See you next time. ")
                       break
              
              
                      
                 
        
        elif exit in ['N','n']: 
            break

if __name__ == "__main__":
  main()