#!/bin/sh
# directory path
zabbix_path='/usr/local/monitor_tools/app/zabbix_agent'
tar_path='/usr/local/monitor_tools/tar_package'
# ftp settings
server="59.175.238.8"
username="zabbix"
passwd="19880103"
# init the install process
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
# init the zabbix enviroment
groupadd zabbix
useradd -g zabbix zabbix

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
PidFile=/usr/local/monitor_tools/app/zabbix_agent/log/zabbix_agentd.pid
LogFile=/usr/local/monitor_tools/app/zabbix_agent/log/zabbix_agentd.log
Server=119.97.226.138
ServerActive=119.97.226.138
Hostname=Zabbix server
Include=$zabbix_path/etc/zabbix_agentd.conf.d/
EOF

cat > $zabbix_path/etc/zabbix_agent.conf <<EOF
Server=119.97.226.138
EOF

ftp -n $server <<EOF
prompt off
user $username $passwd
cd /zabbix/libexec
lcd $zabbix_path/libexec
get discover_disk.pl
cd /zabbix/conf
lcd $zabbix_path/etc/zabbix_agentd.conf.d
get iostat.conf
bye
EOF

chmod +x $zabbix_path/libexec/discover_disk.pl
chown -R zabbix.zabbix $zabbix_path

pkill zabbix_agentd
$zabbix_path/sbin/zabbix_agentd 