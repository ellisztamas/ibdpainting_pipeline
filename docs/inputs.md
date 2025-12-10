# Input files and parameters

Here is an overview of the input data and parameters to run the pipeline.

## Contents

- [Input files and parameters](#input-files-and-parameters)
  - [Contents](#contents)
  - [`config.yml`](#configyml)
  - [Data files](#data-files)
    - [Sample sheet](#sample-sheet)
    - [Genotype data](#genotype-data)
  - [Additional settings](#additional-settings)


## `config.yml`

Input parameters and paths to input files are defined in a config file call `config.yml`.
There is an [example config.yml file](../config.yml) in the top level of this directory.
Create as many copies of this as you need, and edit as necessary for each analysis.
See the docs on [usage](./usage.md) to see how to specify the path to the config file.

If you are using ibdpainting with a working directory (`snakemake [...] --directory`), then it is probably best to use absolute paths in this file.

## Data files

### Sample sheet

The pipeline relies on a a comma-separated sample sheet with columns:

1. `sample`: The name of a single sample to be tested. Every sample name must appear in the VCF file for the test panel.
2. `expected_parents`: Names of expected parents. If there are more than one, separate with **whitespace** (not a tab!). In principle there can be more than two, but I haven't tested this. Every expected parent must appear in the reference panel.

The sample sheet can also contain other columns as long as these are present.

Here is an example.

```cs
sample,expected_parents
F2.05.015,6024 8249
S2.06.002,6024
S2.15.002,6184
F2.27.020,6184 8249
```

Notice that the first and last samples have two expected parents (they are crosses), but the 2nd and 3rd have only one (they are selfed).

### Genotype data

Supply paths to two VCF files for the test and reference panels,

Ensure that all test sample names are in the test-sample VCF, and all expected parents are in the reference VCF.
You can easily check which sample names are in a VCF file by using 
```sh
bcftools query -l my_genotypes.vcf.gz
```
Or check for a specific sample using 
```sh
bcftools query -l my_genotypes.vcf.gz | grep "sample_name"
```

It is strongly recommended to run `ibdpainting` only on syntenic regions.
This pipeline will automatically filter both VCF files for SNPs in positions matching *Arobidopsis thaliana* genes.
If you want to disable that, the simplest thing to do would be to remove this line from the `subset_syntenic_regions` rule:
```sh
--regions-file {input.bed} \
```

If you are using bisulphite data consider pre-filtering out SNPs that vary as C to T.


## Additional settings #

* `window_size`: gives the window size (in base pairs) to calculate genetic distances. Defaults to 500kb.
* `keep_ibd_table`: If set, write an intermediate text file giving genetic distance between the crossed individual and each candidate at each window in the genome. Defaults to `False`, because these can be quite large.
* `max_to_plot`: Optional number of the best matching candidates to plot so that the HTML files do not get too large and complicated. Ignored if this is more than the number of samples.
* `interactive`: If set, save the output plot as an interactive HTML plot including information on candidates within the plot.
* `height`: Height in pixels of the output PNG file. Defaults to 675.
* `width`: Height in pixels of the output PNG file. Defaults to 900.  
*`heterozygosity`: If set, plot the heterozygosity of the test individual in the output plot. Defaults to True