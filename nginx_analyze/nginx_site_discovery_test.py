#!/usr/bin/env python
# -*- coding:utf-8 -*-

import os
import json

nginx_etc_path = '/etc/nginx/sites-enabled'
file_list = os.listdir(nginx_etc_path)
json_data = {"data": []}

'''
In [14]: index = x.split('\n')

In [15]: access_log = [temp.split() for temp in index if 'access_log' in temp.split()]

In [16]: access_log
Out[16]: [['access_log', '/var/log/nginx/localhost.80.access.log;']]

In [17]: server_name = [temp.split() for temp in index if 'server_name' in temp.split()]

In [18]: server_name
Out[18]: [['server_name', 'localhost;']]

In [19]: listen_port = [temp.split() for temp in index if 'listen' in temp.split()]

In [20]: listen_port
Out[20]: [['listen', '80', 'default;']]
'''

class conf_parse(object):

	def __init__(self, infile_path, infile, keyword):
		self.infile_path = infile_path
		self.infile = infile
		self.keyword = keyword


	def procedure(self):
		read_list = open(os.path.join(self.infile_path, self.infile), 'r').read().split('\n')
		mid_list = [test for test in read_list if not test.startswith('#') and test != '']

		result = [test.split() for test in mid_list if self.keyword in test.split()]

		if result != []:
			return result[0][1].replace(';', '')
		else:
			return 'null'


for file in file_list:
	access_log = conf_parse(nginx_etc_path, file, 'access_log')
	server_name = conf_parse(nginx_etc_path, file, 'server_name')
	listen_port = conf_parse(nginx_etc_path, file, 'listen')

	dic_content = {
	"{#ACCESS_LOG}":  access_log,
	"{#SERVER_NAME}": server_name,
	"{#LISTEN_PORT}": listen_port
	}

	json_data['data'].append(dic_content)

''' the output result like fit zabbix require
{
    "data": [
        {
            "{#LISTEN_PORT}": "80",
            "{#SERVER_NAME}": "localhost",
            "{#ACCESS_LOG}": "/var/log/nginx/localhost.80.access.log"
        }
    ]
}
'''

result = json.dumps(json_data)
print result