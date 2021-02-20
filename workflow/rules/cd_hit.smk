rule cd_hit:
    input:
        "results/{output_name}/{output_name}_filtered.fa", 
    output:
        fa = "results/{output_name}/{output_name}_{cdhit}_cd_hit.fasta",
        clstr = "results/{output_name}/{output_name}_{cdhit}_cd_hit.fasta.clstr",
    params:
        m = 0,
        t = 80,
    log:
        "logs/{output_name}/cd_hit_{cdhit}.log",
    benchmark:
        "logs/{output_name}/cd_hit_{cdhit}.benchmark.txt", 
    conda:
        "../envs/cd_hit.yaml",
    shell:
        """
        cd-hit-est -i {input} \
        -c {wildcards.cdhit} \
        -M {params.m} \
        -T {params.t} \
        -o {output.fa} &> {log}
        """