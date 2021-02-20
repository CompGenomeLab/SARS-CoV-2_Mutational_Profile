
rule subsample_fasta:
    input:  
        "results/{output_name}/{output_name}.fasta",          
    output:
        "results/{output_name}/{output_name}_sub.fasta",
    params:
        config["subset"],
    log:
        "logs/{output_name}/filter_fasta.log",
    benchmark:
        "logs/{output_name}/filter_fasta.benchmark.txt",
    shell:
        """
        workflow/scripts/subsample_fasta.sh {input} {output} {params} &> {log}
        """