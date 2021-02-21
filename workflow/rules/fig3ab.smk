
rule fig3ab:
    input:  
        ancestral="results/{output_name}/{output_name}_{cdhit}_ancestral_sequences_muts.json",
        gff=expand("resources/reference_genome/{gff}", 
                       gff=config["reference_gff"]),  
        fa=expand("resources/reference_genome/{fa}", 
                       fa=config["reference_fa"]),   
        codon="resources/codon_table.txt",
        aa="resources/aminoacid_table.txt",     
        usage="resources/h_sapiens_codon_usage.txt",  
    output:
        rel="results/{output_name}/{output_name}_{cdhit}_human_sars_relative_codon.tsv",
        codonfd="results/{output_name}/{output_name}_{cdhit}_codon_formdef_tree.tsv",
        fig3="results/{output_name}/{output_name}_{cdhit}_fig3.png",
    log:
        "logs/{output_name}/fig3ab_{cdhit}.log",
    benchmark:
        "logs/{output_name}/fig3ab_{cdhit}.benchmark.txt",
    conda:
        "../envs/fig3_4.yaml",
    shell:
        """
        Rscript workflow/scripts/figure3ab.R \
        -fa {input.fa} \
        -anc {input.ancestral} \
        -gff {input.gff} \
        -c {input.codon} \
        -a {input.aa} \
        -u {input.usage} \
        -rel {output.rel} \
        -fd {output.codonfd} \
        -f3 {output.fig3} &> {log}
        """
