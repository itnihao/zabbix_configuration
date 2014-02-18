#!/bin/sh
# install dependencies package
# conferences https://github.com/allinurl/goaccess
apt-get install libncurses5-dev libncursesw5-dev libglib2.0-dev libgeoip-dev -y

install_path='/usr/local/monitor_tools/app/goaccess'
tar_path='/usr/local/monitor_tools/tar_package'
cd $tar_path
wget http://downloads.sourceforge.net/project/goaccess/0.7.1/goaccess-0.7.1.tar.gz
tar -xzvf goaccess-0.7.1.tar.gz
cd goaccess-0.7.1/
./configure --prefix=$install_path --enable-geoip --enable-utf8 
make
make install