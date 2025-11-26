rule subset_syntenic_regions:
    input:
        vcf=get_pair_input,
        bed=tair10_genic_regions
    output:
        "subset_syntenic_regions/{pair}.vcf.gz"
    resources:
        qos = 'short',
        mem_mb = 1024,
        runtime = 2*60,
    threads: 10
    shell:
        """
        bcftools view \
            --regions-file {input.bed} \
            --min-af 0.1:minor \
            --write-index \
            --threads {threads} \
            -Oz -o {output} \
            {input.vcf}
        """