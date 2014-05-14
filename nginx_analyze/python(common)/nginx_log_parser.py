#!/usr/bin/env python
# -*- coding:utf-8 -*-  
# author: stefanmonkey
# date:   2014/02/19


import sys, os

filepath = sys.argv[1:]
print filepath
traffic = 0

def format_size(size):
    '''格式化流量单位'''
    KB = 1024 ** 2          #KB -> B  B是字节
    MB = 1024 ** 3        	#MB -> B
    GB = 1024 ** 4	     	#GB -> B
    TB = 1024 ** 5  		#TB -> B
    if size >= TB :
        size = str(size / TB) + 'T'
    elif size < KB :
        size = str(size) + 'B'
    elif size >= GB and size < TB:
        size = str(size / GB) + 'G'
    elif size >= MB and size < GB :
        size = str(size / MB) + 'M'
    else :
        size = str(size / KB) + 'K'
    return size

if len(filepath) > 1:
	sys.exit(1)

url_dic = {}
f = open(filepath[0], 'r')
while True:
	line = f.readline()
	if len(line) == 0:
		break
	temp = line.split()
	traffic += int(temp[9])
	url = temp[6]
	if url not in url_dic.keys():
		url_dic[url] = traffic
	elif url in url_dic.keys():
		url_dic[url] += traffic
	else:
		pass
f.close()

result = sorted(url_dic.iteritems(), key = lambda asd:asd[0])

for i in url_dic.keys():
	url_dic[i] = format_size(url_dic[i])


print result
