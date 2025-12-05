# ibdpainting_pipeline

A snakemake wrapper for validating genotypes using [ibdpainting](https://github.com/ellisztamas/ibdpainting).

`ibdpainting` compares SNP genotypes in a test panel to samples from a reference panel.
It is assumed the reference panel contains the expected parents of the test individuals.
See main ibdpainting repo for details of what the program does.

This repo is intended as a convenient wrapper for the program for samples from
*Arabidopsis thaliana* with reads mapped to the TAIR10 reference genome.

Here are the main steps:

1. Subset VCF files for the test and reference panels to a set of syntenic regions. In *A. thaliana*, that is acheived by using only SNPs in annotated genes.
2. Convert VCF files to HDF5 using `scikit-allel`.
3. Run `ibdpainting`.

## Contents

<!-- TOC start (generated with https://github.com/derlin/bitdowntoc) -->

- [ibdpainting\_pipeline](#ibdpainting_pipeline)
  - [Contents](#contents)
  - [Installation](#installation)
    - [Clone this repo](#clone-this-repo)
    - [Dependencies](#dependencies)
  - [Inputs](#inputs)
  - [Usage](#usage)
    - [Define paths](#define-paths)
  - [Troubleshooting](#troubleshooting)
    - [Lots of red text](#lots-of-red-text)
  - [Acknowledgements](#acknowledgements)

<!-- TOC end -->

## Installation

### Clone this repo

Clone the repo to your project folder:
```sh
git clone https://github.com/ellisztamas/ibdpainting_pipeline.git
```

### Dependencies

A conda environment is provided to install the necessary dependencies.
This will create a conda environment called `ibdpainting_pipeline`.

```sh
cd ibdpainting_pipeline
mamba env create -f environment.yml
```

I recommend using mamba instead of conda to install the environment.

The conversion from VCF to HDF5 format relies on the `scikit-allel` package for Python.
This does not always cooperate with conda/mamba.
If it fails, you may be able to install it manually with `pip install scikit-allel`.

## Inputs

Input parameters and paths to input files are defined in `config.yml`.
The config file also explains what the inputs need to be.
Edit as necessary.

If you are using ibdpainting with a working directory (`snakemake [...] --directory`), then it is probably best to use absolute paths in this file.


## Usage

The pipeline is designed to submit individual steps to the CLIP cluster via the SLURM scheduler, so you only need to run the command to start the pipeline in a terminal (see below).

However, as the pipeline will take a long time, you should probably run this inside a `tmux` window so that the window stays active, even if your local machine goes to sleep.
([Here](https://www.howtogeek.com/671422/how-to-use-tmux-on-linux-and-why-its-better-than-screen/) is a tutorial on getting started with `tmux`).

### Define paths

Here is an example to run the test dataset, assuming your current working directory is set to the root of this pipeline.

Activate the conda environment.
```sh
conda activate ibdpainting_pipeline
```

Define paths to snakemake file, config file and where to store the output.
Change these paths as necessary.

```sh
# Input files
pipeline=$PWD/snakefile.smk
# Config file giving 
config_file=$PWD/config.yml
# Directory to store the output
outdir=$PWD/test_data/output
```

Run the pipeline via SLURM:

```sh
snakemake \
    --snakefile "$pipeline" \
    --configfile "$config_file" \
    --directory "$outdir" \
    --cores all \
    --executor slurm \
    --rerun-incomplete \
    --restart-times 2 \
    -j5
```

Some explanations:

* The convoluted arguments to `--config` pass the variables defined above to snakemake as wildcards. You could also put these in a config file, but this could get messy if you need to run the pipeline several times with different settings and aren't careful.
* The argument `-j N` tells the pipeline to run N jobs in parallel, assuming there are N input files. I used five as a place to start because the genotype calls are done by chromosome, and *Arabidopsis thaliana* has five chromosomes. Increase the number if you want to run more samples in parallel (for example, `-j 96` for a 96-well plate).
* `--rerun-incomplete` tells the pipeline to start any failed steps from scratch if you encounter and error and need to come back to it.
* `--restart-times 2` tells the pipeline to try failed jobs again. For a couple of resource intensive steps, it wil try again with additional memory and time.

Change these inputs as necessary.

## Troubleshooting

Errors are likely, and are quite hard to parse in snakemake.
Here are some suggestions.

### Lots of red text

Somewhere towards the bottom you'll see 
```
Exiting because a job execution failed. Look below for error messages
```

Further down in orange you'll see a mention of an overall log file:
```
Complete log(s): /groups/nordborg/projects/crosses/tom/02_library/ibdpainting_pipeline/test_data/output/.snakemake/log/2025-11-26T121533.704848.snakemake.log
```
That log likely gives the details of *every* job, including paths to log files for individual jobs, but probably won't tell you exactly what went wrong.
You can find individual log files by looking for lines that mention log files with something like
```sh
grep "log" /groups/nordborg/projects/crosses/tom/02_library/ibdpainting_pipeline/test_data/output/.snakemake/log/2025-11-26T121533.704848.snakemake.log
```

If you open those log files you may find something helpful.
If not, you can try looking for lines that might help.
```sh
#
individual_log_file=/convoluted/path/to/single/logfile.log
grep "error" $individual_log_file # Try with capital letters as well
grep "OOM" $individual_log_file # Increase the memory
grep "TIMEOUT" $individual_log_file # Increase the time
grep "missing" $individual_log_file # Maybe missing file
grep "index" $individual_log_file # index files are a common culprit.
```

## Acknowledgements

I used GPT 5.1 and Claude Sonnet for drafting rules.
I created the TOC for this README using https://bitdowntoc.derlin.ch/.