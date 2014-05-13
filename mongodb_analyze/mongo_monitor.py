#!/usr/bin/env python
# author: stefan_bo

import urllib2
import sys
import json

def url_encode(port):
	return str(int(port) + 1000)

parameters = sys.argv[1:]
port = parameters[0]
section = parameters[1]
key = parameters[2:]

# url encode
url = 'http://localhost:%s/_status' % url_encode(port)

# json encode
json_obj = urllib2.urlopen(url, timeout=5).read()

serverStatus = json.loads(json_obj)['serverStatus']

if len(key) == 1:
	print serverStatus[section][key[0]]
else:
	print serverStatus[section][key[0]][key[1]]