
rule fig4ab:
    input:  
        ancestral="results/{output_name}/{output_name}_{cdhit}_ancestral_sequences_muts.json", 
        fa=expand("resources/reference_genome/{fa}", 
                       fa=config["reference_fa"]),   
    output:
        "results/{output_name}/{output_name}_{cdhit}_fig4.png",
    log:
        "logs/{output_name}/fig4ab_{cdhit}.log",
    benchmark:
        "logs/{output_name}/fig4ab_{cdhit}.benchmark.txt",
    conda:
        "../envs/fig3_4.yaml",
    shell:
        """
        Rscript workflow/scripts/figure4ab.R \
        -fa {input.fa} \
        -anc {input.ancestral} \
        -f {output} &> {log}
        """
