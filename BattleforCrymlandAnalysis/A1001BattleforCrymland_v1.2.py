# File name: A1001BattleforCrymland_v1.2.py
# Author: Wanshu Wang
# Student ID# 1818536
# Date: 03.16.2021
# DSC 430 Assignment 1001
# Honor Statement:
# I have not given or received any unauthorized assistance on this assignment
# Video link: https://youtu.be/wObGtF8k2Fc

# Update Notes:  1. dynamic reading parameters, using pandas 2. Assumption added: After a lieutenant is arrested, all of his thieves and lieutenants would be deleted, not in jail, not in Bigg's team 3. added some doctrings and comments. 





import random
import os
import pandas as pd


class thief():
    "class reprent a thief"
    def __init__(self, heist_coef = 1000,LieID = 0):
        'initialize parameters'
        self.jailed_status = False 
        self.wealth = 0
        self.value = 0 #heist of this week
        self.heist_coef = heist_coef
        self.LieID = LieID # ID of the lieutenant this thief is under, Bigg ID is 0, initial thief.LieID = Bigg.ID
    def UpdateWealth(self):
        'Update Wealth'
        if self.jailed_status == False: #if not jailed
            self.wealth = self.wealth + 0.5 * self.value
        else: self.wealth = 0
    def getWeeklyValue(self):
        'calculate the heist of this week'
        d = random.randint(1,20)
        self.value = self.heist_coef * (d**2)

        
        

class lieutenant(thief):
    "class reprent a lieutenant, extends class thief"
    def __init__(self,num_thief=7,testimony=3,heist_coef=1000,LieID=0, ID = 1):
        self.jailed_status = False 
        self.wealth = 0
        self.value = 0 #heist of this week
        self.heist_coef = heist_coef
        self.LieID = LieID # ID of the lieutenant this thief is under, Bigg ID is 0, initial thief.LieID = Bigg.ID
        self.thievesList = []*num_thief #all the thieve this lieutenant has, inital is 7
        self.lieutenantList = [] #all the lieutenant this lieutenant has
        self.num_thief = num_thief
        self.num_lie = 0
        self.n_testimony_jail = testimony
        self.n_testimony = 0
        self.ID = ID # the ID of this lieutenant, initial is 1 , Bigg.ID = 0
        self.heist_coef = heist_coef
    
    def init_thievesList(self):
        "initail this new lieutenant's thief list"
        for i in range(0,self.num_thief):
            self.thievesList.append(thief(self.heist_coef,self.ID))
        self.num_thief = len(self.thievesList) 


    def UpdateWealth(self):
        "Update the wealth by calculating the value of this week"
        if self.jailed_status == False: #if not jailed
            self.num_thief  = self.getTheifNum()
            self.num_lie = self.getLieNum()
            
            if self.num_thief !=0:
                for i in range (0,self.num_thief ):
                    self.value = self.value + self.thievesList[i].value * 0.5
            if self.num_lie !=0: 
                 for i in range (0,self.num_lie):
                    self.value = self.value + self.lieutenantList[i].value * 0.5
            
            self.wealth = self.wealth + self.value
            
        else: 
            self.wealth = 0
        
    def UpdateJailedStatus(self):
        'Update Jailed Status'
        num_Jailed = 0
        n_thief = len(self.thievesList) 
        n_lie = len(self.lieutenantList)
        i = 0
        j = 0
        while  num_Jailed< self.n_testimony_jail and (i < n_thief):
            if self.thievesList[i].jailed_status ==  True:  # if any thieves are arrested
                num_Jailed = num_Jailed + 1
            if j < n_lie and self.lieutenantList[j].jailed_status == True: # if any lieutenants are arrested
                num_Jailed = num_Jailed + 1
            i +=1
            j +=1
        self.n_testimony += num_Jailed
        if self.n_testimony >=self.n_testimony_jail: self.jailed_status = True # if n_testimony is more than n_testimony_jail, the rule number
        else: self.jailed_status = False

    def getTheifNum(self):
        'get the number of theives'
        self.num_thief = len(self.thievesList) 
        return self.num_thief 
    def getLieNum(self):
        'get the number of lieutenants'
        self.num_lie = len(self.lieutenantList) 
        return self.num_lie




