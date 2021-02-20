rule ancestral_tree:
    input:
        tree = "results/{output_name}/{output_name}_{cdhit}_aligned_tree.nwk",
        align = "results/{output_name}/{output_name}_{cdhit}_aligned.fa",
    output:
        "results/{output_name}/{output_name}_{cdhit}_ancestral_sequences_muts.json",
    log:
        "logs/{output_name}/ancestral_tree_{cdhit}.log",
    benchmark:
        "logs/{output_name}/ancestral_tree_{cdhit}.benchmark.txt", 
    shell:
        """
        augur ancestral \
        --tree {input.tree} \
        --alignment {input.align} \
        --output-node-data {output} \
        --inference joint &> {log}
        """