
rule fig2a:
    input:  
        "results/{output_name}/{output_name}_{cdhit}_trinuc_freq.tsv",            
    output:
        "results/{output_name}/{output_name}_{cdhit}_fig2a_mut_profiles.png",
    log:
        "logs/{output_name}/fig2a_{cdhit}.log",
    benchmark:
        "logs/{output_name}/fig2a_{cdhit}.benchmark.txt",
    conda:
        "../envs/fig2a.yaml",
    shell:
        """
        Rscript workflow/scripts/mutation_profile_plotter.R \
        -i {input} \
        -o {output} &> {log}
        """