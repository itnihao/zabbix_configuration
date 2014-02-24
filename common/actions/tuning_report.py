#!/usr/bin/env python
# base the tuning-primer.sh in the currently directory

import os, sys
import subprocess

mysql_user = 'monitoring'
mysql_pass = '123456'

def os_cmd(order):
	try:
		#print "I will run the command %s on the system!" % order
		retcode = subprocess.call(order, shell=True)
		if retcode < 0:
			print >>sys.stderr, "Child was terminated by singal", -retcode
		else:
			print >>sys.stderr, "Child returned", retcode
	except OSError as e:
		print "Something wrong here with the command  %s executed" % order
		print >>sys.stderr, "Execution Falied: ", e


cur_dir = os.path.dirname(os.path.dirname(__file__))

# run the mysql advisor perl 
mysql_advisor_perl = os.path.join(cur_dir, 'mysql_tuner_advisors.pl')
os_cmd('/usr/bin/perl %s' % mysql_advisor_perl)

# run the mysql report perl
mysql_report_perl = os.path.join(cur_dir, 'mysqlreport.pl')
os_cmd('/usr/bin/perl %s --user %s --password %s' % (mysql_report_perl, mysql_user, mysql_pass))
