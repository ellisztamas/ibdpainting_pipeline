# Numeric arguments passed to ibdpainting.
window_size=config['window_size', 500000]
max_to_plot=config['max_to_plot', 20]
height: config['height', 675]
width: config['width', 900]

# Boolean flags passed to ibdpainting 
interactive = config.get("interactive", True)
plot_heterozygosity= config.get("plot_heterozygosity", True)
keep_ibd_table=config.get("keep_ibd_table", False)

def interactive_flag():
    return "--interactive" if interactive else "--no-interactive"
def heterozygosity_flag():
    return "----plot_heterozygosity" if plot_heterozygosity else "--no-plot_heterozygosity"
def keep_ibd_table_flag():
    return "----keep_ibd_table" if keep_ibd_table else "--no-keep_ibd_table"


rule idbpainting:
    input:
        ref  = "hdf5/reference.hdf5",
        test = "hdf5/test.hdf5"
    output:
        "ibdpainting/{sample}_ibd_scores.csv",
        "ibdpainting/{sample}_plot_ibd.png"
    params:
        sample_name = lambda wildcards: wildcards.sample,
        expected_parents=lambda wildcards: sample_dict[wildcards.sample]['expected_parents'],
        output_dir="ibdpainting/{sample}"
    resources:
        qos = 'rapid',
        mem_mb = 10*1024,
        runtime = 60
    shell:
        """
        ibdpainting \
            --input {input.test} \
            --reference {input.ref} \
            --window_size {window_size} \
            --max_to_plot {max_to_plot} \
            --height {height} \
            --width {width} \
            --sample {params.sample_name} \
            --expected_match {params.expected_parents} \
            {interactive_flag()} \
            {heterozygosity_flag} \
            {keep_ibd_table_flag()} \
            --outdir {params.output_dir}
        """