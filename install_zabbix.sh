#!/bin/bash
# install packages

# install server on ubuntu 
apt-get install libghc6-hsql-mysql-dev -y
apt-get install libphp-jabber -y
apt-get install libnet-jabber-loudmouth-perl -y
apt-get install jabber-dev -y
apt-get install libiksemel-dev  -y
apt-get install libcurl4-openssl-dev -y
apt-get install libsnmp-dev -y
apt-get install snmp -y
apt-get install libxml2-dev -y

# install server on redhat/centos
#yum install zlib-devel libxml2-devel glibc-devel curl-devel gcc automake  libidn-devel openssl-devel net-snmp-devel rpm-devel OpenIPMI-devel

wget http://iksemel.googlecode.com/files/iksemel-1.4.tar.gz  
tar -zxvf iksemel-1.4.tar.gz  
cd iksemel-1.4
./configure
make && make install

zabbix_path='/usr/local/monitor_tools/app/zabbix'
mkdir -p /usr/local/monitor_tools/app
mkdir -p /usr/local/monitor_tools/tar_package
# install server
cd /usr/local/monitor_tools/tar_package
wget http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/2.2.1/zabbix-2.2.1.tar.gz
tar -zxvf zabbix-2.2.1.tar.gz
cd zabbix-2.2.1
./configure \
--prefix=$zabbix_path \
--enable-server \
--enable-agent \
--with-mysql \
--enable-ipv6 \
--with-net-snmp \
--with-libcurl \
--with-libxml2 \
--with-jabber

make install

# install agent and proxy
./configure \
--prefix=/usr/local/app/zabbix \
--enable-agent \
--enable-proxy \
--enable-ipv6 \
--with-net-snmp \
--with-libcurl \
--with-libxml2 \
--with-jabber

# install only agent with youxididai server
./configure \
--prefix=/data/lnmp/monitor_tools/app/zabbix_agent \
--enable-agent \
--with-libcurl=/data/lnmp/cur/lib/ \
--with-libxml2=/usr/local/app/locale/libxml2/lib/ \
--with-jabber

# install agent and proxy with youxididai server
./configure \
--prefix=/data/lnmp/monitor_tools/app/zabbix_proxy \
--enable-proxy \
--enable-agent \
--with-mysql=/data/lnmp/monitor_tools/app/mysql/bin/mysql_config \
--with-libcurl=/data/lnmp/cur/bin/curl-config \
--with-libxml2=/usr/local/app/locale/libxml2/bin/xml2-config

# 230 proxy init scripts
export LD_LIBRARY_PATH='/data/lnmp/monitor_tools/app/mysql/lib:/data/lnmp/cur/lib:/usr/local/app/locale/libxml2/lib'


