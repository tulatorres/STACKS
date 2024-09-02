#!/bin/bash

#SBATCH --job-name ustacks
#SBATCH -A phd_mlt
#SBATCH -t 0-12:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=10G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mtorres4@uwyo.edu
#SBATCH -e /pfs/tc1/project/rarity_landscapegenetics/scripts/err_out/err_ustacks_%A_%a.err
#SBATCH -o /pfs/tc1/project/rarity_landscapegenetics/scripts/err_out/std_ustacks_%A_%a.out
#SBATCH --array=1-313


# load modules necessary
module load miniconda3/23.11.0

# Activate stacks environment
conda activate stacks2

# Set working directory to where the index files and trimmed_reads directory are
cd /project/rarity_landscapegenetics/stacks_out/radtags_out

OUT_DIR=/project/rarity_landscapegenetics/stacks_out/ustacks_out


# use a loop to find all the files with pattern AR*.fq.gz 
#     and assign them to a bash array
for x in AR*.fq.gz 
do   
  infiles=(${infiles[@]} "${x}")
done


## For whichever SLURM_ARRAY_TASK_ID index a job is in, get the sample 
## here, I subtract 1 from the $SLURM_ARRAY_TASK_ID because bash indexing starts at zero
##   I think it's less confusing to subtract 1 here than to remember to do it when 
##   specifying the number of jobs for the array

sample=${infiles[($SLURM_ARRAY_TASK_ID-1)]}

filepre="${sample%%.*}"

# run ustacks
ustacks -f $sample \
 -o $OUT_DIR \
 -p 8 \
 -t gzfastq \
 -M 3 \
 -m 3 \
 -p 16
 ##  -t gzfastq \