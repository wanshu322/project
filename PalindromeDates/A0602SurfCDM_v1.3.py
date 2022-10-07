# File name: A0602SurfCDM_v1.1.py
# Author: Wanshu Wang
# Student ID# 1818536
# Date: 02.10.2021
# DSC 430 Assignment 0602
# Honor Statement:
# I have not given or received any unauthorized assistance on this assignment
# Video link: 


import time



import re
from urllib.parse import urljoin
from html.parser import HTMLParser
from urllib.request import urlopen
from urllib import request
from urllib.request import urlopen, Request
import operator
from nltk.corpus import stopwords







class Collector(HTMLParser):
    'collects hyperlink URLs into a list'

    def __init__(self, url):
        'initializes parser, the url, and a list'
        HTMLParser.__init__(self)
        self.url = url
        self.links = []
        self.data = str()

    def handle_starttag(self, tag, attrs):
        'collects hyperlink URLs in their absolute format'
        N = len('https://law.depaul.edu')
        N = len('https://law.depaul.edu/library/about/Pages')
        if tag == 'a':
            for attr in attrs:
                if attr[0] == 'href':
                    # construct absolute URL
                    absolute = urljoin(self.url, attr[1])
                    #if absolute[:4] == 'http': # collect HTTP URLs
                    #restricted search
                    
                    #if absolute[:N] == 'https://law.depaul.edu':
                    if absolute[:N] == 'https://law.depaul.edu/library/about/Pages':
                    #if absolute[:4] == 'http':
                        self.links.append(absolute)
    def getLinks(self):
        'returns hyperlinks URLs in their absolute format'
        return self.links


    def handle_data(self, data):
         self.data = request.urlopen(self.url).read().decode("utf-8").lower()

     




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

       textDataParser =MyTextDataParser()
       textDataParser.feed(content)
       TextData = textDataParser.data

       #remove stop words in TextData_str -> TextData_str
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
       print(f"It runs {toc - tic: 0.4f}")

       return wordlist



class MyTextDataParser(HTMLParser):
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
        


frequency_allpages = {}

def analyze_wordFrequency(url):
    
    print('\n\nVisiting', url)           # for testing

    # obtain links in the web page
    content = urlopen(url).read().decode("utf-8")
    collector = Collector(url)
    collector.feed(content)
    urls = collector.getLinks()          # get list of links

    # compute word frequencies
    content = collector.data
    #content_str = listToString(content)
    freq = frequency(content)
    

    tic = time.perf_counter()
    global frequency_allpages
    for word in freq.keys():
        if word not in frequency_allpages.keys(): 
              #invert the word into frequency_allpages
               frequency_allpages[word] = freq[word] 
        else: 
            frequency_allpages[word] = frequency_allpages[word] +freq[word] 
    toc = time.perf_counter()
    print(f"word in freq.keys() runs {toc - tic: 0.4f}")

    
    
    print(freq)
  

    return urls



visited = {}

def crawl2(url):
    '''a recursive web crawler that calls analyze()
       on every visited web page'''

    # add url to set of visited pages
    global visited     # warns the programmer 
    #visited.add(url)
    visited[url] = 1
   

    # analyze() returns a list of hyperlink URLs in web page url 
    links= analyze_wordFrequency(url)
    print(links)
    # recursively continue crawl from every link in links
    for link in links:
        # follow link only if not visited
        if link not in visited.keys():
            try:
                crawl2(link)
            except:
                pass


def main():




    #exercise web crawler
    tic = time.perf_counter()
    #crawl2('http://reed.cs.depaul.edu/lperkovic/two.html')
    crawl2('https://law.depaul.edu/library/about/Pages/default.aspx')
    #crawl2('https://www.cdm.depaul.edu/Student-Resources/Pages/Current-Students.aspx')
    
    #crawl2('https://law.depaul.edu')
    toc = time.perf_counter()
    print(f"It runs {toc - tic: 0.4f}")

    N = 25 #find top 25 high frequncey words
    frequency_allpages_sorted = dict(sorted(frequency_allpages.items(), key = operator.itemgetter(1), reverse = True)[:N]) 
    print('Top 25 words and the frequncy: ')
    print(frequency_allpages_sorted)
    

    
    
   


       

if __name__ == "__main__":
  main()





  