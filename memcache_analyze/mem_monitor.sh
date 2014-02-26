#!/bin/bash
# 文件名: monitormem.sh
# 用法: monitormem.sh 192.168.10.31 11211
exec 5<> /dev/tcp/$1/$2
if [ $? -eq 0 ]; then
        echo "stats" >&5
        echo "quit" >&5
        while read -u 5 -d $'\r' stat name value;
        do
                echo $stat $name $value
        done
        exit 0
fi
exit 1