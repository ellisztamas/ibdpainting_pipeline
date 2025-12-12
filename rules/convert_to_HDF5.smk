rule convert_to_HDF5:
    input:
        "subset_syntenic_regions/{pair}.vcf.gz"
    output:
        "hdf5/{pair}.hdf5"
    resources:
        qos = 'rapid',
        mem_mb = lambda wildcards, attempt: 10*1024 * attempt,
        runtime = 60
    log:
        out = "logs/convert_to_HDF5/{pair}.out",
        err = "logs/convert_to_HDF5/{pair}.err"
    shell:
        """
        python {workflow.basedir}/scripts/vcf_to_hdf5.py \
            --input {input} \
            --output {output} \
            > {log.out} 2> {log.err}
        """
        
