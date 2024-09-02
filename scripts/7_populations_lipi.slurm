#!/bin/bash

#SBATCH --job-name populations_LIPI
#SBATCH -A phd_mlt
#SBATCH -t 0-12:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=10G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mtorres4@uwyo.edu
#SBATCH -e /project/rarity_landscapegenetics/scripts/err_out/err_pop_LIPI_%A_%a.err
#SBATCH -o /project/rarity_landscapegenetics/scripts/err_out/std_pop_LIPI_%A_%a.out


# load modules necessary
module load miniconda3/23.11.0

# Activate stacks environment
conda activate stacks2st

# defining file paths
POPMAP=/project/rarity_landscapegenetics/scripts/stacks_scripts/popmaps/LIPI_reduced.txt
allstacks=/project/rarity_landscapegenetics/stacks_out/allstacks_out/stacks_lipi
#gstacks=/project/rarity_landscapegenetics/stacks_out/gstacks_out/gstacks_lipi
OUT_DIR=/project/rarity_landscapegenetics/stacks_out/populations_out/populations_lipiR

# running populations code for LIPI data
populations -P $allstacks \
-M $POPMAP \
-O $OUT_DIR \
-t 32 \
-r 80 \
--fasta-samples --vcf --structure --genepop 



# start with a lower -r to start, then increase based on missing data output
# ran an salloc for: stacks-dist-extract populations.log.distribs samples_per_loc_prefilters
# increased from 5% to 50% to 70%
#/project/rarity_landscapegenetics/stacks_out/allstacks_out/stacks_lipi
#/project/rarity_landscapegenetics/stacks_out/gstacks_out/gstacks_lipi
#