# SARS-CoV-2 Mutation Profile

This repository contains the codes used for processing the data and producing the figures in the paper: [The mutation profile of SARS-CoV-2 is primarily shaped by the host antiviral defense](https://www.biorxiv.org/content/10.1101/2021.02.02.429486v1)

## Installation

- To run this workflow, you should have [conda](https://docs.conda.io/en/latest/) installed for environment management. All the other packages and their dependencies can be obtained automatically through environments prepared for each step of the workflow. You can follow the installation steps from [the link](https://docs.conda.io/projects/conda/en/latest/user-guide/install/download.html).

- Initially, you should clone the repository: 

        `git clone https://github.com/CompGenomeLab/SARS-CoV-2_Mutational_Profile.git`

- Next, you should create a conda environment with the defined packages. We propose 2 way to create the environment:

    - One is installing [mamba](https://mamba.readthedocs.io/en/latest/) and creating the environment using mamba:

        ```
        conda install -c conda-forge mamba

        mamba create -c bioconda -c conda-forge -c r -n covid19 snakemake python=3.8

        conda activate covid19

        mamba install -c conda-forge -c bioconda augur=9.0.0
        ```

    - Or the environment can be directly created from our environment file:

        ```
        conda env create -f env.yaml

        conda activate covid19
        ```

| Note: The steps described here apply to the Linux operating system. There may be slight differences in codes between operating systems. |
| --- |
