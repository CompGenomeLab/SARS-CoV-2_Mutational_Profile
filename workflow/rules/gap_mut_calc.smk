
rule gap_mut_calc:
    input:  
        expand("{fasta_folder}/{msa}", 
                fasta_folder=config["fasta_folder"],
                msa=config["msa"]),
    output:
        gaps="{fasta_folder}/gaps.csv",
        muts="{fasta_folder}/mutations.csv",
    log:
        "{fasta_folder}/gap_mut_calc.log",
    benchmark:
        "{fasta_folder}/gap_mut_calc.benchmark.txt",
    shell:
        """
        python3 workflow/scripts/gap_mut_calculator.py \
        {input} \
        {output.gaps} {output.muts} &> {log}
        """