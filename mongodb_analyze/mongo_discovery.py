#!/usr/bin/env python
# -*- coding:utf-8 -*-

import json
import subprocess
import os

mongo_conf_dir='/home/mongodb'
conf_file = [conf_f for conf_f in os.listdir(mongo_conf_dir) if 'conf' in conf_f]

para_list = []


for conf in conf_file:
	dict_temp = {}
	for line in open(os.path.join(mongo_conf_dir, conf)).readlines():
		if 'port' in line:
			dict_temp['port'] = line.split('=')[1].strip()
		if 'bind_ip' in line:
			dict_temp['ipaddr'] = line.split('=')[1].strip()
	para_list.append(dict_temp)


net_cmd = '''netstat -nltu|awk '{print $4}'
'''

p = subprocess.Popen(net_cmd, shell=True, stdout=subprocess.PIPE)
net_result = p.stdout.readlines()

json_data = {"data": []}

for para in para_list:
	for net in net_result:
		if para['port'] in net:
			dic_content = {
    			"{#MONGO_PORT}"  : para['port'],
    			"{#MONGO_IPADDR}" : para['ipaddr']
				}
			
			json_data['data'].append(dic_content)

result = json.dumps(json_data)
print result