#!/bin/bash

# deCODE 2017 MB

set -o errexit

function error_exit () {
  echo -e "$@" >&2; exit 1;
}

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <cont_file> <dst-dir>"
  echo "e.g.: $0 cleaned.cont data/cleaned"
  exit 1
fi

# all utterances need to be resampled
if ! which sox >&/dev/null; then
   echo "Please install 'sox' for resampling on ALL worker nodes!"
   exit 1
fi

## 

src=$1
dst=$2
tmp=`pwd`/data/data_tmp

[ ! -d $dst ] && mkdir -p $dst ;
mkdir -p data/data_tmp/ || exit 1;
text_read=$(cat `pwd`/data/lang/deCODE_read.tra)
text_LongA=$(cat `pwd`/data/lang/deCODE_LongA.tra)
text_ShortA=$(cat `pwd`/data/lang/deCODE_ShortA.tra)
text_ShortE=$(cat `pwd`/data/lang/deCODE_ShortE.tra)
text_ShortI=$(cat `pwd`/data/lang/deCODE_ShortI.tra)
text_ShortO=$(cat `pwd`/data/lang/deCODE_ShortO.tra)
text_ShortU=$(cat `pwd`/data/lang/deCODE_ShortU.tra)
text_ras=$(cat `pwd`/data/lang/deCODE_ras.tra)
text_spila=$(cat `pwd`/data/lang/deCODE_spila.tra)


## Create tmp files with desired content (everything)

grep .wav $src | cut -f1 | sed 's:.wav::' | sort > $tmp/files.lst || exit 1;
cat $tmp/files.lst | sed 's:.*\/::' > $tmp/fileID.lst
cat $tmp/fileID.lst | sed 's:_.*::' > $tmp/spkID.lst

## Create wav.scp,trans,utt2spk,spk2utt

paste -d' ' $tmp/fileID.lst $tmp/files.lst | sed 's/ / sox /' | sed 's/$/.wav -r 16000 -t wav - \|/' > $dst/wav.scp
paste -d' ' $tmp/fileID.lst $tmp/spkID.lst > $dst/utt2spk
utils/utt2spk_to_spk2utt.pl < $dst/utt2spk > $dst/spk2utt

for x in `cat $tmp/fileID.lst`; do
        
   if [[ $x == *"Reading"* ]]; then
	echo "$x $text_read"
   elif [[ $x == *"LongA"* ]]; then 
	echo "$x $text_LongA"
   elif [[ $x == *"MeasureA"* ]]; then 
	echo "$x $text_ShortA"
   elif [[ $x == *"MeasureE"* ]]; then 
	echo "$x $text_ShortE"
   elif [[ $x == *"MeasureI"* ]]; then 
	echo "$x $text_ShortI"
   elif [[ $x == *"MeasureO"* ]]; then 
	echo "$x $text_ShortO"
   elif [[ $x == *"MeasureU"* ]]; then 
	echo "$x $text_ShortU"
   elif [[ $x == *"Ras"* ]]; then 
	echo "$x $text_ras"
   elif [[ $x == *"Spila"* ]]; then 
	echo "$x $text_spila"
   fi
done > $dst/text

utils/validate_data_dir.sh --no-feats $dst || exit 1;
rm -rf data/data_tmp

echo "$0: successfully prepared data in $dst"

exit 0
