#!/bin/bash
NGINX_LOG_PATH="/usr/local/app/lnmp/nginx/logs"
nginx_pid=`ps -ef |grep nginx |grep master|awk '{print $2}'`
if [ -f $NGINX_LOG_PATH/nginx.pid ] ;  then
        echo $nginx_pid > $NGINX_LOG_PATH/nginx.pid
fi
#mv ${NGINX_LOG_PATH}/16999.access.log ${NGINX_LOG_PATH}/16999.access.log.$(date -d "yesterday" +"%Y%m%d")
#mv ${NGINX_LOG_PATH}/17000.access.log ${NGINX_LOG_PATH}/17000.access.log.$(date -d "yesterday" +"%Y%m%d")
#mv ${NGINX_LOG_PATH}/17005.access.log ${NGINX_LOG_PATH}/17005.access.log.$(date -d "yesterday" +"%Y%m%d")

mv ${NGINX_LOG_PATH}/17999.access.log ${NGINX_LOG_PATH}/17999.access.log.$(date -d "yesterday" +"%Y%m%d")
mv ${NGINX_LOG_PATH}/8099.access.log ${NGINX_LOG_PATH}/8099.access.log.$(date -d "yesterday" +"%Y%m%d")
mv ${NGINX_LOG_PATH}/18001.access.log ${NGINX_LOG_PATH}/18001.access.log.$(date -d "yesterday" +"%Y%m%d")
mv ${NGINX_LOG_PATH}/18000.access.log ${NGINX_LOG_PATH}/18000.access.log.$(date -d "yesterday" +"%Y%m%d")

kill -USR1 $(cat ${NGINX_LOG_PATH}/nginx.pid)


find ${NGINX_LOG_PATH} -type f -mtime +10 |grep -v nginx.pid |xargs rm -rf > /dev/null 2>&1