# Numeric arguments passed to ibdpainting.
window_size=config.get('window_size', 500000)
max_to_plot=config.get('max_to_plot', 20)
height=config.get('height', 675)
width=config.get('width', 900)

# Boolean flags passed to ibdpainting 
def interactive_flag():
    return "--interactive" if config.get("interactive", True) else "--no-interactive"
def heterozygosity_flag():
    return "--plot_heterozygosity" if config.get("plot_heterozygosity", True) else "--no-plot_heterozygosity"
def keep_ibd_table_flag():
    return "--keep_ibd_table" if config.get("keep_ibd_table", False) else "--no-keep_ibd_table"


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
        output_dir="ibdpainting",
        height={height},
        width={width},
        interactive_flag     = lambda wildcards: interactive_flag(),
        heterozygosity_flag  = lambda wildcards: heterozygosity_flag(),
        keep_ibd_table_flag  = lambda wildcards: keep_ibd_table_flag()
    log:
        out = "logs/ibdpainting/{sample}.out",
        err = "logs/ibdpainting/{sample}.err"
    resources:
        qos = 'rapid',
        mem_mb = 1*1024,
        runtime = 60
    shell:
        """
        ibdpainting \
            --input {input.test} \
            --reference {input.ref} \
            --window_size {window_size} \
            --max_to_plot {max_to_plot} \
            --height {params.height} \
            --width {params.width} \
            --sample {params.sample_name} \
            --expected_match {params.expected_parents} \
            {params.interactive_flag} \
            {params.heterozygosity_flag} \
            {params.keep_ibd_table_flag} \
            --outdir {params.output_dir} \
            > {log.out} 2> {log.err}
        """