class Bigg(lieutenant):
    "class reprent the Bigg, extends class lieutenant"
    def __init__(self,num_thief=7,testimony=3,heist_coef=1000,LieID=0, ID = 0):
        self.jailed_status = False 
        self.wealth = 0
        self.value = 0 #heist of this week
        self.heist_coef = heist_coef
        #self.LieID = LieID # ID of the lieutenant this thief is under, Bigg ID is 0, initial thief.LieID = Bigg.ID

        self.thievesList = []*num_thief #all the thieve this lieutenant has, inital is 7
        self.lieutenantList = [] #all the lieutenant this lieutenant has
        self.num_thief = num_thief
        self.num_lie = 0
        self.n_testimony_jail = testimony
        self.n_testimony = 0

        self.week_number = 0
        self.num_lie = 0   # number of lieutenants under Bigg this week, initial is 0
        self.bribe_amount = 0 #
        self.wealth_thisweek = 0
        self.ID = 0


class detective():
    'class detective'
    def __init__(self,solve_prob_init, solve_prob_cap):
        self.solve_prob = solve_prob_init
        self.solve_prob_cap = solve_prob_cap
        self.seizeValue = 0
    def solve(self):
        solve_succeed = False
        if random.random() <= self.solve_prob:
           solve_succeed= True
           self.solve_prob += random.randint(1,10)/100 # experience increases x% 
           if self.solve_prob> self.solve_prob_cap: # self.solve_prob is more than the maximum, set it as the maximum
               self.solve_prob = self.solve_prob_cap

        return solve_succeed

class detectiveBribed(detective):
    'class detectiveBribed, the detective who works for Bigg, extends class detective'
    def __init__(self, detectiveBigg_found_init=0.05):
        'initial parameters'
        self.bribed_discover_prob = detectiveBigg_found_init
        self.discover_status = False
        self.solve_prob = 0
    def found(self):
        'check if he is found weekly'
        if random.random() <= self.bribed_discover_prob: # be found
           self.discover_status = True
       
        else: self.bribed_discover_prob += random.random(1,20)/100 # increase x%
           
        return self.discover_status
    



class StatsWeekly():
    def __init__(self,num_thief,n_testimony,heist_coef):
         self.Bigg_week = Bigg(num_thief,n_testimony,heist_coef,LieID=0, ID = 0)
         self.heist_coef = heist_coef
         self.tot_lie = 0 
         self.tot_thief = self.Bigg_week.num_thief  # number of thieves this week, initial is 7
         self.tot_jailed = 0
         self.amount_bribed = 0
         self.BiggWealth = self.Bigg_week.wealth
         self.thiefList_tot = self.Bigg_week.thievesList
         self.LieList_tot = []
         self.Bigg_Capture = False
         self.n_actors = self.tot_lie + self.tot_thief
         self.num_thief_init = num_thief
    def generateStats(self):
        "generate the stats of this week in file"
        # strStat
        strStat = 'Week#:' + str(self.Bigg_week.week_number) + '\n'+ 'Bigg Jailed Status:' + str(self.Bigg_Capture) + '\n'+ 'Biggs wealth:'+str(self.BiggWealth)+ '\n'+'Jailed number:' +str(self.tot_jailed)+'\n'+ 'Bribe amount:'+str(self.amount_bribed) + '\n'+ 'Actors:'+str(self.n_actors) +'\n'
        return strStat
    def getTot_lie(self):
        'get total number of lieutenants'
        self.tot_lie = len(self.LieList_tot)
        return self.tot_lie
    def getTot_thief(self):
        'get total number of thieves'
        self.tot_thief = len(self.thiefList_tot)
        return self.tot_thief
    def UpdateWealth(self):
        'update wealth'
        self.BiggWealth = self.Bigg_week.wealth
    def getBiggCapture(self):
        'update Biggs jailed status'
        self.Bigg_Capture = self.Bigg_week.jailed_status
        return self.Bigg_Capture
    def NewthiefList(self):
        "add new num_thief to the list because a new lieutenant added"
        id = self.LieList_tot[-1].ID #new lieutenant's ID
        self.thiefList_tot.extend(self.LieList_tot[-1].thievesList)

    def printData(self):
        'print out the data'
        print("Week number:", self.Bigg_week.week_number)
        print("Bigg jailed status: ",self.Bigg_Capture)
        print("Bigg's wealth:", self.BiggWealth)
        print("The total number of jailed: ",self.tot_jailed )
        print("The amount accepted by detectives",self.amount_bribed)
        print("The number of actors:",self.n_actors)
    
    


      

