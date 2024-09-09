---
title: "Stacks"
output:
  html_document:
    toc: true
    theme: united
---


## Running Stacks on Amphibian Tissue Data from Wetlands in SE Wyoming
If you are using this for reference code: skip to 0b.

### 0. About the Read Me + Data Conditions ####
#### 0a. General Information
This README document is a guide for the Stacks pipeline that I (MLT) used, along with some specifics on my data.

This project is for Chapter 3 of MLT dissertation research (functional connectivity)

- 800+ samples were collected from various wetland sites on public lands in SE Wyoming
- Tissue data processed specifically covers 3 species:
	1. Northern Leopard Frog (*Lithobates pipiens*, LIPI)
	2. Wood Frog (*Lithobates sylvaticus*, LISY)
	3. Boreal Chorus Frog (*Pseudacris maculata*, PSMA)
- 310 tissue samples processed
	1. LIPI: 36
	2. LISY: 83
	3. PSMA: 192
- One sample, AR0084 (LISY), did not have enough data associated with it down the pipeline and was causing problems. Removed from samples.
- The genetic data was collected via buccal swabs from metamorphosed frogs and tissue samples from tadpole tails (~33% of tail can be safely harvested from the animal, per IACUC approval and cited best practices)
- The genetic data was extracted using the Qiagen Blood and Tissue Kit
- Tissue samples were processed at the UWyo [Genome Technologies Laboratory](https://microcollaborative.atlassian.net/wiki/spaces/MICLAB/overview) (GTL) in Laramie, WY, and were processed by Gregg Randolf
- Genetic data was assayed using ddRAD (restriction enzymes EcoR1 and Mse1 were used)
- Resulting data was processed using [Stacks 2.65](https://catchenlab.life.illinois.edu/stacks/) by MLT and Dr. Sean Harrington (SH) of INBRE

#### 0b. **Before you begin** #####
1. Have a [Beartooth or MedicineBow account](https://arccwiki.atlassian.net/wiki/spaces/DOCUMENTAT/pages/1683587073/Beartooth) or access to a HPC (NOTE: Beartooth will be obsolete in late 2024 - MedicineBow is the new HPC that you'll need an account to)
2. Once on the HPC, STACKS needs to be on the latest version. Run the following code:
```{r}
module load miniconda3/23.11.0
conda create -n stacks2 -c bioconda -c conda-forge stacks=2.65
conda activate stacks2
```
- Change `stacks=` to the latest version of stacks. In this case (2024), STACKS v 2.65 is the latest version
- Only need to run the `conda create` once 
- Always activate stacks2! 

- Also before processing, upload your fastq.gz file (or whichever zip file has your genetic data) onto HPC of choice (see note below)
- I am using [cyberduck](https://cyberduck.io/) to help with uploading and finding files, organizing data, and writing slurm scripts (**highly recommend**)

#### 0c. Data Prep and Organization #####
CODE: (f) = folder | (txt) = text file | (slurm) = slurm script | (o) = other | [n] = MLT note

I organized my files like below on beartooth using cyberduck: 
- (f) rawdata: folder where the gzfastq files received from the GTL are housed
- (f) stacks_scripts: a folder where all your scripts are located, including:
	- (f) popmap: a folder with text files of species/sample and species/reduced samples. Includes: 
		- (txt) species text file: text file with sample name and species (if using multiple species). Columns should be: SampleName, Species. Do not include headers in this file
			- [n] I found it easiest to create this file in excel, then save it into Beartooth using Cyberduck
		- (txt) XXXX_reduced: species text file that will be used in Step 7. Duplicate your species text file to create, then rename.
	- (txt) barcode text file: a text file that has each sample's barcode, provided by the GTL. Columns should be: Barcode, Sample Name. Do not include headers in this file
		- [n] Again, create this file using excel, then save it into Beartooth using Cyberduck
	- (slurm) All stacks scripts for steps 1 - 7
- (f) err_out: a folder where error output goes when running slurm script
- (f) stacks_out: a folder where all Stacks output goes. 
	- (f) allstacks_out: All stacks output from steps 1-6 goes in this folder
 		- [n] **IMPORTANT NOTE**: I initially had several folders for each Stacks step and per species to try and keep organized
 		- **DO NOT DO THIS**. Keep all stacks output in one folder
  		- Downstream Stacks processes will not work unless all Stacks output is in one folder
		- MLT code will have outputs going to separate files per pipeline process and per species initially.
  		- I created the (f) allstacks_out within the (f) stacks_out, then copied all of my files to allstacks_out to fix this issue
	- (f) populations_out: the last step for Stacks can be separated into species-specific folders. Includes:
		- (f) populations_xxxx: Output for initial run of the populations stacks function for species code XXXX (LIPI, LISY, or PSMA) (see 0d for details)
		- (f) populations_xxxxR: Reduced species list for population map

If the above was confusing, below is a condensed example (with reduced descriptions) of how I organized my folders on the HPC. Can use or modify:
```
Folder 1: RawData

Folder 2: StacksScript
- Folder 2a: popmap
	- TextFile 2aa: species text file (with 2+ species; still include if using one species, maybe use lab and sample name)
	- TextFile 2ab: species reduced text file (with 2+ species; still include if using one species, maybe use lab and sample name)
- TextFile: barcodes file
- All Slurm Scripts

Folder 3: err_out

Folder 4: stacks_out
- Folder 4a: allstacks_out
- Folder 4b: populations_out
- Folder 4c: populations_outR
```

#### 0d. General Pipeline #####
For Stacks, the general pipeline programs used for denovo sequencing are as follows:
1. **process_radtags:** proceses the raw reads from the GTL lab
2. **ustacks:** takes input set of short-read sequences, aligns them into unique, matching stacks, compares stacks into set of loci and detect SNPs at each loci using max likelihood framework
3. **cstacks:** building the catalog from ustacks output. Creates a set of consensus loci and merges alleles together
4. **sstacks:** uses ustacks and cstacks output. Matches the ustacks to the cstacks catalog
5. **tsv2bam:** transposes the data so it's oriented by loci instead of by sample
6. **gstacks:** pulls in paired-end reads (if available), assembles the paired-end contig, and merges it with single-end loci. Also, align reads to loci and call SNPs
7. **populations:** compute population-level summary statistics, can output site-level SNP calls in VCF format, and also output SNPs for analyses in STRUCTURE or in Phylip format 

Other useful programs:
- stacks-dist-extract: exports particular section of Stacks log or distribs file for easy viewing or for plotting. Used to identify samples that need to be removed due to having too few loci identified and to help data clean-up 

#### 0e. Helpful Bash Code #####
- cd = move to a different directory
	- e.g., `cd /project/rarity_landscapegenetics/stacks_out`
	- cd .. = move up one directory
	- cd ../.. = move up two directories

- sbatch = running a slurm file
	- e.g., `sbatch 1_frogs_demux_stacks.slurm`
	- need to be in the folder where the slurm file is in for it to run successfully
	- use cd to navigate to scripts folder/directory

- less = looks at a file in bash. Larger files are easier to look at in bash vs cyberduck

- q = quits out of a less file

- cp = copy
	- to move files around, can copy and paste them into a file
	- e.g., cp /project/rarity_landscapegenetics/stacks_out/ustacks_out/lipi/AR0003.alleles.tsv.gz /project/rarity_landscapegenetics/stacks_out
	- easy and quick to move large files around, vs in cyberduck
	- If accidentally saved file in a weird spot, can move it easily using copy function


### 1. Demultiplexing the data using **process_radtags** ####
- see **1_frogs_demux_stacks.slurm for this code** in [scripts](https://github.com/tulatorres/STACKS/tree/5a5ff6a77b05e6e3fe0e1903cc5ea962e7351ef3/scripts) folder 
to separate the data by barcodes, need to demultiplex the data via process_radtags
- For my data, I have a single-end barcode
- For this process, I demuxed my data by indicating what the barcode/index is
- Create a slurm script using the normal sbatch directives + commands. Header includes:

```{r}
#!/bin/bash  
#SBATCH --job-name QQQQ 
#SBATCH -A WWWW
#SBATCH -t 4-00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --mail-type=All
#SBATCH --mail-user=XXXX@uwyo.edu
#SBATCH -e /project/YYYY/err_out/QQQQ%A_%a.err
#SBATCH -o /project/YYYY/err_out/QQQQ%A_%a.output
```
...where:
```
- QQQQ = job name for slurm file (e.g., process_radtags)
- WWWW = account this process is running in (name of account on Beartooth)
- nodes = how many beartooth nodes will be used for this project (1 is usually fine)
- cpus-per-task: how many cpus for running this slurm script. Usually is fine at 16, but I had to modify this value for some of the larger processes
- mem: how much memory is needed for task. I've also had to modify this a bit for osme of the tasks
- mail-type: include and ignore
- mail-user: include your preferred email so beartooth can send you email updates on the processes running
- e : error output file location + file extension
- o : same as above, just including more information
```

General notes for Step 1:
- This is demultiplexing the gzfastq files received from the GTL lab.
- **Demultiplex**: separates and assigns clusters of DNA to a sample from single stream that was combined through multiplexing
- GTL multiplexes the data into one or two lanes. All of my sample's genetics are combined into one file.
- This demultiplex step searches for each sample via the barcodes provided in the barcodes file, then separates into individual samples
- infile should be the gzfastq files
- know what enzyme(s) were used for this step
  
**IMPORTANT NOTE**
- GTL added a couple extra nucleotides to my species' barcodes (in my data, an extra C was added). For MLT data, SH modified the barcodes text file to add the extra nucleotide(s) [[modified_barcodes file](https://github.com/tulatorres/STACKS/blob/5a5ff6a77b05e6e3fe0e1903cc5ea962e7351ef3/scripts/modified_frogs_barcodes_stacks.txt)]
- to search for whether extra nucleotides were added to your barcodes, use the following example:
- `zgrep AATTGGCC frogs.fastq.gz`, where AATTGGCC is one of your barcodes (and `frogs.fastq.gz` is your gzfastq file)
- use Control + z to quit bash process :) 

### 2. Creating unique stacks using **ustacks** ####
- See **2_frogs_ustacks.slurm** in [scripts](https://github.com/tulatorres/STACKS/tree/5a5ff6a77b05e6e3fe0e1903cc5ea962e7351ef3/scripts) folder for code
- This step takes a set of short-read sequences as input and aligns them into exactly-matching stacks (aka, putative alleles)
- It then forms a set of putative loci and detect SNPs at each locus using max likelihood framework
- General Notes for Step 2:
	- In slurm header: include an array at end
 		- Arrays will process each sample more efficiently (MLT: to my understanding)
  		- Array code looks like the following:
			 ` #SBATCH --array=1-XXX `
		- ...where XXX = how many total samples you are processing
	- SH added a loop to find all the fields with pattern AR in the fastq.gz file
	- Add an array to the SBATCH setting (#SBATCH --array=1-N), where N = total number of samples
		- All samples will be processed in pipeline at the same time
		- Faster and more efficient this way
	- Bash indexing starts with 0, so to ensure the samples align, we add a -1 to each ID (line 41 in code)
	- to check if we're calling the correct sample names, we can enter an salloc session in Bash/Beartooth:

Example of running an salloc session and getting onto a node:
```{r}
salloc --account=rarity_landscapegenetics --time=2:00:00 --mem=20G
```

If you forget how to enter an salloc session, you can always search in Bash using history

```{r}
history | grep salloc
```

The above code in bash will call all the times you've run an salloc session and what you entered for memory, time, etc.

### 3. Creating the catalog for each species using **cstacks** ####
See **3_cstacks_XXXX.slurm**, where XXXX = each species, in [scripts](https://github.com/tulatorres/STACKS/tree/5a5ff6a77b05e6e3fe0e1903cc5ea962e7351ef3/scripts) folder for slurm code

- This step builds the catalog for each species using ustacks output. 
- If using multiple species, create a slurm file for each species
- Be sure you're referencing the correct popmap text file if you are processing different species
- Again, quick reminder to **keep all stacks output** (i.e., the OUT_DIR) **to the same folder**
	- You should have two file paths: DIR = stacks_out directory, and POPMAP = popmap directory
	- You won't need to move into the input directory, but move into the directory in general (i.e., Line 30 = cd $DIR)
	- *I did not do the above in the original set of code*; I had to copy and paste all my files into the same folder near the end of processing
- In the code, SH created a samples object that calls each species' samples using the popmap file
- do not use #SBATCH --array for this step (remove from code)

### 4. Creates sets of putative loci (i.e., stacks) with **sstacks** ####
See **4_sstacks_XXXX.slurm**, in where XXXX = species, in [scripts](https://github.com/tulatorres/STACKS/tree/5a5ff6a77b05e6e3fe0e1903cc5ea962e7351ef3/scripts) folder for slurm code

- This step creates the putative loci stacks for each species
- Include the #SBATCH --array=1-Ns, where Ns = total number of samples per species
- Like step 3, create a slurm file for each species
- sstacks code should look like this:

```
sstacks -P $DIR \
- s $DIR/$sample \
-p 32 \
-o $DIR 
```

### 5. Transpose and orient loci with tsv2bam ####
See **5_tsv2bam_XXXX.slurm**, where XXXX = each species, in [scripts](https://github.com/tulatorres/STACKS/tree/5a5ff6a77b05e6e3fe0e1903cc5ea962e7351ef3/scripts) folder for slurm code

- THis step sorts single-end reads so they occur in the same order
- Output shows the raw reads aligned to the loci constructed by the single-end analysis (ustacks/cstacks/sstacks)
- Need to do this so we can examine and compare loci across the metapopulation 

General notes:
- include the SBATCH --array 
- this step is the one that will not run unless all of your Stacks output is in one folder (ustacks/cstacks/sstacks)


### 6. Incorporate, assemble and merge a contig, and align reads with **gstacks** ####
See **6_gstacks_XXXX.slurm**, where XXXX = each species, in [scripts](https://github.com/tulatorres/STACKS/tree/5a5ff6a77b05e6e3fe0e1903cc5ea962e7351ef3/scripts) folder for slurm code

- For denovo analyses, gstacks looks at all the output of stacks
- THen, it incorporates paired-end reads (if available), then assembles paired-end reads into a contig
- Next, it merges the contig with the single-end locus, and it alogns the reads from individual samples to the locus
- This step identifies SNPs within the metapopulation for each loci and genotypes each individual
- You can also remove PCR duplicates in this step if you want

Nothing of note for this step. Runs very quickly
Do not need an array for this step


### 7. Final step: **populations** ####
See **7_populations_XXXX.slurm**, where XXX = each species, in [scripts](https://github.com/tulatorres/STACKS/tree/5a5ff6a77b05e6e3fe0e1903cc5ea962e7351ef3/scripts) folder for slurm code

- You made it!! Final step before we get to use our genetic data!
- As seen above, you can create a folder that houses this data for each of your species.
- In this step, you can save your genetic data in the file format that you need for further analyses
>> I'm using fasta-samples, vcf, structure, and genepop
>> this gives me a variety of output files that I can mess with when running code in Randolf
>> If you're doing phylogenetic analyses, there are outputs for those files as well

**BUT, BEFORE RUNNING THE CODE AND WIPING YOUR HANDS OF BEARTOOTH, FOLLOW THE BELOW STEPS**
- In **populations**, you must remove samples that have high amounts of missing data 
- Use the `-r` option to find those samples and remove them from your dataset
- the `-r` option is what percent threshold of missing data is present in the data
- Start `-r` at a lower value (50 percent)
- Next, enter an salloc session. When done, run the following in-line in Bash:
>> `stacks-dist-extract populations.log.distribs samples_per_loc_prefilters`
>> This above code will give you the amount of loci you have left to work with
>> An acceptable amount of loci is in the thousands. Any sample less than 1000 needs to be removed
>> Remove the sample(s) that have low loci amount from the reduced_XXXX.txt file (see Section 0b.)
- Once samples are removed, re-run the code with a higher `-r` percentage (about 80% threshold). Run the stacks-dist-extract code again
>> Remove samples again from the reduced_XXXX.txt file again
>> Rerun populations code again to double-check you have acceptable amounts of missing data


### Extra Info
#### Errs_Outs
error with AR0084, "data appears to be unique" (most likely not enough data)

removing this particular sample

#### updating stacks
conda create -n stacks2 -c bioconda -c conda-forge stacks=2.65

