#!/bin/bash
install_mysql() {
echo "============================Install MySQL================================="

mkdir -p /data/lnmp/monitor_tools/app/mysql/data -p 
mkdir -p /data/lnmp/monitor_tools/app/mysql/etc/init.d -p
mkdir -p /data/lnmp/monitor_tools/app/mysql/tmp -p
mkdir -p /data/lnmp/monitor_tools/app/mysql/log -p

cd /data/lnmp/monitor_tools/tar_package
cur_dir=$(pwd)
cd $cur_dir
tar -zxvf cmake-2.8.12.1.tar.gz
cd cmake-2.8.12.1
./configure --prefix=/data/lnmp/monitor_tools/app/cmake
make -j2 && make install
cd ..

tar -zxvf mysql-5.5.34.tar.gz
cd mysql-5.5.34
/data/lnmp/monitor_tools/app/cmake/bin/cmake \
-DCMAKE_INSTALL_PREFIX=/data/lnmp/monitor_tools/app/mysql \
-DMYSQL_DATADIR=/data/lnmp/monitor_tools/app/mysql/data \
-DSYSCONFDIR=/data/lnmp/monitor_tools/app/mysql/etc \
-DTMPDIR=/data/lnmp/monitor_tools/app/mysql/tmp \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_READLINE=1 \
-DWITH_DEBUG=0 \
-DWITH_EMBEDDED_SERVER=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1

make -j2 && make install 


cat > /data/lnmp/monitor_tools/app/mysql/etc/my.cnf <<EOF
# Example MySQL config file for medium systems.
#
# This is for a system with little memory (32M - 64M) where MySQL plays
# an important part, or systems up to 128M where MySQL is used together with
# other programs (such as a web server)
#
# MySQL programs look for option files in a set of
# locations which depend on the deployment platform.
# You can copy this option file to one of those
# locations. For information about these locations, see:
# http://dev.mysql.com/doc/mysql/en/option-files.html
#
# In this file, you can use all long options that a program supports.
# If you want to know which options a program supports, run the program
# with the "--help" option.

# The following options will be passed to all MySQL clients
[client]
#password       = your_password
port            = 3306
socket          = /data/lnmp/monitor_tools/app/mysql/mysql.sock

# Here follows entries for some specific programs

# The MySQL server
[mysqld]
port            = 3306
socket          = /data/lnmp/monitor_tools/app/mysql/mysql.sock
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
tmpdir = /data/lnmp/monitor_tools/app/mysql/tmp/
# Don't listen on a TCP/IP port at all. This can be a security enhancement,
# if all processes that need to connect to mysqld run on the same host.
# All interaction with mysqld must be made via Unix sockets or named pipes.
# Note that using this option without enabling named pipes on Windows
# (via the "enable-named-pipe" option) will render mysqld useless!
# 
#skip-networking

# Replication Master Server (default)
# binary logging is required for replication
log-bin=mysql-bin

# binary logging format - mixed recommended
binlog_format=mixed

# required unique id between 1 and 2^32 - 1
# defaults to 1 if master-host is not set
# but will not function as a master if omitted
server-id       = 1

# Replication Slave (comment out master section to use this)
#
# To configure this host as a replication slave, you can choose between
# two methods :
#
# 1) Use the CHANGE MASTER TO command (fully described in our manual) -
#    the syntax is:
#
#    CHANGE MASTER TO MASTER_HOST=<host>, MASTER_PORT=<port>,
#    MASTER_USER=<user>, MASTER_PASSWORD=<password> ;
#
#    where you replace <host>, <user>, <password> by quoted strings and
#    <port> by the master's port number (3306 by default).
#
#    Example:
#
#    CHANGE MASTER TO MASTER_HOST='125.564.12.1', MASTER_PORT=3306,
#    MASTER_USER='joe', MASTER_PASSWORD='secret';
#
# OR
#
# 2) Set the variables below. However, in case you choose this method, then
#    start replication for the first time (even unsuccessfully, for example
#    if you mistyped the password in master-password and the slave fails to
#    connect), the slave will create a master.info file, and any later
#    change in this file to the variables' values below will be ignored and
#    overridden by the content of the master.info file, unless you shutdown
#    the slave server, delete master.info and restart the slaver server.
#    For that reason, you may want to leave the lines below untouched
#    (commented) and instead use CHANGE MASTER TO (see above)
#
# required unique id between 2 and 2^32 - 1
# (and different from the master)
# defaults to 2 if master-host is set
# but will not function as a slave if omitted
#server-id       = 2
#
# The replication master for this slave - required
#master-host     =   <hostname>
#
# The username the slave will use for authentication when connecting
# to the master - required
#master-user     =   <username>
#
# The password the slave will authenticate with when connecting to
# the master - required
#master-password =   <password>
#
# The port the master is listening on.
# optional - defaults to 3306
#master-port     =  <port>
#
# binary logging - not required for slaves, but recommended
#log-bin=mysql-bin

# Uncomment the following if you are using InnoDB tables
innodb_data_home_dir = /data/lnmp/monitor_tools/app/mysql/data
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = /data/lnmp/monitor_tools/app/mysql/data
# You can set .._buffer_pool_size up to 50 - 80 %
# of RAM but beware of setting memory usage too high
innodb_buffer_pool_size = 16M
innodb_additional_mem_pool_size = 2M
# Set .._log_file_size to 25 % of buffer pool size
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash
# Remove the next comment character if you are not familiar with SQL
#safe-updates

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF

chmod +x /data/lnmp/monitor_tools/tar_package/mysql-5.5.34/scripts/mysql_install_db 

/data/lnmp/monitor_tools/tar_package/mysql-5.5.34/scripts/mysql_install_db \
--user=cp_mqq \
--defaults-file=/data/lnmp/monitor_tools/app/mysql/etc/my.cnf \
--datadir=/data/lnmp/monitor_tools/app/mysql/data \
--basedir=/data/lnmp/monitor_tools/app/mysql \
--tmpdir=/data/lnmp/monitor_tools/app/mysql/tmp

cp /data/lnmp/monitor_tools/tar_package/mysql-5.5.34/support-files/mysql.server /data/lnmp/monitor_tools/app/mysql/etc/init.d/mysql 
chmod +x /data/lnmp/monitor_tools/app/mysql/etc/init.d/mysql 
chown -R cp_mqq.mqq /data/lnmp/monitor_tools/app/mysql 

/data/lnmp/monitor_tools/app/mysql/bin/mysqld_safe --skip-grant-tables --user=root&
cat > /data/lnmp/monitor_tools/app/mysql/tmp/mysql_root.sql <<EOF
INSERT INTO `mysql`.`user` (`Host`, `User`, `Password`, `Select_priv`, `Insert_priv`, `Update_priv`, `Delete_priv`, `Create_priv`, `Drop_priv`, `Reload_priv`, `Shutdown_priv`, `Process_priv`, `File_priv`, `Grant_priv`, `References_priv`, `Index_priv`, `Alter_priv`, `Show_db_priv`, `Super_priv`, `Create_tmp_table_priv`, `Lock_tables_priv`, `Execute_priv`, `Repl_slave_priv`, `Repl_client_priv`, `Create_view_priv`, `Show_view_priv`, `Create_routine_priv`, `Alter_routine_priv`, `Create_user_priv`, `Event_priv`, `Trigger_priv`, `Create_tablespace_priv`, `ssl_type`, `ssl_cipher`, `x509_issuer`, `x509_subject`, `max_questions`, `max_updates`, `max_connections`, `max_user_connections`, `plugin`, `authentication_string`) VALUES ('%', 'root', '*6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', '', '', '', '', '0', '0', '0', '0', '', NULL);
EOF
/data/lnmp/monitor_tools/app/mysql/bin/mysql -u root < /data/lnmp/monitor_tools/app/mysql/tmp/mysql_root.sql
/data/lnmp/monitor_tools/app/mysql/etc/init.d/mysql stop

#/data/lnmp/monitor_tools/app/mysql/etc/init.d/mysql start
#/data/lnmp/monitor_tools/app/mysql/bin/mysqladmin -u root password 123456

#cat > /tmp/mysql_sec_script<<EOF
#use mysql;
#update user set password=password('123456') where user='root';
#delete from user where not (user='root') ;
#delete from user where user='root' and password=''; 
#drop database test;
#DROP USER ''@'%';
#flush privileges;
#EOF

#/data/lnmp/monitor_tools/app/mysql/bin/mysql -u root -p123456 -h localhost < /tmp/mysql_sec_script
#/data/lnmp/monitor_tools/app/mysql/etc/init.d/mysql stop
#/data/lnmp/monitor_tools/app/mysql/etc/init.d/mysql start
}
install_mysql