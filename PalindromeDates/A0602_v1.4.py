# File name: A0602SurfCDM_v1.4.py
# Author: Wanshu Wang
# Student ID# 1818536
# Date: 02.10.2021
# DSC 430 Assignment 0602
# Honor Statement:
# I have not given or received any unauthorized assistance on this assignment
# Video link:  https://youtu.be/VKKcKwEg7js

import os
import time
import re
from urllib.parse import urljoin
from html.parser import HTMLParser
from urllib.request import urlopen
from urllib import request
import operator
from nltk.corpus import stopwords
frequency_allpages = {}  #define a global variable to save word frequency for all pages
visited = {}             #define a global variable to record if the link is visited
Nlinks = 0              #record the number of links 






class Collector(HTMLParser):
    'collects hyperlink URLs into a list'

    def __init__(self, url):
        'initializes parser, the url, and a list'
        HTMLParser.__init__(self)
        self.url = url
        self.links = []
        self.data = str()
        self.capture = False

    def handle_starttag(self, tag, attrs):
        'collects hyperlink URLs in their absolute format'
        #N = len('https://law.depaul.edu')
        N = len('https://law.depaul.edu/student-resources/Pages')
        if tag == 'a':
            for attr in attrs:
                if attr[0] == 'href':
                    # construct absolute URL
                    absolute = urljoin(self.url, attr[1])
                    #if absolute[:4] == 'http': # collect HTTP URLs
                    #restricted search#
                    
                    #if absolute[:N] == 'https://law.depaul.edu':
                    if absolute[:N] == 'https://law.depaul.edu/student-resources/Pages':
                    #if absolute[:4] == 'http':
                       
                        self.links.append(absolute)
    def getLinks(self):
        'returns hyperlinks URLs in their absolute format'
        return self.links

    def getData(self):
        #get the content of url
        res = urlopen(self.url)
        res2 = res.read()
        self.data = res2.decode("utf-8")
        return self.data



     




def listToString(s):  
    ' Function to convert a string list into a string'
    # initialize an empty string 
    str1 = " " 
    # return string   
    return (str1.join(s))


def frequency(content):
       '''counts the frequency
       of each word in content'''
       tic = time.perf_counter()

       textDataParser =MyTextDataParser() #extract the text data
       textDataParser.feed(content)
       TextData = textDataParser.data

       #remove stop words
       TextData_str = listToString(TextData)
       TextData_list = re.findall(r'\w+', TextData_str)
       TextData_without_sw_list = [word for word in TextData_list if not word in stopwords.words()]
       
       #check frequency and save it to wordlist(dict)
       wordlist ={}
       for word in TextData_without_sw_list:              
  
          # checking for the duplicacy 
          if word not in wordlist.keys(): 
              #invert the word into wordlist
               wordlist[word] = 1
          else: wordlist[word] = wordlist[word]+1
       toc = time.perf_counter()
       print(f"function frequency runs {toc - tic: 0.4f}")

       return wordlist



class MyTextDataParser(HTMLParser):
    "Extract all the text data"
    def __init__(self):
        super().__init__()
        self.data = []
        self.capture = False

    def handle_starttag(self, tag, attrs):
        if tag in ('p', 'h1','h2','h3','h4','li','ul','a','h5','h6','dt','dd'):
            self.capture = True

    def handle_endtag(self, tag):
        if tag in ('p', 'h1','h2','h3','h4','li','ul','a','h5','h6','dt','dd'):
            self.capture = False

    def handle_data(self, data):
        if self.capture:
            self.data.append(data)
        




def analyze_wordFrequency(url):
    "analyze_wordFrequency() returns a list of hyperlink URLs in web page url"
    
    print('\n\nVisiting', url)           # for testing

    # obtain links in the web page
    tic = time.perf_counter()#timer starts

    res = urlopen(url)
    res2 = res.read()
    content = res2.decode("utf-8")
    collector = Collector(url)
    collector.feed(content)
   
    urls = collector.getLinks()          # get list of links
   

    # compute word frequencies
    content = collector.getData()
    freq = frequency(content)
    

    
    global frequency_allpages   #update word frequencey of the current to the variable frequency_allpages
    for word in freq.keys():
        if word not in frequency_allpages.keys(): 
              #invert the word into frequency_allpages
               frequency_allpages[word] = freq[word] 
        else: 
            frequency_allpages[word] = frequency_allpages[word] +freq[word] 
    
    toc = time.perf_counter()        #timer stops
    print(f"analyze_wordFrequency runs {toc - tic: 0.4f}")
    

    return urls





def crawl2(url):
    '''a recursive web crawler that calls analyze_wordFrequency()
       on every visited web page'''

    # add url to set of visited pages
    global visited     # warns the programmer 
    visited[url] = 1
    global Nlinks
    Nlinks = Nlinks+1
   

    # analyze_wordFrequency() returns a list of hyperlink URLs in web page url 
    links= analyze_wordFrequency(url)
    
    # recursively continue crawl from every link in links
    for link in links:
        # follow link only if not visited
        if link not in visited.keys():
            try:
                crawl2(link)
            except:
                pass


def main():



    os.chdir('/Users/wanshuwang/Documents/CSDS/DS/DSC430/Assignment/A06')
    global Nlinks
    Nlinks = 0 
    #exercise web crawler
    tic = time.perf_counter()
    crawl2('http://reed.cs.depaul.edu/lperkovic/one.html')
    #crawl2('https://law.depaul.edu/student-resources/Pages/default.aspx') # I used student-resources page instead of 'https://law.depaul.edu' for testing. It takes too long for 'https://law.depaul.edu'. 
    
    #crawl2('https://law.depaul.edu')
    toc = time.perf_counter()
    print(f"The entire program runs {toc - tic: 0.4f}")    



    outfile = open('Top25words', 'w')  

    N = 25 #find top 25 high frequncey words
    frequency_allpages_sorted = dict(sorted(frequency_allpages.items(), key = operator.itemgetter(1), reverse = True)[:N]) 
    
    
    print(str(Nlinks) + "   webpages were searched.")
    
    print('Top 25 words and the frequncy: ')
    for key,value in frequency_allpages_sorted.items():  
         print(key+" : "+ str(value))
         outfile.write(key+" : "+ str(value)+'\n')
    outfile.write(str(Nlinks) + " webpages were searched.")
    outfile.close()

if __name__ == "__main__":
  main()





  