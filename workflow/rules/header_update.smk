
rule header_update:
    input:  
        "results/{output_name}/{output_name}_sub.fasta",
    output:
        "results/{output_name}/{output_name}_org.fasta",
    log:
        "logs/{output_name}/header_update.log",
    benchmark:
        "logs/{output_name}/header_update.benchmark.txt",
    shell:
        "python3 workflow/scripts/change_header_.py {input} {output} &> {log}"



