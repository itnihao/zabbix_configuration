#!/bin/sh
#export LD_LIBRARY_PATH='/data/lnmp/monitor_tools/app/mysql/lib:/data/lnmp/cur/lib:/usr/local/app/locale/libxml2/lib'

zabbix_path='/usr/local/monitor_tools/app/zabbix'

mkdir $zabbix_path/libexec -p

server="59.175.238.8"
username="zabbix"
passwd="19880103"


ftp -n $server <<EOF
prompt off
user $username $passwd
lcd $zabbix_path/libexec
cd /zabbix/libexec
get discover_disk.pl
bye
EOF

cat > $zabbix_path/etc/zabbix_agentd.conf.d/iostat.conf <<EOF
UserParameter=custom.vfs.dev.read.ops[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$4}'
UserParameter=custom.vfs.dev.read.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$7}'
UserParameter=custom.vfs.dev.write.ops[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$8}'
UserParameter=custom.vfs.dev.write.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$11}'
UserParameter=custom.vfs.dev.io.active[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$12}'
UserParameter=custom.vfs.dev.io.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$13}'
UserParameter=custom.vfs.dev.read.sectors[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$6}'
UserParameter=custom.vfs.dev.write.sectors[*],cat /proc/diskstats | grep \$1 | head -1 | awk '{print \$\$10}'
UserParameter=custom.disks.discovery_perl,$zabbix_path/libexec/discover_disk.pl
EOF

pkill zabbix_agentd
$zabbix_path/sbin/zabbix_agentd 
chown -R zabbix.zabbix $zabbix_path
chmod +x $zabbix_path/libexec/discover_disk.pl
