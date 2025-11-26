import pandas as pd

# Get sample sheet path from CLI/config; can provide a default if you like
SAMPLESHEET = config.get("sample_sheet")
samples_df = pd.read_csv(SAMPLESHEET)
# Dict of samples
sample_dict = samples_df.set_index("sample", drop=False).to_dict(orient="index")
SAMPLES = samples_df["sample"].tolist()

# BED file listing genic regions in the TAIR10 coordinate system.
tair10_genic_regions = os.path.join(workflow.basedir, "TAIR10_GFF3_genes.bed")



# Hocus-pocus to get the test and reference panels to be processed in parallel.
CONFIG_REF = config["reference_panel"]
CONFIG_TEST = config["test_panel"]

pair_samples = ["reference", "test"]
def get_pair_input(wildcards):
    if wildcards.pair == "reference":
        return CONFIG_REF
    elif wildcards.pair == "test":
        return CONFIG_TEST
    else:
        raise ValueError(f"Unknown pair: {wildcards.pair}")



include: "rules/subset_syntenic_regions.smk"
include: "rules/convert_to_HDF5.smk"
include: "rules/ibdpainting.smk"

rule all:
    input:
        # expand("hdf5/{pair}.hdf5", pair=pair_samples)
        expand("ibdpainting/{sample}_ibd_scores.csv", sample=SAMPLES)