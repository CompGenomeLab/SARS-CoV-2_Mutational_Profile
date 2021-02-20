import pip
def import_or_install(package):
    try:
        __import__(package)
    except ImportError:
        pip.main(["install", package])

import_or_install("argparse")
import_or_install("pandas")
import_or_install("xlrd")
import_or_install("opencage")
#import_or_install("colour")

import os,sys
import argparse, textwrap
import pandas as pd
import numpy as np
from datetime import datetime
from opencage.geocoder import OpenCageGeocode
import logging
from datetime import datetime

#LOG_FILENAME=datetime.now().strftime("tsv2metadata_%H:%M:%S_%d-%m-%Y.log")
#logging.basicConfig(filename=LOG_FILENAME, level=logging.INFO)
logging.basicConfig(stream=sys.stdout, level=logging.INFO)

#connecting API
key="e35844700a9e452ca8d0503a178a44b3"
geocoder=OpenCageGeocode(key)


#details about program

#parsing arguments

parser=argparse.ArgumentParser(prog="tsv2metadata.py",
	usage="python3 %(prog)s [options] <path_of_file>",
	description=textwrap.dedent("""\
		authors:	ADEBALI LAB - https://github.com/CompGenomeLab
		contact:	https://adebalilab.org/contact/"""),
	add_help=True,
	formatter_class=argparse.RawTextHelpFormatter, 
	epilog=textwrap.dedent("""\

#To use this program, you should install pip on your system. To install
pip3 on Ubuntu or Debian Linux, open a new Terminal window and enter:

# sudo apt-get install python3-pip

===========================================================================================================================================

This program helps you to convert your files from excel format to tsv (for using as augur metadata) format. The program can connect
geocoder API server and can retrieve coordinates of the locations that it has parsed. Created coordinates will be used by auspice to
visualize your analysis. tsv2metadata ignores data with wrong date format and can filter data with given range of datetimes. 

#	REQUIRED
	========

> with "-i" flag	(--input)	, you should specify your input file. It should be in EXCEL file format.
> with "-o" flag 	(--outdir)	, you should specify your output directory.

#	OPTIONAL
	========

> with "-t" flag	(--time)	, you can select the range of datetime. It should be like "2019-01-01:2020-01-01" .
> with "-rm" flag 	(--rmid)	, you can refer your .txt file that contains headers ("strain") you want to remove manually. 


Expected metadata output will be like below:

+--------+-----------+-------+--------+---------+----------+-------+---------------+---------+-----------+-----------+-----------+---------+
| strain | accession |  date | region | country | division |  city |  comparative  |    db   |  segment  | originlab | submitlab | authors |
+--------+-----------+-------+--------+---------+----------+-------+---------------+---------+-----------+-----------+-----------+---------+
|  value |   value   | value | value  |  value  |  value   | value |     value     |  value  |   value   |   value   |   value   |  value  | 
|  value |   value   | value | value  |  value  |  value   | value |     value     |  value  |   value   |   value   |   value   |  value  |
|  value |   value   | value | value  |  value  |  value   | value |     value     |  value  |   value   |   value   |   value   |  value  |
|  value |   value   | value | value  |  value  |  value   | value |     value     |  value  |   value   |   value   |   value   |  value  |
+--------+-----------+-------+--------+---------+----------+-------+---------------+---------+-----------+-----------+-----------+---------+


On the other hand tsv2metadata will give extra outputs; latlong file, colors file and keepid file. First two files can be used for creating
.json file before the visualization in augur.


Expected metadata_latlong output will be like below:

+-------------+---------------+--------------------+---------------------+
|   region    | north america |	     51.0000002    |    -109.0000002     |
|   region    |    oceania    |	      -18.3128     |      138.5156       |
|   region    |     europe    |	         51.0      |	    10.0         |
|   region    |      asia     |	     51.2086975    |      89.2343748     |
|   region    |     africa    |	     11.5024338    |      17.7578122     |
|   country   |    argentina  |	     -38.416097    | -63.616671999999994 | 
|   country   |     austria   |	     47.516231     |      14.550072      |
|   country   |    australia  |	     -25.274398    |      133.775136     |
|   country   |    belgium    |	     50.503887     |      4.469936       |
|   country   |     brazil    |	     -14.235004    |     -51.92528       |
|   division  |   washington  |	     38.8949855    |     -77.0365708     |
|   division  |    new york   |      40.7127281    |     -74.0060152     |
|   division  | new hampshire |	     43.4849133    |     -71.6553992     |
|   division  |  rhode island |	     41.7962409    |     -71.5992372     |
|   division  |     england   |	     52.7954791    |     -0.5402403      |
|    city     |     kayseri   |      38.7225274    |      35.4874516     |
|    city     |     istanbul  |      41.0096334    |      28.9651646     |
|    city     |     kocaeli   |      40.8216536    |      29.9507184     |
|    city     |     ankara    |      39.9207774    |      32.854067      |
|    city     |      siirt    |      37.8646916    |      42.0510294     |
| comparative |     vietnam   |	14.058323999999999 |      108.277199     |
| comparative |  south africa |	    -30.559482     |      22.937506      | 
| comparative |     kayseri   |	     38.7225274    |      35.4874516     |
| comparative |     istanbul  |	     41.0096334    |      28.9651646     |
| comparative |     kocaeli   |	     40.8216536    |      29.9507184     |
+-------------+---------------+--------------------+---------------------+


#	IMPORTANT
	=========

keepid.txt file can be used for retrieving sequences -that already will be in metadata file from alignment file (MAFFT output).

You can use this command in bash, to retrive sequences from alignment.fasta file :
#	awk '{ if ((NR>1)&&($0~/^>/)) { printf("\n%s", $0); } else if (NR==1) { printf("%s", $0); } else { printf("\t%s", $0); } }' alignment.fasta | grep -Ff keepid.txt - | tr "\t" "\n" > alignment_filtered.fasta


===========================================================================================================================================
"""))

