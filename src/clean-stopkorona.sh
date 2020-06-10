#!/bin/bash

i="$1"

if [ ! -f "$i" ]
then
   echo "Please, provide input file name. Exit."
   exit 1
fi

sed -i '1s/^/LocationName,Confirmed,New,Active,Recovered,Deaths\n/' "$i"
sed -i -E 's/ \t/,/g' "$i"
