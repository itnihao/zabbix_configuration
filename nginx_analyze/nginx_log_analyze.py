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

#######################################################
# coding begin
#######################################################

import sys
import time, datetime

class nginx_analyze(object):
	
	def __init__(self, filepath, parameters):
		''' 
		init the value status value, request times, traffic
		'''
		self.filepath = filepath
		self.parameters = parameters
		
		self.status_dic = {}
		self.traffic = 0
		self.requests = 0
		

	def analyze(self):
		'''
		In [113]: line
		Out[113]: '111.73.46.31 - - [19/Feb/2014:08:39:04 +0800] "GET http://www.google.com/ HTTP/1.0" 200 7893 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"\n'

		In [115]: line.split('[')
		Out[115]: 
		['111.73.46.31 - - ',
 		'19/Feb/2014:08:39:04 +0800] "GET http://www.google.com/ HTTP/1.0" 200 7893 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"\n']

		In [118]: line.split('[')[1].split()[0]
		Out[118]: '19/Feb/2014:08:39:04'
		
		So time is line.split('[')[1].split()[0]

		In [114]: line.split('"')[2].split()
		Out[114]: ['200', '7893']
		
		So 
		status is line.split('"')[2].split()[0], 
		traffic is line.split('"')[2].split()[1]
		'''
		for line in open(self.filepath,'r'):
			if self._time_process(line):
				temp = line.split('"')[2].split()
				self.traffic += int(temp[1])
				self.requests += 1
				st = temp[0]

				if st not in self.status_dic:
					self.status_dic[st] = 1
				else:
					self.status_dic[st] += 1

		if self.parameters == 'traffic':
			print self.traffic
		elif self.parameters == 'requests':
			print self.requests
		elif self.parameters in self.status_dic:
			print self.status_dic[self.parameters]
		elif self.status_dic == {}:
			print 0
		else:
			print 0
			#print 'usages : xxx.py filepath parameters '
			#print 'parameter like traffic/requests/200/404/...'



	def _time_process(self, line):
		now = datetime.datetime.now()
		timedelta = datetime.timedelta(minutes=5)
		
		timestr = line.split('[')[1].split()[0]
		times_temp = time.strptime(timestr,  '%d/%b/%Y:%H:%M:%S')
		timestamp = datetime.datetime(times_temp[0], times_temp[1], times_temp[2], times_temp[3], times_temp[4], times_temp[5])

		if  now - timestamp <= timedelta:
			return True
		else:
			return False


m = sys.argv[1:]
if len(m) == 2:
	ab = nginx_analyze(m[0],m[1])
	ab.analyze()
else:
	print 'parameters number must be two'

