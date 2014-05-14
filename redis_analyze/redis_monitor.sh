#!/bin/bash
# 文件名: redis_monitor.sh
# 用法: redis_monitor.sh 192.168.10.31 6379
exec 5<> /dev/tcp/$1/$2
if [ $? -eq 0 ]; then
        echo " info" >&5
        echo " quit" >&5
        while read -u 5 -d $'\r' stat name value;
        do
                echo $stat $name $value
        done
        exit 0
fi
exit 1