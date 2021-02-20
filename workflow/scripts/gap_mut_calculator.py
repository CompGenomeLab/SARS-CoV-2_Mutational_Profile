import csv, sys

g = csv.writer(open(sys.argv[2], "w")) 

refDict={}
def fastareader(filename):
    header=0
    seqDict = {}
    filein = open(filename, 'r')
    for line in filein:
        if line.startswith('>'):
            #before header changes
            header = line[1:].strip()
            if "EPI_ISL_402124" in header:
                refDict[header] = ""
                print("reffound")
            else:
                seqDict[header] = ""
        else:
            if "EPI_ISL_402124" in header:
                refDict[header] += line.strip()
            else:
                seqDict[header] += line.strip() 
    return seqDict


geneFile = sys.argv[1] #'msa_0210.fasta'


geneDict = fastareader(geneFile)
qualDict = {}
res = list(refDict.keys())[0] 
refseq=refDict[res]
print("ref uploaded")
print("mutation count starting")
w = csv.writer(open(sys.argv[3], "w")) 
for header in geneDict.keys():
    muts=0
    dele=0
    inser=0
    for i in range(len(geneDict[header])):
        geneSequence=geneDict[header]
        if geneSequence[i] != refseq[i] and geneSequence[i]!="N" and geneSequence[i]!="-" and refseq[i]!="-":
            muts+=1
        if refseq[i]=="-" and geneSequence[i] != "-" and geneSequence[i]!="N":
            inser+=1
        if refseq[i]!="-" and geneSequence[i] == "-" and refseq[i]!="N":
            dele+=1
    w.writerow([header, muts,dele,inser])
print("writing results")