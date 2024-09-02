#!/bin/bash

#SBATCH --job-name sstacks_PSMA
#SBATCH -A phd_mlt
#SBATCH -t 0-12:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=30G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mtorres4@uwyo.edu
#SBATCH -e /project/rarity_landscapegenetics/scripts/err_out/err_sstacks_PSMA_%A_%a.err
#SBATCH -o /project/rarity_landscapegenetics/scripts/err_out/std_sstacks_PSMA_%A_%a.out
#SBATCH --array=1-191

# load modules necessary
module load miniconda3/23.11.0

# Activate stacks environment
conda activate stacks2

# defining file paths
OUT_DIR=/project/rarity_landscapegenetics/stacks_out/sstacks_out/sstacks_psma
INPUT_DIR=/project/rarity_landscapegenetics/stacks_out/cstacks_out/cstacks_PSMA
POPMAP=/project/rarity_landscapegenetics/scripts/stacks_scripts/popmaps/PSMA.txt
ustacks=/project/rarity_landscapegenetics/stacks_out/ustacks_out

# creating sample object 
mapfile -t all_samples < <(cut -f 1 $POPMAP)

sample=${all_samples[($SLURM_ARRAY_TASK_ID-1)]}

# running sstacks code for LISY data
sstacks -c $INPUT_DIR \
-s $ustacks/$sample \
-p 32 \
-o $OUT_DIR
