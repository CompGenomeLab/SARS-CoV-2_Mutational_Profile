
def getRoot(wildcards, root_file):
    try:
        with open(root_file, "r") as rootfile:
            return rootfile.readline()
    except:
        print("Warning: Root file couldn't open.. Ignore if it is a dry run.")

rule refine:
    input:
        tree = "results/{output_name}/{output_name}_{cdhit}_aligned.fa.treefile",
        align = "results/{output_name}/{output_name}_{cdhit}_aligned.fa",
        metadata = "results/{output_name}/{output_name}_metadata.tsv",
        rootfile = "results/{output_name}/{output_name}_{cdhit}_root.txt", 
    output:
        "results/{output_name}/{output_name}_{cdhit}_aligned_tree.nwk",
    params:
        lambda wildcards, input: getRoot(wildcards, input[3]), 
    log:
        "logs/{output_name}/refine_{cdhit}.log",
    benchmark:
        "logs/{output_name}/refine_{cdhit}.benchmark.txt", 
    shell:
        """
        augur refine \
        --tree {input.tree} \
        --alignment {input.align} \
        --metadata {input.metadata} \
        --output-tree {output} \
        --root {params} \
        --timetree \
        --clock-rate 0.0008 \
        --clock-std-dev 0.0004 \
        --coalescent const \
        --date-inference marginal \
        --date-confidence \
        --no-covariance \
        --clock-filter-iqd 4 &> {log}
        """