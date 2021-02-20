rule seq_filter:
    input:
        fa = "results/{output_name}/{output_name}_org.fasta",
        k = "results/{output_name}/{output_name}_keepid.txt",
    output:
        "results/{output_name}/{output_name}_filtered.fa",
    shell:
        """
        workflow/scripts/filter.sh {input.fa} {input.k} {output}
        """