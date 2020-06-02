#!/bin/bash

cat $1 | sed -E 's/,?\{"LocationName":"No region speified","Lat":null,"Lng":null,"Observations":[0-9]*,"Confirmed":0,"Recovered":0,"Deaths":0,"IsoCode":null,"New":false\},?//'
