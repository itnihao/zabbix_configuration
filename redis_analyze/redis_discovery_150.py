#!/usr/bin/env python
# -*- coding:utf-8 -*-
import json
import subprocess
import os, sys
import re

def config_parser(conf, para):
	result = []
	input_conf = open(conf, 'r').readlines()

	p = re.compile(r'(^%s (\S)+)' % para)

	for line in input_conf:
		iter = p.finditer(line)
		for m in iter:
			result.append(m.group())

	return result[0]

redis_conf_path = '/etc/redis/'

redis_para = []
redis_conf = [conf for conf in os.listdir(redis_conf_path) if '.conf' in conf]

for conf in redis_conf:
    ipaddr = config_parser(os.path.join(redis_conf_path, conf), 'bind').split()[1]
    port = config_parser(os.path.join(redis_conf_path,conf), 'port').split()[1]
    dict_temp = {'port' : port, 'ipaddr': ipaddr}
    redis_para.append(dict_temp)

json_data = {"data": []}

for para in redis_para:
        
	dic_content = {
	"{#REDIS_PORT}":  para['port'],
	"{#REDIS_IPADDR": para['ipaddr']
	}

	json_data['data'].append(dic_content)

result = json.dumps(json_data)
print result