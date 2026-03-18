#!/bin/bash

#SBATCH --job-name populations_psma
#SBATCH -A phd_mlt
#SBATCH -t 0-12:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=10G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mtorres4@uwyo.edu
#SBATCH -e /project/rarity_landscapegenetics/scripts/err_out/err_pop_psma_%A_%a_%A_%a.err
#SBATCH -o /project/rarity_landscapegenetics/scripts/err_out/std_pop_psma_%A_%a.out


# load modules necessary
module load miniconda3/23.11.0

# Activate stacks environment
conda activate stacks2

# defining file paths
POPMAP=/project/rarity_landscapegenetics/scripts/stacks_scripts/popmaps/PSMA.txt
allstacks=/project/rarity_landscapegenetics/stacks_out/allstacks_out/stacks_psma
OUT_DIR=/project/rarity_landscapegenetics/stacks_out/populations_out/populations_psma

# reduced pop map directories
POPMAPR=/project/rarity_landscapegenetics/scripts/stacks_scripts/popmaps/PSMA_reduced.txt
OUT_DIRR=/project/rarity_landscapegenetics/stacks_out/populations_out/populations_psmaR

# running populations code for PSMA data
populations -P $allstacks \
-M $POPMAPR \
-O $OUT_DIRR \
-t 32 \
-r 70\
--fasta-samples --vcf --structure --genepop 



# start with a lower -r to start, then increase based on missing data output
# ran an salloc for: stacks-dist-extract populations.log.distribs samples_per_loc_prefilters
# start at 5%, then 50% threshold, increase to 80% threshold, then adjust
#/project/rarity_landscapegenetics/stacks_out/allstacks_out/stacks_lipi
#/project/rarity_landscapegenetics/stacks_out/gstacks_out/gstacks_lipi
