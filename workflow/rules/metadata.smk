rule rename_metadata:
    input:
        expand("{info_folder}/{info}", 
                info_folder=config["info_folder"], 
                info=config["info_file"]),
    output:
        "results/{output_name}/{output_name}.tsv", 
    shell:
        "cp {input} {output}"


rule metadata:
    input:
        "results/{output_name}/{output_name}.tsv", 
    output:
        "results/{output_name}/{output_name}_keepid.txt",
        "results/{output_name}/{output_name}_metadata.tsv",
        "results/{output_name}/{output_name}_lat_long.tsv",
    params:
        o = "results/{output_name}/",
        t = config["time_window"],
    log:
        "logs/{output_name}/metadata.log",
    benchmark:
        "logs/{output_name}/metadata.benchmark.txt", 
    shell:
        """
        python3 workflow/scripts/tsv2metadata.py \
        -i {input} \
        -o {params.o} \
        -t {params.t} &> {log}
        """