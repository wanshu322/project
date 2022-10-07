# File name: A0902GameofLife_v1.0.py
# Author: Wanshu Wang
# Student ID# 1818536
# Date: 03.09.2021
# DSC 430 Assignment 0902
# Honor Statement:
# I have not given or received any unauthorized assistance on this assignment
# Video link: https://youtu.be/2p8XSQZAers





import numpy as np
import numpy.ma as ma
import matplotlib.pyplot as plt 
from celluloid import Camera


def conway(s,p):
    """generates a board, which is a square two dimensional NumPy array of size s by s. The board should be randomly populated with probability p. """
    board = np.random.random((s,s))
    board_live = ma.masked_where(board <= p,board)#live( <= p) cell value = 1
    board_live = board_live.filled(1)
    board = ma.masked_where(board_live != 1,board_live)#dead cell value = 0
    board = board.filled(0)
            
    return board


def advance(board,t):
    """accepts a Conway board and advances it t time steps """
    [s,s] = board.shape
    board_last = board
    board_cur = board
    for x in range (0,t): # t times of advance

        #rule
        for i in range(0,s):
            for j in range(0,s):
               sum_neighbour = GetNeighbourSum(board_last, i, j)
               if sum_neighbour == 3 and board_last[i,j]!= 1: board_cur[i,j] = 1 #Any dead cell (marked as 0) with exactly three live neighbors becomes a live cell, as if by reproduction.
               elif sum_neighbour <2 and board_last[i,j] == 1:   board_cur[i,j] = 0 # Any live cell (marked as 1) with fewer than two live neighbors dies
               elif sum_neighbour >3 and board_last[i,j] == 1: board_cur[i,j] = 0 #Any live cell (marked as 1) with more than three live neighbors dies
        board_last = board_cur #be ready for next advance

    return board_cur

    

def GetNeighbourSum(board, i, j):
    "Get the eight neighbour elements of the argument element"
    sum_neighbour = 0
    [s,s] = board.shape
    if i >=s-1 or j >=s-1: #adjust the boundrary situation
            i = i - (s-1)
            j = j - (s-1)
    neighbour = [board[i-1, j - 1], board[i,j-1], board[i+1, j+1], board[i-1,j], board[i-1,j+1],board[i,j+1],board[i+1,j],board[i+1,j-1]] #get all eight neighbours as a list
    sum_neighbour = sum(neighbour)   #get the sum of all eight neighbours
    return sum_neighbour 

def displayBoard(board):
    "display the board"
    plt.figure()
    plt.matshow(board)
    plt.show()   
        


def main():
     while True:
        exit = input("Do you want to start? Y/N ")
        if exit not in ['Y','N','y','n']:   #check if the input is valid
               print('Please enter letter Y or letter N') #ask to enter a valid input
               continue        
        elif  exit in ['Y','y']: # Yes - to start   

              s = int(input("Please enter an integer as the dimension of the board: "))
              p = float(input("Please enter a number between 0 and 1 as the probability: "))
              board = conway(s,p)

              print(board)
              t= int(input("Pease enter an integer as the advance times: "))
              board_ad = advance(board,t)
              displayBoard(board_ad)




            

        elif exit in ['N','n']: 
            break
if __name__ == "__main__":
  main()