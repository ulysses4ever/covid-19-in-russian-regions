#!/bin/bash
set -x
base=$(pwd)/../data
today=$(date +%m%d)
out=${base}/covid${today}.json
if [ -f ${out} ]
then
   exit
fi
tmp=${base}/tmp.json
yest=$(date +%m%d --date="yesterday")
last=${base}/covid${yest}.json
wget https://covid19.rosminzdrav.ru/wp-json/api/mapdata/ -O ${tmp}
df=$(diff ${last} ${tmp})
if [ "$d" == "" ]
then
    rm ${tmp}
else
    mv ${tmp} ${out}
fi
