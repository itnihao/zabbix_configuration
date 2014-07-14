#!/usr/bin/env python
import urllib2
import sys

fpm_status_url = "http://localhost/fpmstatus"


def url_to_list(url):
        result = urllib2.urlopen(url, timeout=5).readlines()
        return [temp.strip('\n') for temp in result]

parameters = sys.argv[1:]
content = " ".join(parameters)

fpm_result = url_to_list(fpm_status_url)

for item in fpm_result:
        if content == item.split(':')[0]:
                print item.split(':')[1].strip()