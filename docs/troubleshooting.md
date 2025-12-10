# Troubleshooting

Errors are likely, and are quite hard to parse in snakemake.
Here are some suggestions.

## Lots of red text

Somewhere towards the bottom you'll see 
```
Exiting because a job execution failed. Look below for error messages
```

Further down in orange you'll see a mention of an **overall log file**:
```
Complete log(s): /groups/nordborg/projects/crosses/tom/02_library/ibdpainting_pipeline/test_data/output/.snakemake/log/2025-11-26T121533.704848.snakemake.log
```
That log likely gives the details of *every* job, including paths to log files for individual jobs, but probably won't tell you exactly what went wrong.
You can find **individual log files** by looking for lines that mention log files with something like
```sh
grep "log" /groups/nordborg/projects/crosses/tom/02_library/ibdpainting_pipeline/test_data/output/.snakemake/log/2025-11-26T121533.704848.snakemake.log
```

If you open those log files you may find something helpful.
If not, you can try grepping for lines that might help.
```sh
#
individual_log_file=/convoluted/path/to/single/logfile.log
grep "error" $individual_log_file # Try with capital letters as well
grep "OOM" $individual_log_file # Increase the memory
grep "TIMEOUT" $individual_log_file # Increase the time
grep "missing" $individual_log_file # Maybe missing file
grep "index" $individual_log_file # index files are a common culprit.
```

## Missing headers in the sample sheet

You see something like
```sh
KeyError in file "/big/log/path/ibdpainting_pipeline/snakefile.smk", line 10:  'sample'
```
or
```sh
KeyError in file "/big/log/path/ibdpainting_pipeline/snakefile.smk", line 10:  'expected_parents'
```

The pipeline is expecting a sample sheet with columns `sample` and `expected_parents`, but it didn't find one or both of those.
See the page on [input files](usage.md) and update your sample sheet.

## The sample name is not in the list of samples

If you see:
```sh
ValueError: The sample name is not in the list of samples in the input file.
```

This means that there is an entry in your sample sheet that is not in the VCF file for the test panel.
You can easily check which sample names are in a VCF file by using 
```sh
bcftools query -l my_genotypes.vcf.gz
```
Or check for a specific sample using 
```sh
bcftools query -l my_genotypes.vcf.gz | grep "sample_name"
```

## Expected parents aren't plotted

If you give one or more expected parents but the names do not match any sample names, then they won't be plotted in the outputs.
This won't throw an error (it probably should throw at least a warning).


## Missing data in the sample sheet

You see
```
InputFunctionException in rule idbpainting in file "/users/thomas.ellis/crosses/02_library/ibdpainting_pipeline/rules/ibdpainting.smk", line 16:
Error:
  KeyError: 'nan'
```

You have a missing entry in your sample sheet.
For example you passed this, which has a missing sample name in row 2.
```sh
sample,expected_parents
F2.05.015,6024 8249
,6024
S2.15.002,6184
F2.27.020,6184 8249
```

## Duplicate samples

You see something like
```sh
ValueError in file "/big/log/path/ibdpainting_pipeline/snakefile.smk", line 7:
DataFrame index must be unique for orient='index'.
```
Your sample sheet contains rows with duplicated sample names.
For example, this sample sheet has two entries for `F2.05.015`:

```sh
sample,expected_parents
F2.05.015,6024 8249
F2.05.015,6024
S2.06.002,6024
S2.15.002,6184
F2.27.020,6184 8249
```
Remove one of the duplicates.
If you rename something, don't forget that the new name needs to be present in the test VCF file.

## Memory or job time issues

If you grep individual log files like this:
```sh
grep "OOM" $individual_log_file
grep "MEMORY" $individual_log_file
```
and get matches, this indicates that the job in question was killed because it used too much memory.

Likewise if you get matches using:
```sh
grep "TIMEOUT" $individual_log_file
```
this indicates that the job did not complete in time.

The easiest thing to try is to increase the number you pass to `--restart-times` (see [usage](usage.md)).
This will tell the pipeline to repeat jobs that fail, but with increased resources.

You can also set resources explcitily by modifying the `resources` block of any rule.
For example, to set the rule [subset_syntenic_regions](../rules/subset_syntenic_regions.smk) to use 10GB memory (about 10k mb) and run for two hours (two times 60 minutes), change the block `resources` to 
```sh
    resources:
        qos = 'short',
        mem_mb = 10000
        runtime = 2*60
```

## Snakemake version

```sh
assert self.workflow.is_main_process
```
This is an issue with snakemake 9.14 and above.
Downgrading to 9.13 fixes it.

This ought not to be an issue anymore because I hardcoded versions in `environment.yml`, but it can be fixed.
With the conda environment open, check your version:
```
snakemake --version
```
Downgrade the version:
```
mamba install -n ibdpainting_pipeline "snakemake==9.13.7" -c bioconda
```