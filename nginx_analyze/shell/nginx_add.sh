#!/bin/sh

zabbix_path='/data/lnmp/monitor_tools/app/zabbix_agent'

mkdir $zabbix_path/libexec -p

server="59.175.238.8"
username="zabbix"
passwd="19880103"


ftp -n $server <<EOF
prompt off
user $username $passwd
lcd $zabbix_path/libexec
cd /zabbix_youxididai/libexec
get nginx_site_discovery.py
get nginx_log_parser.sh
get nginx_total_analyze.sh
bye
EOF

cat > $zabbix_path/etc/zabbix_agentd.conf <<EOF
PidFile=$zabbix_path/log/zabbix_agentd.pid
LogFile=$zabbix_path/log/zabbix_agentd.log
Server=10.144.132.230
ServerActive=119.97.226.138
Hostname=10.144.133.55
Include=$zabbix_path/etc/zabbix_agentd.conf.d/
Timeout=30
EOF

cat > $zabbix_path/etc/zabbix_agentd.conf.d/nginx.conf <<EOF
# zabbix LLD scripts about site self
UserParameter=nginx.statistics.200[*],$zabbix_path/libexec/nginx_log_parser.sh \$1 200
UserParameter=nginx.statistics.404[*],$zabbix_path/libexec/nginx_log_parser.sh \$1 404
UserParameter=nginx.requests[*],$zabbix_path/libexec/nginx_log_parser.sh \$1 requests
UserParameter=nginx.traffic[*],$zabbix_path/libexec/nginx_log_parser.sh \$1 traffic
UserParameter=nginx.sites.discovery_python,/data/lnmp/Python-2.7.3/python $zabbix_path/libexec/nginx_site_discovery.py

# zabbix nginx total requests , total status statistics and total traffic
UserParameter=nginx.total.200,$zabbix_path/libexec/nginx_total_analyze.sh 200
UserParameter=nginx.total.404,$zabbix_path/libexec/nginx_total_analyze.sh 404
UserParameter=nginx.total.traffic,$zabbix_path/libexec/nginx_total_analyze.sh traffic
UserParameter=nginx.total.requests,$zabbix_path/libexec/nginx_total_analyze.sh requests
EOF

pkill zabbix_agentd
$zabbix_path/sbin/zabbix_agentd 

chmod +x $zabbix_path/libexec/*
chmod o+r /usr/local/app/lnmp/nginx/logs/*