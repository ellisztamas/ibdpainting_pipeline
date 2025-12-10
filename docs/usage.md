# Usage

The pipeline is designed to submit individual steps to the CLIP cluster via the SLURM scheduler, so you only need to run the command to start the pipeline in a terminal (see below).

However, as the pipeline will take a long time, you should probably run this inside a `tmux` window so that the window stays active, even if your local machine goes to sleep.
([Here](https://www.howtogeek.com/671422/how-to-use-tmux-on-linux-and-why-its-better-than-screen/) is a tutorial on getting started with `tmux`).

## Define paths

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

## Run the pipeline

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
