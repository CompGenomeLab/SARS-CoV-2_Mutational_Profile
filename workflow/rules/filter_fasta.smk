
rule filter_fasta:
    input:  
        raw=expand("{fasta_folder}/{fasta}", fasta_folder=config["fasta_folder"], 
                    fasta=config["fasta_file"]),
        header="results/{output_name}/covid_filtered_headers.txt",            
    output:
        "results/{output_name}/{output_name}.fasta",
    log:
        "logs/{output_name}/filter_fasta.log",
    benchmark:
        "logs/{output_name}/filter_fasta.benchmark.txt",
    shell:
        """
        python3 workflow/scripts/filterFasta.py \
        {input.raw} {input.header} \
        {output} &> {log}
        """


