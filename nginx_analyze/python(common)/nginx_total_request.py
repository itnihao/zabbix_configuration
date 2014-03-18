#!/usr/bin/env python
# -*- coding: utf-8 -*-
import datetime,time
import sys,os

def time_process(line,now,timedelta):
        timestr = line.split('[')[1].split()[0]
        times_temp = time.strptime(timestr,  '%d/%b/%Y:%H:%M:%S')
        timestamp = datetime.datetime(times_temp[0], times_temp[1], times_temp[2], times_temp[3], times_temp[4], times_temp[5])

        if  now - timestamp <= timedelta:
            return True
        else:
             return False

def conf_list_ana(key, line_read):
    return [temp.split() for temp in line_read if key in temp.split()][0]

def log_analyze(file):
    now = datetime.datetime.now()
    timedelta = datetime.timedelta(minutes=5)

    f = open(file,'r')
    line = f.readline()
    f.seek(0,2)
    n = f.tell()
    n = n - n * 2
    i = 0
    y = 0
    while i > n:
        i = i - 1
        f.seek(i , 2)
        c = f.read(1)
        if c == '\n':
            i = i - 1
            line = f.readline().strip()
            if len(line) == 0:
                continue
            if time_process(line, now, timedelta):
                y += 1
            else:
                break
    f.close()
    return y

nginx_base = '/data/lnmp/nginx'
nginx_etc_path = os.path.join(nginx_base, 'conf/conf.d')
file_list = [item for item in os.listdir(nginx_etc_path) if 'conf' in item]
results = 0

for file in file_list:
    index = open(os.path.join(nginx_etc_path, file), 'r').read().split('\n')
    access_log = conf_list_ana('access_log', index)[1].replace(';', '')
    #print os.path.join(nginx_base, access_log)
    ab = log_analyze(os.path.join(nginx_base, access_log))
    #print ab
    results += ab
    
print results

