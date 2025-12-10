rule subset_syntenic_regions:
    input:
        vcf=get_pair_input,
        bed=tair10_genic_regions
    output:
        "subset_syntenic_regions/{pair}.vcf.gz"
    resources:
        qos = 'short',
        mem_mb = lambda wildcards, attempt: attempt * 2*1024,
        runtime = lambda wildcards, attempt: attempt * 2*60,
    log:
        out = "logs/subset_syntenic_regions/{pair}.out",
        err = "logs/subset_syntenic_regions/{pair}.err"
    threads: 10
    shell:
        """
        bcftools view \
            --regions-file {input.bed} \
            --min-af 0.1:minor \
            --types snps \
            --write-index \
            --threads {threads} \
            -Oz -o {output} \
            {input.vcf} \
            > {log.out} 2> {log.err}
        """