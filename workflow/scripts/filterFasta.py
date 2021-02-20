import sys 

with open(sys.argv[2], 'r') as selectedfasta:
    sList = []
    for sname in selectedfasta:
        sname = sname.strip().split("|")[0][8:]
        sList.append(sname)
        #print(sname)

with open(sys.argv[3],"w") as ffasta:

    rfasta = open(sys.argv[1], 'r').readlines()
    mycount = 0
    for idx in range(0,len(rfasta),2):
        header = rfasta[idx][1:].strip()

        if header in sList:
            mycount +=1
            print(mycount, "HEADER:", header)
            ffasta.write(">" + header + "\n") 
            ffasta.write(rfasta[idx+1])
            

