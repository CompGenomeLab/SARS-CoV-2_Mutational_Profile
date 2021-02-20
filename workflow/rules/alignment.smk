rule alignment:
    input:
        seq = "results/{output_name}/{output_name}_{cdhit}_cd_hit.fasta",
        refseq = expand("resources/reference_genome/{refseq}", 
                        refseq=config["reference_fa"]),
    output:
        "results/{output_name}/{output_name}_{cdhit}_aligned.fa",
    log:
        "logs/{output_name}/alignment_{cdhit}.log",
    benchmark:
        "logs/{output_name}/alignment_{cdhit}.benchmark.txt", 
    shell:
        """
        augur align \
        --sequences {input.seq} \
        --reference-sequence {input.refseq} \
        --output {output} &> {log}
        """