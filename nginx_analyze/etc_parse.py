#!/usr/bin/env python
# -*- coding:utf-8 -*-

import os

class conf_parse(object):

	def __init__(self, infile_path, infile, keyword):
		self.infile_path = infile_path
		self.infile = infile
		self.keyword = keyword


	def procedure(self):
		read_list = open(os.path.join(self.infile_path, self.infile), 'r').read().split('\n')
		mid_list = [test for test in read_list if not test.startswith('#') and test != '']

		result = [test.split() for test in mid_list if self.keyword in test.split()]

		if result != []:
			return result[0][1].replace(';', '')
		else:
			return 'null'


a = conf_parse('/tmp','test.conf','access_log')
result = a.procedure()

print result




