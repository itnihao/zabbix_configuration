#!/bin/sh
# directory path
zabbix_path='/usr/local/zabbix'

# init the install process
mkdir $zabbix_path/libexec -p
mkdir $zabbix_path/log -p
mkdir $zabbix_path/tmp -p


# init the zabbix enviroment
groupadd zabbix
useradd -g zabbix zabbix

cd /tmp
wget http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/2.2.3/zabbix-2.2.3.tar.gz

wget http://iksemel.googlecode.com/files/iksemel-1.4.tar.gz  
tar -zxvf iksemel-1.4.tar.gz  
cd iksemel-1.4
./configure
make && make install

ln -s /usr/local/lib/libiksemel.so.3 /usr/lib64/

cd /tmp
tar -zxvf zabbix-2.2.3.tar.gz
cd zabbix-2.2.3
./configure \
--prefix=$zabbix_path \
--enable-agent \
--with-libcurl \
--with-libxml2 \
--with-jabber
make install 


# configuration settings
cat > $zabbix_path/etc/zabbix_agentd.conf <<EOF
PidFile=/usr/local/zabbix/tmp/zabbix_agentd.pid
LogFile=/usr/local/zabbix/log/zabbix_agentd.log
Server=192.168.1.63
Include=$zabbix_path/etc/zabbix_agentd.conf.d/
BufferSend=10
Timeout=10
EOF

cat > $zabbix_path/etc/zabbix_agent.conf <<EOF
Server=192.168.1.63
EOF

chown -R zabbix.zabbix $zabbix_path