#!/bin/bash

#SBATCH --job-name gstacks_LIPI
#SBATCH -A phd_mlt
#SBATCH -t 0-12:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=10G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mtorres4@uwyo.edu
#SBATCH -e /project/rarity_landscapegenetics/scripts/err_out/err_gstacks_LIPI_%A_%a.err
#SBATCH -o /project/rarity_landscapegenetics/scripts/err_out/std_gstacks_LIPI_%A_%a.out
#SBATCH --array=1-36

# load modules necessary
module load miniconda3/23.11.0

# Activate stacks environment
conda activate stacks2

# defining file paths
POPMAP=/project/rarity_landscapegenetics/scripts/stacks_scripts/popmaps/LIPI.txt
allstacks=/project/rarity_landscapegenetics/stacks_out/allstacks_out/stacks_lipi
OUT_DIR=/project/rarity_landscapegenetics/stacks_out/gstacks_out/gstacks_lipi


# creating sample object 
mapfile -t all_samples < <(cut -f 1 $POPMAP)

sample=${all_samples[($SLURM_ARRAY_TASK_ID-1)]}

# running gstacks code for LIPI data
gstacks -P $allstacks \
-M $POPMAP \
-O $OUT_DIR \
-t 32 \

#/project/rarity_landscapegenetics/stacks_out/allstacks_out/stacks_lipi
#/project/rarity_landscapegenetics/stacks_out/gstacks_out/gstacks_lipi

