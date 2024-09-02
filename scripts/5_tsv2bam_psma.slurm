#!/bin/bash

#SBATCH --job-name tsv2bam_psma
#SBATCH -A phd_mlt
#SBATCH -t 0-12:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=10G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mtorres4@uwyo.edu
#SBATCH -e /project/rarity_landscapegenetics/scripts/err_out/err_tsv2bam_PSMA_%A_%a.err
#SBATCH -o /project/rarity_landscapegenetics/scripts/err_out/std_tsv2bam_PSMA_%A_%a.out
#SBATCH --array=1-191

# load modules necessary
module load miniconda3/23.11.0

# Activate stacks environment
conda activate stacks2

# defining file paths
POPMAP=/project/rarity_landscapegenetics/scripts/stacks_scripts/popmaps/PSMA.txt
allstacks=/project/rarity_landscapegenetics/stacks_out/allstacks_out/stacks_psma


# creating sample object 
mapfile -t all_samples < <(cut -f 1 $POPMAP)

sample=${all_samples[($SLURM_ARRAY_TASK_ID-1)]}

# running sstacks code for LIPI data
tsv2bam -P $allstacks \
-s $sample \
-t 32

#/project/rarity_landscapegenetics/stacks_out/allstacks_out/stacks_psma
