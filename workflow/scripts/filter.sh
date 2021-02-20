#!/bin/bash

awk '{ if ((NR>1)&&($0~/^>/)) { printf("\n%s", $0); } else if (NR==1) { printf("%s", $0); } else { printf("\t%s", $0); } }' $1 | grep -Ff $2 - | tr "\\t" "\\n" > $3
