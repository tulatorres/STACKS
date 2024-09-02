#!/bin/bash

#SBATCH --job-name populations_LISY
#SBATCH -A phd_mlt
#SBATCH -t 0-12:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=10G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mtorres4@uwyo.edu
#SBATCH -e /project/rarity_landscapegenetics/scripts/err_out/err_pop_LISY_%A_%a.err
#SBATCH -o /project/rarity_landscapegenetics/scripts/err_out/std_pop_LISY_%A_%a.out


# load modules necessary
module load miniconda3/23.11.0

# Activate stacks environment
conda activate stacks2st

# defining file paths
POPMAP=/project/rarity_landscapegenetics/scripts/stacks_scripts/popmaps/LISY.txt
allstacks=/project/rarity_landscapegenetics/stacks_out/allstacks_out/stacks_lisy
OUT_DIR=/project/rarity_landscapegenetics/stacks_out/populations_out/populations_lisy

# reduced pop map directories
POPMAPR=/project/rarity_landscapegenetics/scripts/stacks_scripts/popmaps/LISY_reduced.txt
OUT_DIRR=/project/rarity_landscapegenetics/stacks_out/populations_out/populations_lisyR

# running populations code for LISY data
populations -P $allstacks \
-M $POPMAP \
-O $OUT_DIR \
-t 32 \
-r 50\
--fasta-samples --vcf --structure --genepop 



# start with a lower -r to start, then increase based on missing data output
# ran an salloc for: stacks-dist-extract populations.log.distribs samples_per_loc_prefilters
# start at 50% threshold, increase to 80% threshold
#/project/rarity_landscapegenetics/stacks_out/allstacks_out/stacks_lipi
#/project/rarity_landscapegenetics/stacks_out/gstacks_out/gstacks_lipi
