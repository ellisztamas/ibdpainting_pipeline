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