def AllthiefSteal(stats_weekly, num_thief,n_testimony,promotion_wealth):
    "thieve steal weekly, update all the wealth to thieves and check the promotion, update the total number of thieves and lieutenants"
    n = len(stats_weekly.thiefList_tot)
    for i in range(0,n):
            #steal and update the wealth
            stats_weekly.thiefList_tot[i].getWeeklyValue()
            stats_weekly.thiefList_tot[i].UpdateWealth()

            #check theif promotion
            if stats_weekly.thiefList_tot[i].wealth > promotion_wealth:
                new_Lie = lieutenant(num_thief,n_testimony,len(stats_weekly.LieList_tot) + 1)  #this thief becomes a lieutenant
                new_Lie.wealth = stats_weekly.thiefList_tot[i].wealth
                new_Lie.init_thievesList()

                #update the List of Lieutenants_tot in stats_weekly 
                stats_weekly.LieList_tot.append(new_Lie)
                stats_weekly.thiefList_tot.remove(stats_weekly.thiefList_tot[i])
                stats_weekly.NewthiefList() # add new num_thief to the list because they are with a new lieutenant
                stats_weekly.n_actors = stats_weekly.n_actors + 8

                #if new_Lie.LieID == 0: #this new Lieunetant is under Bigg
                  # stats_weekly.Bigg_week.thievesList.remove(stats_weekly.thiefList_tot[i])
                  # stats_weekly.Bigg_week.thievesList.append(new_Lie)

                #update the lieutenants which has this new lieutenant
                id = new_Lie.LieID
                for j in range(stats_weekly.tot_lie): 
                    if id == stats_weekly.LieList_tot[j].ID:
                        stats_weekly.LieList_tot[j].thievesList.remove(stats_weekly.thiefList_tot[i])
              
                        stats_weekly.LieList_tot[j].thievesList.append(new_Lie)

                #update the numbers of Lieutenants and thieves
                stats_weekly.tot_lie = len(stats_weekly.LieList_tot)
                stats_weekly.tot_thief = len(stats_weekly.thiefList_tot)

               
         

    return stats_weekly
           


def lieutenantValueUpdate(stats_weekly):
    "update the wealth to all lieutenants"
    for i in range(0,stats_weekly.tot_lie): # Update each lieutenant
        stats_weekly.LieList_tot[i].UpdateWealth()

        while stats_weekly.LieList_tot[i].num_lie > 0:  # Update each lieutenant under other lieutenant
            for j in range(0,stats_weekly.LieList_tot[i].num_lie):
                stats_weekly.LieList_tot[i].lieutenantList[j].UpdateWealth()
    
    return stats_weekly


