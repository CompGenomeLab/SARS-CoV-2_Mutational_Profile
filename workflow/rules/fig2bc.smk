
rule fig2bc:
    input:  
        trimer="results/{output_name}/{output_name}_{cdhit}_mut_counts_pos_trimer.tsv",
        ancestral="results/{output_name}/{output_name}_{cdhit}_ancestral_sequences_muts.json",
        ref=expand("resources/reference_genome/{ref}", 
                       ref=config["reference_gff"]),    
        codon="resources/codon_table.txt",
        aa="resources/aminoacid_table.txt",       
    output:
        tsv="results/{output_name}/{output_name}_{cdhit}_fig2bc.tsv",
        all_aa="results/{output_name}/{output_name}_{cdhit}_all_aa.tsv",
        fig2b="results/{output_name}/{output_name}_{cdhit}_fig2b.png",
        fig2c="results/{output_name}/{output_name}_{cdhit}_fig2c.png",
    log:
        "logs/{output_name}/fig2bc_{cdhit}.log",
    benchmark:
        "logs/{output_name}/fig2bc_{cdhit}.benchmark.txt",
    conda:
        "../envs/fig2bc.yaml",
    shell:
        """
        Rscript workflow/scripts/fig2bc_and_aachanges.R \
        -t {input.trimer} \
        -anc {input.ancestral} \
        -ref {input.ref} \
        -c {input.codon} \
        -a {input.aa} \
        -tsv {output.tsv} \
        -aa {output.all_aa} \
        -f2b {output.fig2b} \
        -f2c {output.fig2c} &> {log}
        """
