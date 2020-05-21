#!/bin/bash
#
# This is supposed to be run by Cron every day, because Minzdrav
# doesn't preserve data for previous days
#
wget https://covid19.rosminzdrav.ru/wp-json/api/mapdata/ -O $(pwd)/../data/total-covid$(date +%m%d).json
