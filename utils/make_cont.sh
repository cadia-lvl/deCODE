#!/bin/bash
# 1st script in batch processing.
# Creates a content file that contains all info about audio in the database
# This is later used for ASR and paralellization.

if [ $# -ne 2 ]; then
   echo "Error : Arguments should be a directory containing .wav and .mark files and output file"
   exit 1;
fi

dir=$1
out=$2
echo "Creating a content file $2 from $1"

find $dir -type f -name "*.wav" | sort | egrep -v "Testing|Practice" > tmp/audio.lst
printf "File\tName\tID\tGender\tSmark\tEmark\n" > $out

while read line; do

    file=$(basename $line | sed 's/\..*//')
    id=$(basename $line | cut -d'_' -f1 | tr -d " \t\r\n")

    gender=$(cat $(echo $line | sed 's/_Measure.*/_info.txt/') | grep Kyn: | sed 's/.*Karl.*/M/' | sed 's/.*Kona.*/F/')
    mark=$(cat $(echo $line | sed 's/.wav/_mark.txt/') | tr -d " :[aA-zZ]" | tr "\n" "," | sed 's/.$//' | tr -d " \t\r\n" )   

    if [[ $mark = *","* ]]; then
       if [[ $line = *"Reading"* ]]; then
          start_m=$(echo $mark | rev | cut -d',' -f2 | rev)
          end_m=$(echo $mark | rev | cut -d',' -f1 | rev)
       else
	  start_m="0"
          end_m=$(echo $mark | cut -d',' -f1 )
       fi
    else
       start_m="0"
       end_m=$mark
    fi

    if [[ ! -z $id || -z $g || -z $m ]]; then
       printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$line" "$file" "$id" "$gender" "$start_m" "$end_m"
    fi

done < tmp/audio.lst >> $out
rm tmp/audio.lst
echo "Done!"