#awk '{ if ((NR>1)&&($0~/^>/)) { printf("\n%s", $0); } else if (NR==1) { printf("%s", $0); } else { printf("\t%s", $0); } }' alignment.fasta | grep -Ff keepid.txt - | tr "\t" "\n" > alignment_filtered.fasta

parser.add_argument("-i","--input", metavar="<.TSV FILE>", required=True, help="Write the path of your input -tsv- file (i.e. /home/Desktop/input.tsv)")
parser.add_argument("-o","--outdir", metavar="<OUTDIR>", required=True, help="Write only the path where you want to put outs (i.e. /home/Desktop/)")

parser.add_argument("-t","--time", metavar="<DATETIME>", required=False, help="Write the time range that you want to filter (i.e. 2019-01-01:2020-01-01)")
parser.add_argument("-rm","--rmid", metavar="<RMID>", required=False, help="Refer the .txt file that contains headers you want to remove manually (i.e. /home/Desktop/removeheaders.txt)")

args=parser.parse_args()


#getting directory
directory = args.outdir

#getting input path
inp_file=args.input
inpname=inp_file.split("/")[-1].split(".")[0]

#read file
x=pd.read_csv(inp_file,sep="\t")
logging.info("Metadata file ("+ inpname +") is reading...")

#merge column values to create strain column
a=x.astype(str)

a.rename({"gisaid_epi_isl":"accession", "virus":"virus" , "date":"date" , "originating_lab":"originlab" , "submitting_lab":"submitlab" , "authors":"authors"}, axis=1, inplace=True)

#replace "[^\w>]" with "_" in strain column
a["strain"] = a["strain"].str.replace("[^\w>]", "_", regex = True)

#rmid list filtering
if args.rmid:
	rmid=args.rmid
	rmidname=rmid.split("/")[-1].split(".")[0]
	rmidlist=[]
	with open(rmid) as burak:
		for line in burak:
			line=line.strip()
			rmidlist.append(line)

	a=a[~a["strain"].isin(rmidlist)]

	logging.info("Sequences (retrieved from "+rmidname+" file) have been removed...")

a["city"]=a[(a["country"].str.contains("Turkey")==True)]["division"]
a["division"]=a[(a["country"].str.contains("USA")==True) | (a["country"].str.contains("United Kingdom")==True)]["division"]
a['city'] = a.city.str.replace("Turkey", "?")

a["comparative"]=a[(a["country"].str.contains("Turkey")==False)]["country"]
a["comparative"]=a["comparative"].fillna(a.city)

a["division"] = a.division.str.replace("Grand Princess 2nd Cruise", "California")
a["division"] = a.division.str.replace("Grand Princess", "California")

#changing strings to lowercase
a["region"]= a["region"].str.lower()
a["country"]= a["country"].str.lower()
a["division"]= a["division"].str.lower()
a["city"]= a["city"].str.lower()
a["comparative"]=a["comparative"].str.lower()


#ignoring missing datetimes
a=a[(a["date"].str.count("-")==2)]
a=a[~a.date.str.contains("X")]
logging.info("Datetimes in wrong format have been deleted..")

#filtering datetime with given conditions
if args.time:
	#setting start & end datetimes from input
	time=args.time
	start1=time.split(":")[0]
	end1=time.split(":")[1]

	#changing dtype of date column to datetime[int64]
	a["date"]=pd.to_datetime(a.date)

	#filtering dataframe datetimes
	start2= pd.to_datetime (start1)
	end2= pd.to_datetime (end1)

	a=a.loc[(a.date >= start2) & (a.date <= end2), :]

	logging.info("Data has been filtered by selected range (from "+start1+" to "+end1+ ") of datetimes.")

