#!/bin/sh
# chkconfig: 345 95 95
# description:Zabbix server
# Zabbix
# Copyright (C) 2001-2013 Zabbix SIA
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.


# Start/Stop the Zabbix server daemon.
# Place a startup script in /sbin/init.d, and link to it from /sbin/rc[023].d

# Source function library
. /etc/rc.d/init.d/functions

# Source networking configuration
. /etc/sysconfig/network 

# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0

zabbix_server='/usr/local/zabbix/sbin/zabbix_server'
prog=$(basename $zabbix_server)
zabbix_server_conf='/usr/local/zabbix/etc/zabbix_server.conf'

lockfile=/var/lock/subsys/zabbix_server

start() {
	[ -x $zabbix_server ] || exit 5
	[ -f $zabbix_server_conf ] || exit 6
	echo -n $"Starting $prog: "
	$zabbix_server 
	retval=$?
	echo 
	[ $retval -eq 0 ] && touch $lockfile 
	return $retval
}

stop() {
	echo -n $"Stopping $prog: "
	killproc $prog -QUIT
	retval=$?
	echo 
	[ $retval -eq 0 ] && rm -f $lockfile
	return $retval
}


case $1 in
'start')
	start
;;
'stop')
	stop 
;;
'restart')
	$0 stop
	sleep 10
	$0 start
;;
'status')
	status zabbix_server
;;
*)
	echo "Usage: $0 start|stop|restart"
;;
esac