
rule filter_by_header:
    input:  
        raw=expand("{fasta_folder}/{fasta}", fasta_folder=config["fasta_folder"], 
                    fasta=config["fasta_file"]),
        header="results/{output_name}/headers.txt",            
    output:
        "results/{output_name}/{output_name}.fasta",
    log:
        "logs/{output_name}/filter_by_header.log",
    benchmark:
        "logs/{output_name}/filter_by_header.benchmark.txt",
    shell:
        """
        python3 workflow/scripts/filterFasta.py \
        {input.raw} {input.header} \
        {output} &> {log}
        """


