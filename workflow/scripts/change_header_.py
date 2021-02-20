import os
import sys
import subprocess
import json
import re


key2valueDict = {}
def make_new_header(file,new_file_name):
    filein = open(file, 'r')
    seqDict = {}
    for line in filein:
        if line.startswith('>'):
            header = line.strip()
            seqDict[header] = ""
        else:
            seqDict[header] += line.strip()
    new_dict = {}
    for k,v in seqDict.items():
        k = re.sub(r'[^\w>]', '_',k)

        new_dict[k] = v

    new_file = open (new_file_name,  "w")
    for newheader in  new_dict.keys():
        new_file.write(newheader+'\n' + new_dict[newheader]+'\n')
    
    new_file.close()


if __name__ == "__main__": 
    fasta_file  = sys.argv[1] 
    new_file_name = sys.argv[2]
    make_new_header(fasta_file,new_file_name)



        
    
