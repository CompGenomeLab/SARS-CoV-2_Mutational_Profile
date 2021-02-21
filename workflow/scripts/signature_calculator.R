library(rjson)
library(stringr)
library(reshape2)
library(argparser)

################################
# Create a parser
p <- arg_parser("This script aims to calculate the ancestral mutations in the tree according to their trinucleotides and position")
p <- add_argument(p, "-i", help="input, the ancestral sequences file")
p <- add_argument(p, "-o1", help="output, mutational counts pos trimer")
p <- add_argument(p, "-o2", help="output, mutation counts")

# Parse the command line arguments
argv <- parse_args(p)
################################

muts <- fromJSON(file=argv$i)

mutslist<-c("A_T","A_G","A_C","A_A","T_T","T_A","T_G","T_C","C_A","C_G","C_T","C_C","G_A","G_C","G_T","G_G")
df<-as.data.frame(matrix(0, nrow=0, ncol=length(mutslist)+2))
colnames(df)<-c("pos","mut",mutslist)

#get the information for each sequence in the tree
allnodes<-muts$nodes

for(i in 1:length(allnodes)){
  mutations<-allnodes[i][[1]]$muts #-----get mutation list of the sequence
  if(length(mutations)>0){#--------------if there is a mutation in the sequence    
    for (n in 1:length(mutations)){
      if(!str_detect(mutations[n],"-") & !str_detect(mutations[n],"N")){
        mut<-mutations[n]
        old<-substr(mut,1,1)
        new<-substr(mut,nchar(mut),nchar(mut))
        position<-as.integer(substr(mut,2,nchar(mut)-1))
        trimer<-substr(allnodes[i][[1]]$sequence,position-1,position+1)
        # if there is a mutation in the previous position initialize this on the trimer
        if(n-1!=0){if(as.integer(substr(mutations[n-1],2,nchar(mutations[n-1])-1))+1==position){
          substr(trimer,1,1)<-substr(mutations[n-1],1,1)
        }}
        # if there is a mutation in the next position initialize this on the trimer
        if(n+1 <=length(mutations)){if(as.integer(substr(mutations[n+1],2,nchar(mutations[n+1])-1))-1==position){
          substr(trimer,3,3)<-substr(mutations[n+1],1,1)
        }}
        forcolcheck<-trimer
        substr(forcolcheck,2,2)<-"_"
        df[nrow(df)+1,]<-0
        df[nrow(df),which(names(df)==forcolcheck)]<-df[nrow(df),which(names(df)==forcolcheck)]+1
        df[nrow(df),1]<-position
        df[nrow(df),2]<-paste(old,new,sep=">")
      }
    }
  }
}

df2 <- aggregate(df[,3:ncol(df)],by=list(df$pos,df$mut),FUN=sum, na.rm=TRUE)
df2<-df2[order(df2$Group.1),]
colnames(df2)<-c("pos","mut",mutslist)
write.table(df2, argv$o1, sep = "\t", quote = FALSE, row.names = FALSE)

df3<-df2[,-c(1) ]
df3 <- aggregate(df3[,2:ncol(df3)],by=list(df3$mut),FUN=sum, na.rm=TRUE)
#will be used for signature calculations
#write.table(df3,"C:/Users/zeyne/Desktop/COVID-MAY/COVID_2021/february/signatures/2021-02-17_0.99_mut_counts_trimer.tsv",sep = "\t", quote = FALSE, row.names = FALSE)
write.table(df3,"", sep = "\t", quote = FALSE, row.names = FALSE)

df4<-melt(data = df3, id.vars = c("Group.1"), measure.vars = c(names(df3)[c(2:ncol(df3))]))
df4$variable<-as.character(df4$variable)
substr(df4$variable,2,2)<-substr(df4$Group.1,1,1)
df4$variable<-paste(df4$Group.1,df4$variable,sep=":")
df4<-df4[,-c(1)]
write.table(df4, argv$o2, sep = "\t", quote = FALSE, row.names = FALSE, col.names = F)
