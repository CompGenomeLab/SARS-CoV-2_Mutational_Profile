# MUTATION PERCENTAGE CALCULATION
# WRITTEN IN ADEBALI LAB - SABANCI UNIVERSITY
# UPDATED FEBRUARY 2021
# adebalilab.org

import argparse

ap = argparse.ArgumentParser()
ap.add_argument("-f", "--file",type = str ,required=True, help="File that includes mutation count for each mutation type")
ap.add_argument("-p", "--percentages",type = str ,required=True, help="Percentages output")

args = vars(ap.parse_args())

tsv_file = open(args["file"],"r")
tsv_lines = tsv_file.readlines()

out_name = args["percentages"]
f = open(out_name,"w")

mut_dict={}
total_num = 0

for i in tsv_lines:
  if i[0:3] in mut_dict:
    mut_dict[i[0:3]] += int((i.split())[1])
    total_num += int((i.split())[1])
  else:
    mut_dict[i[0:3]] = int((i.split())[1])
    total_num += int((i.split())[1])

for key,values in mut_dict.items():
  f.write((key.replace("T","U")+"\t"+"%"+str((values/total_num)*100)+"\n")) # T's are replaced by U since the code is used on RNA sequences

f.close()
