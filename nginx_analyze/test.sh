#!/bin/sh
# author: stefanmonkey

time_end=`date +"%Y:%H:%M:%S"`
time_start=`date -d "-500minutes" +"%Y:%H:%M:%S"`

# total requests
#sed -n "/$time_start/, /$time_end/"p /var/log/nginx/16999.access.log |wc -l

# total bytes send 
#awk 'BEGIN{sum=0;}{if ($9 == 200) {sum +=$10;} } END {print sum}' /var/log/nginx/16999.access.log

sed -n "/$time_start/, /$time_end/"p
