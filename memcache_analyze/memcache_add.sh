#!/bin/sh
# author: stefanmonkey

zabbix_path='/usr/local/monitor_tools/app/zabbix_agent'

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
bye
EOF

cat > $zabbix_path/etc/zabbix_agentd.conf.d/memcache.conf <<EOF
UserParameter=memcached_stats[*],$zabbix_path/libexec/mem_monitor.sh localhost \$1 \$2
UserParameter=memcached_port_discovery,$zabbix_path/libexec/mem_discovery.py
EOF

pkill zabbix_agentd
$zabbix_path/sbin/zabbix_agentd 
chown -R zabbix.zabbix $zabbix_path
chmod +x $zabbix_path/libexec/discover_disk.pl
