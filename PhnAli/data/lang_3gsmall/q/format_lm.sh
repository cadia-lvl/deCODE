#!/bin/bash
cd /home/staff/inga/kaldi/egs/althingi/s5
. ./path.sh
( echo '#' Running on `hostname`
  echo '#' Started at `date`
  set | grep SLURM | while read line; do echo "# $line"; done
  echo -n '# '; cat <<EOF
utils/format_lm.sh data/Mlang data/Mlang_3gsmall/kenlm_3g.arpa.gz data/local/Mdict/lexicon.txt data/Mlang_3gsmall 
EOF
) >data/Mlang_3gsmall/format_lm.log
if [ "$CUDA_VISIBLE_DEVICES" == "NoDevFiles" ]; then
  ( echo CUDA_VISIBLE_DEVICES set to NoDevFiles, unsetting it... 
  )>>data/Mlang_3gsmall/format_lm.log
  unset CUDA_VISIBLE_DEVICES.
fi
time1=`date +"%s"`
 ( utils/format_lm.sh data/Mlang data/Mlang_3gsmall/kenlm_3g.arpa.gz data/local/Mdict/lexicon.txt data/Mlang_3gsmall  ) &>>data/Mlang_3gsmall/format_lm.log
ret=$?
sync || truetime2=`date +"%s"`
echo '#' Accounting: begin_time=$time1 >>data/Mlang_3gsmall/format_lm.log
echo '#' Accounting: end_time=$time2 >>data/Mlang_3gsmall/format_lm.log
echo '#' Accounting: time=$(($time2-$time1)) threads=1 >>data/Mlang_3gsmall/format_lm.log
echo '#' Finished at `date` with status $ret >>data/Mlang_3gsmall/format_lm.log
[ $ret -eq 137 ] && exit 100;
touch data/Mlang_3gsmall/q/done.24594
exit $[$ret ? 1 : 0]
## submitted with:
# sbatch --export=PATH  --ntasks-per-node=1    --open-mode=append -e data/Mlang_3gsmall/q/format_lm.log -o data/Mlang_3gsmall/q/format_lm.log  /home/staff/inga/kaldi/egs/althingi/s5/data/Mlang_3gsmall/q/format_lm.sh >>data/Mlang_3gsmall/q/format_lm.log 2>&1
