#!/bin/sh

cat >> /etc/sudoers <<EOF
Cmnd_Alias MONITORING = /bin/netstat, /sbin/sudo
%zabbix	ALL=(root) NOPASSWD:MONITORING
EOF

