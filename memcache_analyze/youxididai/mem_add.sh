#!/bin/sh
# author: stefanmonkey

zabbix_path='/data/lnmp/monitor_tools/app/zabbix_agent'

mkdir $zabbix_path/libexec -p

server="59.175.238.8"
username="zabbix"
passwd="19880103"


ftp -n $server <<EOF
prompt off
user $username $passwd
lcd $zabbix_path/libexec
cd /zabbix/libexec
get mem_discovery.py
get mem_monitor.sh
bye
EOF

cat > $zabbix_path/etc/zabbix_agentd.conf.d/memcache.conf <<EOF
UserParameter=memcached_stats[*],$zabbix_path/libexec/mem_monitor.sh localhost \$1 |grep -w \$2|awk '{print \$\$3}'
UserParameter=memcached_port_discovery,/data/lnmp/python/bin/python $zabbix_path/libexec/mem_discovery.py 
EOF

#export LD_LIBRARY_PATH='/data/lnmp/monitor_tools/app/mysql/lib:/data/lnmp/cur/lib:/usr/local/app/locale/libxml2/lib'
pkill zabbix_agentd
$zabbix_path/sbin/zabbix_agentd 
chmod +x $zabbix_path/libexec/*
