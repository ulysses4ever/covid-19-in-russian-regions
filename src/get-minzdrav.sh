#!/bin/bash
#set -x
base="$(pwd)/../data/minzdrav"
today="$(date +%m%d)"
out="${base}/${today}.json"
if [ -f "${out}" ]
then
   exit
fi

tmp="${base}/tmp.json"
yest="$(date +%m%d --date="yesterday")"
last="${base}/${yest}.json"

wget https://covid19.rosminzdrav.ru/wp-json/api/mapdata/ -O "${tmp}"

df=$(diff "${last}" "${tmp}" | head -1)
if [ "${df}" == "" ]
then
    rm "${tmp}"
else
    mv "${tmp}" "${out}"
fi
