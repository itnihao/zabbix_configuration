#!/usr/bin/env python
# -*- coding:utf-8 -*-

import sys, os
BASE_DIR = os.path.dirname(os.path.dirname(__file__))
sys.path.append(BASE_DIR)

from nginx_analyze import nginx_analyze

m = sys.argv[1:]
if len(m) == 2:
	ab = nginx_analyze(m[0],m[1])
	results = ab.analyze()
	print results
else:
	print 'parameters number must be two'