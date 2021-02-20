rule define_root:
    input:
        "results/{output_name}/{output_name}_metadata.tsv",
        "results/{output_name}/{output_name}_{cdhit}_aligned.fa",
    output:
        "results/{output_name}/{output_name}_{cdhit}_root.txt",
    log:
        "logs/{output_name}/define_root_{cdhit}.log",
    benchmark:
        "logs/{output_name}/define_root_{cdhit}.benchmark.txt", 
    shell:
        "python3 workflow/scripts/date_rooting.py {input} {output} &> {log}"