#!/usr/bin/env python
# route snmp manager

import subprocess, sys

def os_cmd(order):
	try:
		print "I will run the command %s on the system!" % order
		retcode = subprocess.call(order, shell=True)
		if retcode < 0:
			print >>sys.stderr, "Child was terminated by singal", -retcode
		else:
			print >>sys.stderr, "Child returned", retcode
	except OSError as e:
		print "Something wrong here with the command  %s executed" % order
		print >>sys.stderr, "Execution Falied: ", e

snmp_cmd 		= "snmpwalk -v 2c -c public"
oid_name 		= ".1.3.6.1.2.1.2.2.1.2"
oid_traffic_in  = ".1.3.6.1.2.1.2.2.1.10."
oid_traffic_out = ".1.3.6.1.2.1.2.2.1.16."

