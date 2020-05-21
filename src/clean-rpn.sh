#/bin/bash

i=$1

sed -i -E 's/^[0-9]+\. //' $i
sed -i -zE 's/\n\n/\n/g' $i
sed -i -E 's/ - /,/g' $i
sed -i '1iRegion,NewCases' $i
