#!/bin/sh
#export LD_LIBRARY_PATH='/data/lnmp/monitor_tools/app/mysql/lib:/data/lnmp/cur/lib:/usr/local/app/locale/libxml2/lib'

zabbix_path='/data/lnmp/monitor_tools/app/zabbix_agent'


cat > $zabbix_path/etc/zabbix_agentd.conf.d/iostat.conf <<EOF
UserParameter=custom.vfs.dev.io.active[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$12}'
UserParameter=custom.vfs.dev.io.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$13}'
UserParameter=custom.vfs.dev.read.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$7}'
UserParameter=custom.vfs.dev.write.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$11}'
UserParameter=custom.vfs.dev.read_merge[*],cat /proc/diskstats |grep \$1 |head -1 |awk '{print \$\$5}'
UserParameter=custom.vfs.dev.write_merge[*],cat /proc/diskstats |grep \$1 |head -1 |awk '{print \$\$9}'
UserParameter=custom.disks.discovery_perl,$zabbix_path/libexec/discover_disk.pl
EOF

pkill zabbix_agentd
$zabbix_path/sbin/zabbix_agentd 