#create new columns
a["segment"]="genome"
a["db"]="gisaid"


#rearrange columns by specifying their order
a=a[["strain","virus","accession","date","region","country","division","city","comparative","db","segment","originlab","submitlab","authors"]]

#strip all strings in different columns
a["region"]=a["region"].str.strip()
a["country"]=a["country"].str.strip()
a["division"]=a["division"].str.strip()
a["city"]=a["city"].str.strip()
a["comparative"]=a["comparative"].str.strip()

#delete blank rows
a=a.dropna(axis=0,how="all")
a=a.fillna("?")

#a.to_csv("xyz.tsv",sep="\t",index=None)

#retrieving coordinates and creating lat_long file
logging.info("Connecting server to retrieve coordinates of locations...")


region=a["region"].tolist()
regions=[x for x in region if str(x)!="?"]
regionlist=[]
for i in regions:
	if i not in regionlist:
		regionlist.append(i)
regionlats=[]
regionlngs=[]
for i in regionlist:
	query=i
	result=geocoder.geocode(query)
	lat=result[0]["geometry"]["lat"]
	lng=result[0]["geometry"]["lng"]
	regionlats.append(lat)
	regionlngs.append(lng)
regiondata={"info":"region","loc":regionlist,"lat":regionlats,"lng":regionlngs}
df1=pd.DataFrame(regiondata)

		
countrie=a["country"].tolist()
countries=[x for x in countrie if str(x)!="?"]
countrylist=[]
for i in countries:
	if i not in countrylist:
		countrylist.append(i)
countrylats=[]
countrylngs=[]
for i in countrylist:
	query=i
	result=geocoder.geocode(query)
	lat=result[0]["geometry"]["lat"]
	lng=result[0]["geometry"]["lng"]
	countrylats.append(lat)
	countrylngs.append(lng)
countrydata={"info":"country","loc":countrylist,"lat":countrylats,"lng":countrylngs}
df2=pd.DataFrame(countrydata)


division=a["division"].tolist()
divisions=[x for x in division if str(x)!="?"]
divisionlist=[]
for i in divisions:
	if i not in divisionlist:
		divisionlist.append(i)
divisionlats=[]
divisionlngs=[]
for i in divisionlist:
	query=i
	result=geocoder.geocode(query)
	lat=result[0]["geometry"]["lat"]
	lng=result[0]["geometry"]["lng"]
	divisionlats.append(lat)
	divisionlngs.append(lng)
divisiondata={"info":"division","loc":divisionlist,"lat":divisionlats,"lng":divisionlngs}
df3=pd.DataFrame(divisiondata)

citie=a["city"].tolist()
cities=[x for x in citie if str(x)!="?"]
citylist=[]
for i in cities:
	if i not in citylist:
		citylist.append(i)
citylats=[]
citylngs=[]
for i in citylist:
	query=i
	result=geocoder.geocode(query)
	lat=result[0]["geometry"]["lat"]
	lng=result[0]["geometry"]["lng"]
	citylats.append(lat)
	citylngs.append(lng)
citydata={"info":"city","loc":citylist,"lat":citylats,"lng":citylngs}

df4=pd.DataFrame(citydata)

comparativedata1={"info":"comparative","loc":countrylist,"lat":countrylats,"lng":countrylngs}
df5=pd.DataFrame(comparativedata1)
comparativedata2={"info":"comparative","loc":citylist,"lat":citylats,"lng":citylngs}
df6=pd.DataFrame(comparativedata2)

#merge them outer
c=df1.merge(df2,how="outer").merge(df3,how="outer").merge(df4,how="outer").merge(df5,how="outer").merge(df6,how="outer")

#create outputs

outfile1=directory+"/"+inpname+"_lat_long.tsv"
c.to_csv(outfile1, sep="\t", index=None, header=False)
logging.info("Coordinates of countries retrieved and have written into "+inpname+"_lat_long.tsv (for "+inpname+")..")

outfile2=directory+"/"+inpname+"_metadata.tsv"
a=a.drop_duplicates(subset="strain", keep="first")
a.to_csv(outfile2, sep="\t", index=None, header=True)
logging.info("Parsed metadata has written into "+inpname+"_metadata.tsv (for "+inpname+")..")

#create file from strains to retrieve them from alignment result in future

outfile3=directory+"/"+inpname+"_keepid.txt"
keep = a[['strain']].copy()
keep.to_csv(outfile3, index=None, header=False)
logging.info("Filtered strains have written into "+inpname+"_keepid.txt (for "+inpname+")..")
logging.info("DONE!")