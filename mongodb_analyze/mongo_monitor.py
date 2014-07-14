#!/usr/bin/env python
# author: stefan_bo

import urllib2
import sys
import json

def url_encode(port):
	return str(int(port) + 1000)

parameters = sys.argv[1:]

ipaddr = parameters[0]
port = parameters[1]
section = parameters[2]
key = parameters[3:]

# url encode
url = 'http://%s:%s/_status' % (ipaddr, url_encode(port)) 

# json encode
json_obj = urllib2.urlopen(url, timeout=5).read()

serverStatus = json.loads(json_obj)['serverStatus']

if len(key) == 1:
	print serverStatus[section][key[0]]
else:
	print serverStatus[section][key[0]][key[1]]