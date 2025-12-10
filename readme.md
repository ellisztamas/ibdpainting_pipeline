# ibdpainting_pipeline

A snakemake wrapper for validating genotypes using [ibdpainting](https://github.com/ellisztamas/ibdpainting).

## Contents

<!-- TOC start (generated with https://github.com/derlin/bitdowntoc) -->

- [ibdpainting\_pipeline](#ibdpainting_pipeline)
  - [Contents](#contents)
  - [Premise](#premise)
  - [Installation](#installation)
    - [Clone this repo](#clone-this-repo)
    - [Dependencies](#dependencies)
  - [Use the pipeline](#use-the-pipeline)
  - [Outputs](#outputs)
  - [Acknowledgements](#acknowledgements)
  - [Contributing](#contributing)

<!-- TOC end -->

## Premise

`ibdpainting` compares SNP genotypes in a test panel to samples from a reference panel.
It is assumed the reference panel contains the expected parents of the test individuals.
See main ibdpainting repo for details of what the program does.

This repo is intended as a convenient wrapper for the program for samples from
*Arabidopsis thaliana* with reads mapped to the TAIR10 reference genome.

Here are the main steps:

1. Subset VCF files for the test and reference panels to a set of syntenic regions. In *A. thaliana*, that is acheived by using only SNPs in annotated genes.
2. Convert VCF files to HDF5 using `scikit-allel`.
3. Run `ibdpainting` for each sample.


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

## Use the pipeline

* See [here](docs/inputs.md) for the files and parameter settings.
* See [here](docs/usage.md) for how to run the pipeline
* See [here](docs/troubleshooting.md) for suggestions about troubleshooting in the (likely) case of errors.

## Outputs

The pipeline will create four directories in whatever you give as the output directory.

The main out is the directory `ibdpainting`.
For every sample this should contain:

* A `_plot_ibd.png` plot
* A `_ibd_scores.csv` file giving the genetic distances to each (pair of) candidate(s)
* If specified in the `config.yaml`, an interactive `_plot_ibd.html` plot.
* If specified in the `config.yaml`, an `_ibd_scores.csv` file giving the genetic distance at every window for every reference individual.

There will also be directories with logs and intermediate files.
Unless you plan to run the pipeline again, you can probably delete these.

## Acknowledgements

I used GPT 5.1 and Claude Sonnet for drafting rules.
I created the TOC for this README using https://bitdowntoc.derlin.ch/.


## Contributing

It would not be a terrible idea to put this in a singularity container.