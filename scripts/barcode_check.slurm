#!/bin/bash

#SBATCH --job-name BC_check
#SBATCH -A phd_mlt
#SBATCH -t 4-00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mtorres4@uwyo.edu
#SBATCH -e err_outs/BC_check_%A_%a.err
#SBATCH -o err_outs/BC_check_%A_%a.out

# defining the file
file="../rawdata/Torres1_S1_R1_001.fastq.gz"

# searching for cut sites 
zgrep CAATTC $file > ../barcodes_testing/seqs_cutsite.txt

# defines the variable within the cut sites
numcutsites=$(wc -l ../barcodes_testing/seqs_cutsite.txt)

# finding unique, possible barcodes 
cat ../barcodes_testing/seqs_cutsite.txt | awk -F "CAATTC" '{print $1}' | grep -E '^.{1,12}$' | sort | uniq -c | sort -n > ../barcodes_testing/barcodes_possible_uniq.txt

# finding number of reads
numreads=$(zgrep -c '^+$' $file)

# finding number of possible barcodes
numbarcodes=$(wc -l ../barcodes_testing/barcodes_possible_uniq.txt)

# summary information
echo "number of reads: $numreads" > ../barcodes_testing/barcodes_summary.txt
echo "number of possible barcodes: $numbarcodes" >> ../barcodes_testing/barcodes_summary.txt
echo "number of lines with cutsites: $numcutsites" >> ../barcodes_testing/barcodes_summary.txt
