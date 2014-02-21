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

# read the nginx configuration
def conf_list_ana(key, line_read):
	return [temp.split() for temp in line_read if key in temp.split()][0]


for file in file_list:
	index = open(os.path.join(nginx_etc_path,file),'r').read().split('\n')
	access_log = conf_list_ana('access_log', index)[1].replace(';','')
	server_name = conf_list_ana('server_name', index)[1].replace(';','')
	listen_port = conf_list_ana('listen', index)[1].replace(';','')

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