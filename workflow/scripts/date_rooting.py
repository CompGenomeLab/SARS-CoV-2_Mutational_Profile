import sys 

metadata=open(sys.argv[1],"r")
itermeta = iter(metadata)
next(itermeta)

date_dict={}

for line in itermeta:

    line_list=line.split("\t")

    date=line_list[3]
    sample=line_list[0]
    date_dict[sample]=int(date.replace("-",""))

fasta=open(sys.argv[2],"r")

count=0
minimum=30000000

for line in fasta:

    count+=1
    if line[0]==">":

        header=line[1:].strip()
        if header in date_dict.keys():

            if count==1:

                minimum=date_dict[header]
                decision_header=header

            else:

                if date_dict[header]<minimum:

                    minimum=date_dict[header]
                    decision_header=header

root = open(sys.argv[3],"w") 
root.write(decision_header)
root.close() 