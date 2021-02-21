# NORMALIZATON ON MUTATION COUNTS WITH TRINUCLEOTIDE COUNTS
# WRITTEN IN ADEBALI LAB - SABANCI UNIVERSITY
# UPDATED FEBRUARY 2021
# adebalilab.org

import argparse

ap = argparse.ArgumentParser()
ap.add_argument("-ref", "--reference",type = str ,required=True, help="fasta file for reference sequence to normalize")
ap.add_argument("-c", "--counts",type = str ,required=True, help="file for mutation counts")
ap.add_argument("-r", "--relative", type = str ,required=True, help="current mutation / all mutations")
ap.add_argument("-t", "--trinucleotide", type = str ,required=True, help="current mutation / trinucleotide count")
ap.add_argument("-o", "--original", type = str ,required=True, help="current mutation")
args = vars(ap.parse_args())

seq_file = open(args["reference"],"r")
seq_lines = seq_file.readlines()

header = ""
forward = ""

for x in seq_lines:
  if x[0] == ">":
    header = x[1:].strip()
  else:
    forward += x.strip()

tri_dict = {}

for i in range(len(forward)-2):
  trinuc = forward[i]+forward[i+1]+forward[i+2]

  if trinuc in tri_dict:
    tri_dict[trinuc] += 1
  else:
    tri_dict[trinuc] = 1

count_file = open(args["counts"],"r")
count_lines = count_file.readlines()
total_count = 0

for x in count_lines:
  x = x.strip()
  x = x.split()
  total_count += int(x[1])

count_file.seek(0)
count_lines = count_file.readlines()

f1 = open(args["relative"],"w") # current mutation / all mutations for plotting
f2 = open(args["trinucleotide"],"w") # current mutation / trinucleotide count for plotting
f3 = open(args["original"],"w") # current mutation for plotting

for x in count_lines:
  x = x.strip()
  x = x.split()
  count = int(x[1])
  sign = (x[0].split(":"))[0]
  tri = (x[0].split(":"))[1]
  count_f1 = (count/total_count)*100
  count_f2 = (count/tri_dict[tri])*100
  sign = sign.replace("T", "U")
  tri = tri.replace("T", "U")
  f1.write(sign+"\t"+tri+"\t"+str(count_f1)+"\n")
  f2.write(sign+"\t"+tri+"\t"+str(count_f2)+"\n")
  f3.write(sign+"\t"+tri+"\t"+str(count)+"\n")

f1.close()
f2.close()
f3.close()
