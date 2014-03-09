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
apt-get install build-essential gcc g++ make libncurses5-dev libxp-dev libmotif-dev libxt-dev libstdc++6 -y
apt-get install libpcre3 libpcre3-dev

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

mkdir -p $zabbix_path/libexec
mkdir -p $zabbix_path/log
mkdir -p $zabbix_path/tmp

cat > $zabbix_path/etc/zabbix_agent.conf <<EOF
server=192.168.1.204
EOF

cat > $zabbix_path/etc/zabbix_agentd.conf <<EOF
PidFile=$zabbix_path/tmp/zabbix_agentd.pid
LogFile=$zabbix_path/log/zabbix_agentd.log
Server=192.168.1.204
ServerActive=192.168.1.204
Hostname=Zabbix server
Include=$zabbix_path/etc/zabbix_agentd.conf.d/
EOF

cat > $zabbix_path/etc/zabbix_server.conf <<EOF
LogFile=$zabbix_path/log/zabbix/zabbix_server.log
PidFile=$zabbix_path/log/zabbix/zabbix_server.pid
DBName=zabbix
DBUser=root
DBPassword=123456
DBSocket=/var/run/mysqld/mysqld.sock
DBPort=3306
StartVMwareCollectors=4
VMwareFrequency=60
VMwareCacheSize=60M
ListenIP=192.168.1.204
CacheSize=20M
EOF

chown -R zabbix.zabbix $zabbix_path 

cd /usr/local/monitor_tools/tar_package

tar zxvf APC-3.1.9.tgz
cd APC-3.1.9
phpize
./configure --enable-apc --enable-apc-mmap  config=/usr/bin/php-config
make && make install
cd ..

unzip  igbinary-igbinary-c35d48f.zip
cd igbinary-igbinary-c35d48f
phpize
./configure  --enable-igbinary config=/usr/bin/php-config
make 
make install
cd ..

cd /usr/local/monitor_tools/tar_package/zabbix-2.2.1/database/mysql
mysql -u root -p123456 -e "use zabbix_temp; source schema.sql; source images.sql; source data.sql; "

