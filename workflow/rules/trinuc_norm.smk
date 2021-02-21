
rule trinuc_norm:
    input:  
        muts="results/{output_name}/{output_name}_{cdhit}_mutation_counts.tsv", 
        refseq=expand("resources/reference_genome/{refseq}", 
                       refseq=config["reference_fa"]),           
    output:
        rel="results/{output_name}/{output_name}_{cdhit}_relative_cont.tsv",
        tri="results/{output_name}/{output_name}_{cdhit}_trinuc_freq.tsv",
        ori="results/{output_name}/{output_name}_{cdhit}_original.tsv",
    log:
        "logs/{output_name}/trinuc_norm_{cdhit}.log",
    benchmark:
        "logs/{output_name}/trinuc_norm_{cdhit}.benchmark.txt",
    shell:
        """
        python3 workflow/scripts/mutation_trinucleotide_normalizator.py \
        -ref {input.refseq} \
        -c {input.muts} \
        -r {output.rel} \
        -t {output.tri} \
        -o {output.ori} &> {log}
        """