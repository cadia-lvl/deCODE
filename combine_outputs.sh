#!/bin/bash
# Copyright 2018 deCODE Genetics & Reykjavik University (Author : Michal Borsky). Apache 2.0.

# This combines all partial 'output' files into a single 'result' file
# The script is run after all jobs from slurm are finished
# The script scans the whole folder and looks for subfolders 'output.*'
# The script to extract vowel space area features is run afterwards
# Usage : ./combine_outputs.sh <folder_with_results> <output_file> 
#    ie : ./combine_outputs.sh results/results_071018 ../results/071018.feasts


echo "$0 $@"  # Print the command line for logging
if [ $# != 2 ]; then
  echo "Usage: ./combine_outputs.sh <results_folder> <output_file> "
  echo " e.g.: ./combine_outputs.sh results/results_071018 ../results/cleaned.feats"
  exit 1;
fi

# Combine outputs
find $1 -name 'output' -print0 | 
while IFS= read -r -d $'\0' line; do 

     if [[ ${line} =~ output.1/ ]]; then
	cat $line
     else
	sed -e 1d $line     
     fi
done > $2

# Run vowel space area script
cd multi_utterance
./run_command.m measure_derivative_parameters1 --in ../$2 --out ../$2.vowel_space
