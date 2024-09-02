#!/bin/bash

#SBATCH --job-name process_radtags
#SBATCH -A phd_mlt
#SBATCH -t 4-00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mtorres4@uwyo.edu
#SBATCH -e /project/rarity_landscapegenetics/scripts/err_out/radtags_demux%A_%a.err
#SBATCH -o /project/rarity_landscapegenetics/scripts/err_out/radtags_demux%A_%a.out

module load miniconda3/23.1.0

## run stacks
conda activate stacks

## define file paths
infile="/pfs/tc1/project/rarity_landscapegenetics/rawdata/Torres1_S1_R1_001.fastq.gz"
#bcfile="/pfs/tc1/project/rarity_landscapegenetics/ipyrad_scripts/stacks_scripts/modified_frogs_barcodes_stacks.txt"
bcfile="/pfs/tc1/project/rarity_landscapegenetics/scripts/stacks_scripts/modified_frogs_barcodes_stacks.txt"
outdir="/pfs/tc1/project/rarity_landscapegenetics/stacks_out/radtags_out"

## run process radtags
### old code from stacks 1.4
#process_radtags -f $infile \
 -b $bcfile --inline_null \
 -i gzfastq \
 -o  $outdir \
 --renz_1 ecoRI  \
 --renz_2 mseI \
 -c -q -r -w 0.15 -s 10 -D \
 --adapter_mm 2 \
 --adapter_1 TACAGATCGGAAGATCTCGTATGCCGTCTTCTGCTTGA
 
 process_radtags -f $infile \
 -i gzfastq \
 -b $bcfile --inline_null \
 -o $outdir \
 --renz_1 ecoRI \
 --renz_2 mseI \
 -c -q -r -s 10 -D \
 --window-size 0.15 \
 --adapter_mm 2 \
 --adapter_1 TACAGATCGGAAGATCTCGTATGCCGTCTTCTGCTTGA