def detectiveSolve(DetectiveList,stats_weekly):
    "detective solve, and update the wealth and jailed_status to thieves, lieutenants, and Bigg_week, update the detectives and detectiveBribed"
    #assign thief randomly
    #num = len(DetectiveList)
    
    temp_thiefList = stats_weekly.thiefList_tot
    temp_lieList = stats_weekly.LieList_tot

    loop_time = min(len(DetectiveList), len(temp_thiefList)) #loop time equals the minimum of the number of detectives and the number of thief numbers. eg. if there are 2 thieves, the third detective won't solve anything.
    num_list = random.sample(range(0,loop_time),loop_time)

    for i in range(0,loop_time):
        if DetectiveList[i].solve(): #detective gets the thief
            n = num_list[i]
            stats_weekly.thiefList_tot[n].jailed_status = True #update the thief jailed status
            DetectiveList[i].seizeValue += stats_weekly.thiefList_tot[num_list[i]].wealth 
            #detective seizes the wealth
            stats_weekly.thiefList_tot[num_list[i]].wealth = 0# the wealth of the jailed thief is 0
            stats_weekly.tot_jailed += 1
            stats_weekly.n_actors = stats_weekly.n_actors - 1

            #update testimony  and Lieutenant jailed status
            LieID = stats_weekly.thiefList_tot[num_list[i]].LieID
            if LieID == 0: #is Bigg
                stats_weekly.Bigg_week.n_testimony += 1
                if stats_weekly.Bigg_week.n_testimony>= stats_weekly.Bigg_week.n_testimony_jail: #Bigg is arrested 
                    stats_weekly.Bigg_Capture = True
                    stats_weekly.Bigg_week.jailed_status = True
                    #stats_weekly.BiggWealth = 0
                    stats_weekly.tot_jailed += 1
                    break
                    

            else: # this lieutenant is not Bigg
                for j in range(1,LieID+1):
                  if LieID == stats_weekly.LieList_tot[j].ID:
                    stats_weekly.LieList_tot[j].n_testimony += 1
                    if stats_weekly.LieList_tot[j].n_testimony>=stats_weekly.Bigg_week.n_testimony_jail : # a lieutenant is arrested, detective gets wealth, and remove it from lieList_tot, remove all his lieutenants and thieves from list
                        stats_weekly.LieList_tot[j].jailed_status = True
                        DetectiveList[i].seizeValue += stats_weekly.LieList_tot[j].wealth
                        stats_weekly.LieList_tot[j].wealth = 0 # the wealth of the jailed lieutenant is 0

                        #remove all his lieutenants and thieves from list
                        for l in range(0,len(stats_weekly.LieList_tot[j].thievesList)): #remove
                             temp_thiefList.remove(stats_weekly.LieList_tot[j].thievesList[l])
                        # if he has lieutenant, remove it
                        for l in range(0,len(stats_weekly.LieList_tot[j].lieutenantList)):
                            temp_lieList.remove(stats_weekly.LieList_tot[j].lieutenantList[l])


                        stats_weekly.LieList_tot.remove(stats_weekly.LieList_tot[j])
                        
                        #update numbers of actors and arrested
                        stats_weekly.tot_jailed += 1
                        stats_weekly.tot_lie = stats_weekly.tot_lie - 1
                        stats_weekly.n_actors = stats_weekly.n_actors - 1

            temp_thiefList.remove(stats_weekly.thiefList_tot[num_list[i]])#remove the arrested thief from thievesList_tot
            #stats_weekly.tot_thief = stats_weekly.tot_thief -1 #update the thief number in total
                   
    stats_weekly.thiefList_tot = temp_thiefList #update the thiefList which has removed the arrested thief
    stats_weekly.tot_thief = len(stats_weekly.thiefList_tot)
    stats_weekly.LieList_tot = temp_lieList
    stats_weekly.tot_lie = len(stats_weekly.LieList_tot)

    return stats_weekly



def detectivesBribed(detective_try,stats_weekly,detectiveBigg_found_init,bribe_rate_initial):
    "Bigg bribes detective, update Bigg's wealth and the transfer detective into detectiveBribed"
    bribe_accpeted_prob = 0
    bribe_amount_this = stats_weekly.Bigg_week.value * bribe_rate_initial # calculate the bribe amount for this time

    # try to bribe
    # Step 1: calculate the probability 
    if bribe_amount_this < 10000: bribe_accpeted_prob = 0.05
    elif bribe_amount_this <100000: bribe_accpeted_prob = 0.1
    elif bribe_amount_this <1000000: bribe_accpeted_prob = 0.25
    elif bribe_amount_this <10000000: bribe_accpeted_prob = 0.5

    if random.random() < bribe_accpeted_prob: # bribe succeed, return a new detectiveBribed
       new_d = detectiveBribed(detectiveBigg_found_init)
       return new_d
    else: return detective_try #bribe failed, return the old one



def FindBribed(DetectiveList,solve_init,solve_cap):
    "find out if there is any detective being bribed, and update them to new detective class or keep the status"
    for i in range(0,len(DetectiveList)):
        if type(DetectiveList[i]) == type(detectiveBribed()):# this detective is bribed and works for Bigg
            if DetectiveList[i].found: # this detective is found
               DetectiveList.remove(DetectiveList[i]) #remove the bribed detective who is found
               DetectiveList.append(detective(solve_init,solve_cap))  # add a new detective to the list
    return DetectiveList

