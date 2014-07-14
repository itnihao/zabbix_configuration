#!/usr/bin/env python
# -*- coding:utf-8 -*-
import json
import re

phpfpm_conf_file='/usr/local/php/etc/php-fpm.conf'

php_run_ip = []

pattern = 'listen = (.*):(.*)'

listen = re.findall(pattern,open(phpfpm_conf_file).read())

json_data = {"data": []}

dic_content = {"{#PHPFPM_IP}": listen[0][0]}

json_data['data'].append(dic_content)

result = json.dumps(json_data)
print result