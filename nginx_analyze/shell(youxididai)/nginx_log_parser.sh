#!/bin/sh
# author: stefanmonkey

time_end=`date +"%Y:%H:%M:%S"`
time_start=`date -d "-5minutes" +"%Y:%H:%M:%S"`

# total requests
#sed -n "/$time_start/, /$time_end/"p /var/log/nginx/16999.access.log |wc -l

# total bytes send 
#awk 'BEGIN{sum=0;}{if ($9 == 200) {sum +=$10;} } END {print sum}' /var/log/nginx/16999.access.log

case $2 in 
	requests)
		sed -n "/$time_start/, /$time_end/"p $1 |wc -l
		;;
	traffic)
		sed -n "/$time_start/, /$time_end/"p $1 | awk 'BEGIN{sum=0;}{{sum +=$10;}} END {print sum}'
		;;
	200)
		sed -n "/$time_start/, /$time_end/"p $1 | awk 'BEGIN{count=0;}{if ($9 == 200) {count++;} } END {print count}'
		;;
	404)
		sed -n "/$time_start/, /$time_end/"p $1 | awk 'BEGIN{count=0;}{if ($9 == 404) {count++;} } END {print count}'
		;;
	*)
		exit 1
esac
