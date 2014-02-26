#!/bin/bash
# author: stefanmonkey

time_end=`date +"%Y:%H:%M:%S"`
time_start=`date -d "-5minutes" +"%Y:%H:%M:%S"`

# total requests
#sed -n "/$time_start/, /$time_end/"p /var/log/nginx/16999.access.log |wc -l

# total bytes send 
#awk 'BEGIN{sum=0;}{if ($9 == 200) {sum +=$10;} } END {print sum}' /var/log/nginx/16999.access.log
nginx_log_file=`cat /data/lnmp/nginx/conf/conf.d/*|egrep -v '^$|^#' |egrep 'access_log'|awk '{print $2}'|awk -F';' '{print $1}'|uniq`
nginx_base='/data/lnmp/nginx/'

case $1 in 
	requests)
		total_count=0
		for file in $nginx_log_file
		do
			let total_count+=`sed -n "/$time_start/, /$time_end/"p $nginx_base$file |wc -l`
		done
		echo $total_count
		;;
	traffic)
		total_count=0
		for file in $nginx_log_file
		do
			let total_count+=`sed -n "/$time_start/, /$time_end/"p $nginx_base$file | awk 'BEGIN{sum=0;}{{sum +=$10;}} END {print sum}'`
		done
		echo $total_count
		;;
	200)
		total_count=0
		for file in $nginx_log_file
		do
			let total_count+=`sed -n "/$time_start/, /$time_end/"p $nginx_base$file | awk 'BEGIN{count=0;}{if ($9 == 200) {count++;} } END {print count}'`
		done
		echo $total_count
		;;
	404)
		total_count=0
		for file in $nginx_log_file
		do
			let total_count+=`sed -n "/$time_start/, /$time_end/"p $nginx_base$file | awk 'BEGIN{count=0;}{if ($9 == 404) {count++;} } END {print count}'`
		done
		echo $total_count
		;;
	*)
		exit 1
esac