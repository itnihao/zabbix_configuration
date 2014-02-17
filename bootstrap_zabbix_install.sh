#!/bin/sh
# directory path
zabbix_path='/usr/local/monitor_tools/app/zabbix_agent'
tar_path='/usr/local/monitor_tools/tar_package'

# ftp settings
server="59.175.238.8"
username="zabbix"
passwd="19880103"

# init the install environment
mkdir $zabbix_path/libexec -p
mkdir $zabbix_path/log -p
mkdir $zabbix_path/tmp -p
mkdir $tar_path -p

# get tar from ftp
ftp -n $server <<EOF
prompt off 
user $username $passwd
cd /zabbix/tar_package
lcd $tar_path
get zabbix-2.2.1.tar.gz
bye
EOF

# add zabbix user
groupadd zabbix
useradd -g zabbix zabbix 

# install agent procedure
cd $tar_path
tar -zxvf zabbix-2.2.1.tar.gz
cd zabbix-2.2.1
./configure \
--prefix=$zabbix_path \
--enable-agent \
--with-libcurl \
--with-libxml2 \
--with-jabber
make install 

# configuration settings
cat > $zabbix_path/etc/zabbix_agentd.conf <<EOF
PidFile=$zabbix_path/log/zabbix_agentd.pid
LogFile=$zabbix_path/log/zabbix_agentd.log
Server=119.97.226.138
ServerActive=119.97.226.138
Hostname=Zabbix server
Include=$zabbix_path/etc/zabbix_agentd.conf.d/
EOF

cat > $zabbix_path/etc/zabbix_agent.conf <<EOF
Server=119.97.226.138
EOF

# iostat item configuration
# version 1.203
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

# version 1.204
cat > $zabbix_path/etc/zabbix_agentd.conf.d/iostat.conf <<EOF
UserParameter=custom.disks.discovery_perl,$zabbix_path/libexec/discover_disk.pl
EOF

ftp -n $server <<EOF
prompt off
user $username $passwd
cd /zabbix/libexec
lcd $zabbix_path/libexec
get discover_disk.pl
bye
EOF

# zabbix cpu external configuration
cat > $zabbix_path/etc/zabbix_agentd.conf.d/cpu.conf <<EOF
UserParameter=custom.cpu.info,cat /proc/cpuinfo |egrep 'model name' |uniq |awk -F':' '{print \$2}' 
EOF

chmod +x $zabbix_path/libexec/discover_disk.pl 
chown -R zabbix.zabbix $zabbix_path

pkill zabbix_agentd
$zabbix_path/sbin/zabbix_agentd