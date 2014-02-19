#!/usr/bin/env python
# -*- coding:utf-8 -*-  
# author: stefanmonkey
# date:   2014/02/19
'''
 default nginx log format is :
 '$remote_addr - $remote_user  [$time_local]  '
                 ' "$request"  $status  $body_bytes_sent  '
                 ' "$http_referer"  "$http_user_agent" ';
'''

# 记录指定时间段内(5分钟内)请求总数， 统计status状态码个数， nginx流量， 字典存储
# scripts.py log_path parameters 取得结果 

import time , datetime
filepath = '/tmp/access.log'

status = {}
requests = 0
traffic = 0

now = datetime.datetime.now()
timedelta = datetime.timedelta(minutes=5)

for line in open(filepath,'r'):
	'''
	In [113]: line
	Out[113]: '111.73.46.31 - - [19/Feb/2014:08:39:04 +0800] "GET http://www.google.com/ HTTP/1.0" 200 7893 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"\n'

	In [115]: line.split('[')
	Out[115]: 
	['111.73.46.31 - - ',
 	'19/Feb/2014:08:39:04 +0800] "GET http://www.google.com/ HTTP/1.0" 200 7893 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"\n']
	
	In [117]: line.split('[')[1].split()
	Out[117]: 
	['19/Feb/2014:08:39:04',
 	'+0800]',
 	'"GET',
 	'http://www.google.com/',
 	'HTTP/1.0"',
 	'200',
 	'7893',
 	'"-"',
 	'"Mozilla/4.0',
 	'(compatible;',
 	'MSIE',
 	'6.0;',
 	'Windows',
 	'NT',
 	'5.1)"']

	In [118]: line.split('[')[1].split()[0]
	Out[118]: '19/Feb/2014:08:39:04'
	
	So time is line.split('[')[1].split()[0]
	'''
	timestr = line.split('[')[1].split()[0]
	times_temp = time.strptime(timestr,  '%d/%b/%Y:%H:%M:%S')
	timestamp = datetime.datetime(times_temp[0], times_temp[1], times_temp[2], times_temp[3], times_temp[4], times_temp[5])
	if  now - timestamp <= timedelta:
		'''		
		In [114]: line.split('"')[2].split()
		Out[114]: ['200', '7893']
		
		So 
		status is line.split('"')[2].split()[0], 
		traffic is line.split('"')[2].split()[1]

		'''
		temp = line.split('"')[2].split()
		#status = temp[0]		
		traffic += int(temp[1])
		requests += 1

print traffic
print requests
