#!/usr/bin/env python
# -*- coding:utf-8 -*-
import json
import subprocess
import os, sys

redis_port = []
redis_init = [init for init in os.listdir('/etc/init.d/') if 'redis' in init]

for redis in redis_init:
    f = open(os.path.join('/etc/init.d/', redis), 'r').read().split()
    port = [port_temp for port_temp in f if 'redisport'.upper() in port_temp][0]

    redis_port.append(port.split('=')[1].strip('"'))


json_data = {"data": []}


for port in redis_port:
        
	dic_content = {
	"{#REDIS_PORT}":  port.strip()
	}

	json_data['data'].append(dic_content)

result = json.dumps(json_data)
print result