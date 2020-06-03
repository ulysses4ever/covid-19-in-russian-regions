#!/bin/bash
set -xe

mydir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
base="${mydir}/../data/rpn-url-ids"
today="$(date +%m%d)"
out="${base}/${today}"
if [ -f "${out}" ]
then
   exit
fi

# Get most recent URL IDs
wget https://www.rospotrebnadzor.ru/about/info/news/
iconv -f CP1251 -t UTF-8 index.html -o index.utf8.html
urlid1=$(grep "О подтвержденных случаях новой коронавирусной инфекции COVID-2019 в России" index.utf8.html | head -1 | grep -Po "[0-9]{5}")
urlid2=$(grep "Информационный бюллетень о ситуации и принимаемых мерах по недопущению распространения заболеваний, вызванных новым коронавирусом" index.utf8.html | head -1 | grep -Po "[0-9]{5}")
rm -f index.html index.utf8.html
if [ "${urlid1}" == "" ] && [ "${urlid2}" == "" ]
then
    exit
fi
yest="$(date +%m%d --date="yesterday")"
last="${base}/${yest}"

# If we've alaredy seen these URL IDs, exit: the data is not up yet
if grep -q "${urlid1}" "${last}"
then
    exit
fi
if grep -q "${urlid2}" "${last}"
then
    exit
fi

echo "(${urlid1}, ${urlid2})" > "${out}"
