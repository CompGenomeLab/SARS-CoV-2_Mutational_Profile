rule tree:
    input:
        "results/{output_name}/{output_name}_{cdhit}_aligned.fa", 
    output:
        "results/{output_name}/{output_name}_{cdhit}_aligned.fa.treefile", 
    params:
        nt = "AUTO",
        m = "GTR",
        r = "-redo" if config["redo"] else [],
    log:
        "logs/{output_name}/tree_{cdhit}.log",
    benchmark:
        "logs/{output_name}/tree_{cdhit}.benchmark.txt", 
    conda:
        "../envs/tree.yaml"
    shell:
        """
        iqtree \
        -fast \
        -s {input} \
        -nt {params.nt} \
        -m {params.m} \
        {params.r} &> {log}
        """