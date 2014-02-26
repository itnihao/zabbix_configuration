#!/bin/sh

zabbix_path='/data/lnmp/monitor_tools/app/zabbix_agent'



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