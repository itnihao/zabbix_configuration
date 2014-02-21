#!/usr/bin/env python
# -*- coding:utf-8 -*-

import os, sys
from nginx_analyze import nginx_analyze

parameters = sys.argv[1:]
nginx_etc_path = '/etc/nginx/sites-enabled'
file_list = os.listdir(nginx_etc_path)
results = 0

def conf_list_ana(key, line_read):
	return [temp.split() for temp in line_read if key in temp.split()][0]

for file in file_list:
	index = open(os.path.join(nginx_etc_path, file), 'r').read().split('\n')
	access_log = conf_list_ana('access_log', index)[1].replace(';', '')
	
	ab = nginx_analyze(access_log, parameters[0])
	results += ab.analyze()
	
print results