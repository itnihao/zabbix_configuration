#!/usr/bin/env python
# -*- coding:utf-8 -*-

import json
import subprocess

mem_cmd = '''ps -ef|grep memcache|grep -v 'grep'|awk -F"-p" '{print $2}'|awk '{print $1}'
'''

json_data = {"data": []}

p = subprocess.Popen(mem_cmd, shell=True, stdout=subprocess.PIPE)
port_list = p.stdout.readlines()

for port in port_list:
        dic_content = {
        "{#MEM_PORT}":  port.strip()
        }

        json_data['data'].append(dic_content)

result = json.dumps(json_data)
print result