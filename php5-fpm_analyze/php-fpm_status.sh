#!/bin/bash
### OPTIONS VERIFICATION
if [ -z "$1" ];then
	cat < [url]

Options:
	metric   -- statistics metric
	url      -- PHP-FPM statistics url (default http://127.0.0.1:10061/php-fpm_status)
EOF
	exit 1
fi

### PARAMETERS
MON_ITEM=$1
STATS_URL=${2:-http://127.0.0.1:10061/php-fpm_status}
CURL="/usr/local/bin/curl"
CACHE_TTL="1"		# TTL min
CACHE_FILE="/usr/local/zabbix/var/`basename $0`.cache"

### RUN
## Check cache file
CACHE_FIND=`find $CACHE_FILE -mmin -$CACHE_TTL 2>/dev/null`
if [ -z "$CACHE_FIND" ] || ! [ -s "$CACHE_FILE" ];then
	$CURL -s $STATS_URL > $CACHE_FILE 2>/dev/null || exit 1
fi


case "$MON_ITEM" in
	"accepted_conn")
		awk '/^accepted conn:/ {print $NF}' $CACHE_FILE
		;;
	"idle_procs")
		awk '/^idle processes:/ {print $NF}' $CACHE_FILE
		;;
	"active_procs")
		awk '/^active processes:/ {print $NF}' $CACHE_FILE
        ;;
	"total_procs")
		awk '/^total processes:/ {print $NF}' $CACHE_FILE
		;;
    "listen_queue")
		awk '/^listen queue:/ {print $NF}' $CACHE_FILE
		;;
	"listenqueue_len")
		awk '/^listen queue len:/ {print $NF}' $CACHE_FILE
		;;
	"max_active_processes")
		awk '/^max active processes:/ {print $NF}' $CACHE_FILE
		;;
	"maxchildren_reached")
		awk '/^max children reached:/ {print $NF}' $CACHE_FILE
    	;;
	"slow_requests")
		awk '/^slow requests:/ {print $NF}' $CACHE_FILE
		;; 
	*)
	 	echo "ZBX_NOTSUPPORTED"
		exit 1
		;;
esac
exit 0