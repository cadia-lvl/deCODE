#!/bin/bash

# Evenly distributing readings over the list. Including unaligned files.
# The main script that extract voice sourse and vocal tract features from all
# recordings in a database (folder). The parallelization is done using slurm.
# The phone alignment relies on Kaldi.

# Begin configuration section.
stage=0
nj=100
work_dir=`pwd`
# End configuration section.

echo "$0 $@"  # Print the command line for logging

. utils/parse_options.sh || exit 1;

if [ $# -ne 1 ] ; then
   echo "Usage: $0 <folder> ";
   echo "e.g.: ./run.sh /nfs/transfer/results_021217"
   echo "Note: <tmp-dir> defaults to ./tmp"
   echo "Options: "
   echo "  --nj <nj>                     # number of parallel jobs"
   echo "  --stage <stage_lvl>           # stage of the script, usually 0"
   exit 1;
fi

## Variables
source_dir=$1
name=$(echo $source_dir | sed 's/\/$//' | sed 's/.*\///')
scp=tmp/$name.scp


## Create content list with files for futher processing
if [ $stage -le 0 ]; then
   utils/make_cont.sh $source_dir $work_dir/tmp/$name.cont
fi

## Run ASR to obtain phone alignment
if [ $stage -le 1 ]; then
   (cd PhnAli; ./align.sh --nj $nj $work_dir/tmp/$name.cont)   
fi

## Run octave scripts to extract features
if [ $stage -le 2 ]; then

   # Create master scp with all files to be processed. This files can be used if there is no parallelization
   echo "Creating list of files to extract VoiceSource and VocalTract feats in $scp"
   cat PhnAli/tri4_ali_$name/filesOK.scp | xargs -I% grep %.wav tmp/$name.cont | perl -p -i -e "s/\r//g" | \
     awk -v "dir=$name" '{printf "./run_command.m measure_voice_parameters --audio %s --out results/%s/output --gender %s --smark %s --emark %s --ctm PhnAli/tri4_ali_%s/ctm/%s.ctm\n", $1, dir, $4, $5, $6, dir, $2}' > $scp

   # Split the master into nj number of lists
   echo "Spliting $scp into $nj number of sublist in results/$name/"
   rm -rf results/$name
   split_scps=""
   for n in $(seq $nj); do
     mkdir -p results/$name/output.$n || exit 1;
     split_scps="$split_scps results/$name/output.$n/$name.$n.sh"
   done
   perl utils/split_scp.pl $scp $split_scps || exit 1;

   # rename outputs for each split and submit to slurm
   for n in $(seq $nj); do
     echo '#!/bin/bash' > results/$name/output.$n/$n.tmp
     echo "[ -e results/$name/output.$n/output ] && rm results/$name/output.$n/output" >> results/$name/output.$n/$n.tmp
     cat results/$name/output.$n/$name.$n.sh | sed "s/output/output.$n\/output/" >> results/$name/output.$n/$n.tmp
     mv results/$name/output.$n/$n.tmp results/$name/output.$n/$name.$n.sh 
   done
fi

if [ $stage -le 3 ]; then
   echo "Final processing and submitting jobs to slurm"
   for n in $(seq $nj); do
     # Send to slurm
     sbatch -o results/$name/output.$n/log results/$name/output.$n/$name.$n.sh
   done
fi
