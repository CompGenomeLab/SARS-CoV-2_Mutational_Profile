
rule percentage_calc:
    input:  
        "results/{output_name}/{output_name}_{cdhit}_mutation_counts.tsv",            
    output:
        "results/{output_name}/{output_name}_{cdhit}_percentages.txt",
    log:
        "logs/{output_name}/percentage_calc_{cdhit}.log",
    benchmark:
        "logs/{output_name}/percentage_calc_{cdhit}.benchmark.txt",
    shell:
        """
        python3 workflow/scripts/percentage_calculator.py \
        -f {input} \
        -p {output} &> {log}
        """