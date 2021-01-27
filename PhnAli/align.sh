#!/bin/bash

# Script to force-align utterances, using HMM-GMM model. 
# Relies on kaldi

. ./cmd.sh
. ./path.sh
set -e

stage=0
nj=10
mfccdir=`pwd`/data/mfcc

echo "$0 $@"  # Print the command line for logging
. utils/parse_options.sh || exit 1;


cont=$1
part=$(basename $cont | cut -f 1 -d '.')
echo ============================================================================
echo "                Data Preparation			                        "
echo ============================================================================

if [ $stage -le 0 ]; then

  local/data_prep_deCODE.sh $cont data/$part
  steps/make_mfcc.sh --cmd "$train_cmd" --nj $nj data/$part $mfccdir/$part/log $mfccdir/$part
  steps/compute_cmvn_stats.sh data/$part $mfccdir/$part/log $mfccdir/$part
  echo "Data prepared"
fi


echo ============================================================================
echo "		                 Getting ali for VAD	                        "
echo ============================================================================

if [ $stage -le 1 ]; then

  # Get aligns for VAD
  steps/align_fmllr.sh --nj $nj --cmd "$train_cmd" --retry_beam 80 data/$part data/lang `pwd`/tri4 tri4_ali_$part

  # Convert to phones
  echo "Converting alignments to phoneme transcription"
  for i in tri4_ali_$part/ali.*.gz; do
     ali-to-phones --ctm-output tri4/final.mdl ark:"gunzip -c $i|" -> ${i%.gz}.ctm;
  done;
  [ -e tri4_ali_$part/all.ctm ] && rm tri4_ali_$part/all.ctm
  cat tri4_ali_$part/*.ctm > tri4_ali_$part/all.ctm

  # Extract list of files that were successfully processed
  echo "Extracting list of successfully transcribed utterances into tri4_ali_$part/filesOK.scp"
  cut -d' ' -f1 tri4_ali_$part/all.ctm | sort -u > tri4_ali_$part/filesOK.scp

  # split per utterance
  echo "Splitting the alignment file on per-utterance basis into tri4_ali_$part/ctm/"
  mkdir -p tri4_ali_$part/ctm
  for file in $(cat tri4_ali_$part/filesOK.scp); do 
     grep "$file " tri4_ali_$part/all.ctm > tri4_ali_$part/ctm/${file}.ctm;
  done

  rm tri4_ali_$part/ali.*.ctm
fi
