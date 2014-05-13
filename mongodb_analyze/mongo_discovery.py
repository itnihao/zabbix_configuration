#!/usr/bin/env python
# -*- coding:utf-8 -*-

import json
import subprocess
import os

mongo_conf_dir='/home/mongodb'
conf_file = [conf_f for conf_f in os.listdir(mongo_conf_dir) if 'conf' in conf_f]

conf_port_list = []
port_list = []

for conf in conf_file:
	for line in open(os.path.join(mongo_conf_dir, conf)).readlines():
		if 'port' in line:
			conf_port_list.append(line.split('=')[1].strip())


net_cmd = '''netstat -nltu|awk '{print $4}'
'''

p = subprocess.Popen(net_cmd, shell=True, stdout=subprocess.PIPE)
net_result = p.stdout.readlines()



for port in conf_port_list:
	for net in net_result:
		if port.strip() in net:
			port_list.append(port)

json_data = {"data": []}

for port in port_list:
        dic_content = {
        "{#MONGO_PORT}":  port.strip()
        }

        json_data['data'].append(dic_content)

result = json.dumps(json_data)
print result