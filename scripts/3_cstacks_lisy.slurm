#!/bin/bash

#SBATCH --job-name cstacks_LISY
#SBATCH -A phd_mlt
#SBATCH -t 0-12:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=30G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mtorres4@uwyo.edu
#SBATCH -e /project/rarity_landscapegenetics/scripts/err_out/err_cstacks_LISY_%A_%a.err
#SBATCH -o /project/rarity_landscapegenetics/scripts/err_out/std_cstacks_LISY_%A_%a.out

# load modules necessary
module load miniconda3/23.11.0

# Activate stacks environment
conda activate stacks2

# defining file paths
OUT_DIR=/project/rarity_landscapegenetics/stacks_out/cstacks_out/cstacks_LISY
INPUT_DIR=/project/rarity_landscapegenetics/stacks_out/ustacks_out
POPMAP=/project/rarity_landscapegenetics/scripts/stacks_scripts/popmaps/LISY.txt

# run cstacks for LISY
# Building catalog of loci available for LISY samples

# moving into input directory
cd $INPUT_DIR

# creating a samples object 
samples=$(cat $POPMAP | cut -f 1)

for file in $samples
	do
    lisy_samples+="-s $file "
	done

# running cstacks
# cstacks -n 1 -o $OUT_DIR -p 32 $lisy_samples

cstacks -n 1 -o $OUT_DIR -p 16 $lisy_samples 
