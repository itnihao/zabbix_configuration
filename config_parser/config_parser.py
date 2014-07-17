#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re

def config_parser(conf, para):
	result = []
	input_conf = open(conf, 'r').readlines

	p = re.compile(r'(^para (\S)+)')

	for line in input_conf:
		iter = p.finditer(line)
		for m in iter:
			result.append(m.group())

	return result






In [28]: p = re.compile(r'(^bind (\S)+)')

In [29]: for line in conf:
   ....:     iter = p.finditer(line)
   ....:     for m in iter:
   ....:         print "m", m.group()
   ....:         
   ....:         
m bind 127.0.0.1