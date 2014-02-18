#!/bin/bash
I=`ps aux | grep nginx | grep root | grep -v 'grep nginx' | awk '{print $14}'`    #查找nginx进程
if [ $I == /usr/local/nginx/sbin/nginx ];then
ACCLOG=`cat /usr/local/nginx/conf/nginx.conf | grep  ' access_log' | awk '{print $2}'`  #如果nginx进程在，就找到配置文件，读取accesslog路径
ERRLOG=`cat /usr/local/nginx/conf/nginx.conf| grep  ^error  | awk '{print $2}'| cut  -d";" -f1`  #错误日志的路径
ls $ACCLOG     #查看是否有此文件
if [ $? -eq 0 ];then    #如果有
mv $ACCLOG  $ACCLOG.`date -d "-1 day" +%F`  #重命名当前日志
mv $ERRLOG $ERRLOG.`date -d "-1 day" +%F`
touch $ACCLOG    #创建空日志
touch $ERRLOG
chown nginx:root  $ACCLOG   #修改属主
chown nginx:root  $ERRLOG
[ -f /usr/local/nginx/logs/nginx.pid ] && kill -USR1 `cat /usr/local/nginx/logs/nginx.pid`     #判断进程，并重新加载（这里的kill -USR1会使nginx将新产生的日志写到刚创建的新日志里面。）
/mnt/logs/checklog.sh $ACCLOG.`date "-1 day" +%F` #这个是日志分析脚本
gzip $ACCLOG.`date -d "-1 day" +%F`  #压缩日志
gzip $ERRLOG.`date -d "-1 day" +%F`

mv  $ACCLOG.`date -d "-10 day" +%F`.*  /mnt/history.nginx.log/   #将10天前的老日志清理到其他地方，（你们如果想删除的可以自己改成删除）
mv  $ERRLOG.`date -d "-10 day" +%F`.*  /mnt/history.nginx.log/
fi
fi