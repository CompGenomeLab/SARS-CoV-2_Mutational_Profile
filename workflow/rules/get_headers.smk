
rule get_headers:
    input:  
        expand("{fasta_folder}/mutations.csv", 
                fasta_folder=config["fasta_folder"]),            
    output:
        "results/{output_name}/{output_name}_headers.txt",
    log:
        "logs/{output_name}/get_headers.log",
    benchmark:
        "logs/{output_name}/get_headers.benchmark.txt",
    conda:
        "../envs/get_headers.yaml",
    shell:
        """
        Rscript workflow/scripts/covid_sequence_filter.R \
        -i {input} \
        -o {output} &> {log}
        """