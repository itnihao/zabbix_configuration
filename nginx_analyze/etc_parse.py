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
		for read_line in read_list:

