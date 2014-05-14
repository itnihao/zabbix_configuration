#!/usr/bin/env python
# -*- coding:utf-8 -*-

import json
import subprocess

mem_cmd = '''ps -ef|grep memcache|grep -v 'grep'|awk -F"-p" '{print $2}'|awk '{print $1}'
'''

json_data = {"data": []}

def os_cmd(command):
	p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
	return p.stdout.readlines()

port_list = os_cmd(mem_cmd)
net_result = os_cmd('netstat -nlt')

for port in port_list:
	for net in net_result:
		if port.strip() in net:
			ipaddr = net.split()[3].split(':')[0]
        
	dic_content = {
	"{#MEM_PORT}":  port.strip(),
	"{#MEM_IPADDR}": ipaddr
	}

	json_data['data'].append(dic_content)

result = json.dumps(json_data)
print result