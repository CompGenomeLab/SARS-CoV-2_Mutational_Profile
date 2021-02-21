
rule signature_calc:
    input:  
        "results/{output_name}/{output_name}_{cdhit}_ancestral_sequences_muts.json",           
    output:
        trimer="results/{output_name}/{output_name}_{cdhit}_mut_counts_pos_trimer.tsv",
        muts="results/{output_name}/{output_name}_{cdhit}_mutation_counts.tsv",
    log:
        "logs/{output_name}/signature_calc_{cdhit}.log",
    benchmark:
        "logs/{output_name}/signature_calc_{cdhit}.benchmark.txt",
    conda:
        "../envs/signature_calc.yaml",
    shell:
        """
        Rscript workflow/scripts/signature_calculator.R \
        -i {input} \
        -o1 {output.trimer} \
        -o2 {output.muts} &> {log}
        """