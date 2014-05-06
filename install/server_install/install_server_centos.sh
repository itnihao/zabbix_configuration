#!/bin/sh
# install zabbix server from tar source

cd /tmp
wget http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/2.2.3/zabbix-2.2.3.tar.gz

wget http://iksemel.googlecode.com/files/iksemel-1.4.tar.gz  
tar -zxvf iksemel-1.4.tar.gz  
cd iksemel-1.4
./configure
make && make install

yum install curl \
			curl-devel \
			net-snmp \
			net-snmp-devel \
			OpenIPMI \
			perl-DBI -y

groupadd -g 573 zabbix 
useradd -g zabbix -u 573 -s /sbin/nologin zabbix 

zabbix_path='/usr/local/zabbix'
mkdir -p $zabbix_path/log 
mkdir -p $zabbix_path/libexec 
mkdir -p $zabbix_path/tmp

# install zabbix server 

cd /tmp
tar -zxvf zabbix-2.2.3.tar.gz
cd zabbix-2.2.3
./configure \
--prefix=$zabbix_path \
--enable-server \
--enable-agent \
--enable-ipv6 \
--with-mysql \
--with-net-snmp \
--with-libcurl \
--with-libxml2 \
--with-jabber=/usr/local 

make install

#cat > $zabbix_path/etc/zabbix_agent.conf <<EOF
#server=118.244.236.5
#EOF
#
#cat > $zabbix_path/etc/zabbix_agentd.conf <<EOF
#PidFile=$zabbix_path/tmp/zabbix_agentd.pid 
#LogFIle=$zabbix_path/log/zabbix_agentd.log 
#Server=118.244.236.5
#Hostname=Zabbix Server 
#Include=$zabbix_path/etc/zabbix_agentd.conf.d/
#EOF
#
#cat > $zabbix_path/etc/zabbix_server.conf <<EOF
#LogFile=$zabbix_path/log/zabbix_server.log 
#PidFile=$zabbix_path/tmp/zabbix_server.pid 
#DBName=zabbix 
#DBUser=zabbix 
#DBPassword=1qaz2wsx
#DBSocket=/var/run/mysqld/mysqld.sock
#DBPort=3306
#StartVMwareCollectors=4
#VMwareFrequency=60
#VMwareCacheSize=60M
#ListenIP=192.168.1.63
#CacheSize=20M
#EOF

chown -R zabbix.zabbix $zabbix_path 

# mysql init 
mysql -u root -pqwe123 -e "create database zabbix character set utf8;"
mysql -u root -pqwe123 -e "create user 'zabbix'@'%' identified by '1qaz2wsx';"
mysql -u root -pqwe123 -e "grant all on zabbix.* to 'zabbix'@'%' identified by '1qaz2wsx'; "

cd /tmp/zabbix-2.2.3/database/mysql 
mysql -u root -pqwe123 -e "use zabbix; source schema.sql; source images.sql; source data.sql; "