def main():
    while True:
        exit = input("Do you want to start? Y/N ")
        if exit not in ['Y','N','y','n']:   #check if the input is valid
               print('Please enter letter Y or letter N') #ask to enter a valid input
               continue        
        elif  exit in ['Y','y']: # Yes - to start  
            
              os.chdir('/Users/wanshuwang/Documents/CSDS/DS/DSC430/Assignment/A10') 
              #initial all the parameters   TO-DO: update by reading from a file
              '''weeks = 500  
              num_thief = 7
              heist_coef = 1000 
              promotion_wealth = 1000000 
              n_detetectives = 3 
              solve_init = 0.25
              solve_cap = 0.75 
              n_testimony = 3
              bribe_init = 1000000
              bribe_rate_initial= 0.1
              detectiveBigg_found_init = 0.05'''
              #P_file = pd.read_csv('Parameters.txt',delimiter =' ')
              #P_file.to_csv('P.csv', index = None)
              P_data = pd.read_csv('P.csv')

              weeks = P_data.iloc[0]['weeks']
              num_thief = int(P_data.iloc[0]['num_thief'])
              heist_coef = P_data.iloc[0]['heist_coef'] 
              promotion_wealth = P_data.iloc[0]['promotion_wealth'] 
              n_detetectives = int(P_data.iloc[0]['n_detetectives'])
              solve_init = P_data.iloc[0]['solve_init']
              solve_cap = P_data.iloc[0]['solve_cap'] 
              n_testimony = P_data.iloc[0]['n_testimony']
              bribe_init = P_data.iloc[0]['bribe_init']
              bribe_rate_initial= P_data.iloc[0]['bribe_rate_initial']
              detectiveBigg_found_init = P_data.iloc[0]['detectiveBigg_found_init']


              #open file
              outfile = open('StatsWeekly.txt', 'w')  

              #initial Bigg
              stats_weekly = StatsWeekly(num_thief,n_testimony,heist_coef)
              stats_weekly.Bigg_week.init_thievesList()
              DetectiveList = [detective(solve_init,solve_cap)]* n_detetectives

              
        
              
              #weekly actions 
              # loop will stop once Bigg is arrested or week up to the limit 
              while stats_weekly.Bigg_Capture == False and stats_weekly.Bigg_week.week_number < weeks:

                  stats_weekly.Bigg_week.week_number += 1  #week number count

                  stats_weekly = AllthiefSteal(stats_weekly, num_thief,n_testimony,promotion_wealth) #thieves steal and promote possibly


                  if stats_weekly.tot_lie !=0:  # if there are lieutenants rather than Bigg
                     stats_weekly = lieutenantValueUpdate(stats_weekly) #lieutenants' wealth update



                  detectiveSolve(DetectiveList,stats_weekly) #detectives solve 
                  
                  if stats_weekly.getBiggCapture() ==False:    # if Bigg is not in jail, update his wealth, attempt to bribe detecttives
                      stats_weekly.Bigg_week.UpdateWealth() #update Bigg's wealth
                      stats_weekly.UpdateWealth()

                      #bribe detectives
                      for j in range(0,n_detetectives):
                          if DetectiveList[j].seizeValue >= bribe_init:

                              #Bigg trys to bribe this detective
                              new_d = detectivesBribed(DetectiveList[j],stats_weekly,detectiveBigg_found_init,bribe_rate_initial)
                              if new_d == DetectiveList[j]: #new detective is changed, bribe succeed, remove the old detective, add a new bribed detective
                                  stats_weekly.amount_bribed += bribe_rate_initial* stats_weekly.Bigg_week.value #update the bribed amount accepted by this detective
                                  stats_weekly.Bigg_week.wealth = stats_weekly.Bigg_week.wealth - bribe_rate_initial* stats_weekly.Bigg_week.value # update the value of Bigg's wealth
                                  stats_weekly.UpdateWealth()
                                  DetectiveList.remove(DetectiveList[j])
                                  DetectiveList.append(new_d)

                              else: DetectiveList[j].seizeValue = 0 #reset the seizeValue

                  
                  
                  #find out the bribed detectives
                  DetectiveList = FindBribed(DetectiveList,solve_init,solve_cap)
                 
                      
                  #record the data
                  stats_weekly.printData()
                  
                  
                  outfile.write(stats_weekly.generateStats())

              


              outfile.close()

        elif exit in ['N','n']: 
             break


if __name__ == "__main__":
  main()
      