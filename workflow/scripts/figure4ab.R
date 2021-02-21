library(forcats)
library(rjson)
library(stringr)
library(reshape2)
library(Bios2cor)
library(ggplot2)
library(patchwork)
library(argparser)

################################
# Create a parser
p <- arg_parser("producing Figure 4a and 4b")
p <- add_argument(p, "-anc", help="input, ancestral sequences")
p <- add_argument(p, "-fa", help="input, reference fasta file")
p <- add_argument(p, "-f", help="output, figure 4")
# Parse the command line arguments
argv <- parse_args(p)
################################

muts <- fromJSON(file=argv$anc)
allnodes<-muts$nodes

dinucs<-c("GC","CG","TC","CT","AT","TA","GA","AG","GT","TG","CA","AC","AA","CC","TT","GG")
didf<-as.data.frame(matrix(0, nrow=0, ncol=5))
colnames(didf)<-c("position","form/deform","dinuc","val","mut")

for(i in 1:length(allnodes)){
  mutations<-allnodes[i][[1]]$muts
  if(length(mutations)>0){
    for (n in 1:length(mutations)){
      if(!str_detect(mutations[n],"-") & !str_detect(mutations[n],"N")){
        mut<-mutations[n]
        old<-substr(mut,1,1)
        new<-substr(mut,nchar(mut),nchar(mut))
        position<-as.integer(substr(mut,2,nchar(mut)-1))
        curtrimer<-substr(allnodes[i][[1]]$sequence,position-1,position+1)
        oldtrimer<-curtrimer
        substr(oldtrimer,2,2)<-old
        if(n-1!=0){ #there is a mutation right before this position
          if(as.integer(substr(mutations[n-1],2,nchar(mutations[n-1])-1))==position-1){
            substr(oldtrimer,1,1)<-substr(mutations[n-1],1,1)}}
        if(n+1<=length(mutations)){#there is a mutation right after this position
          if(as.integer(substr(mutations[n+1],2,nchar(mutations[n+1])-1))==position+1){
            substr(oldtrimer,3,3)<-substr(mutations[n+1],1,1)
          }}
        formdinuc1<-substr(curtrimer,1,2)
        formdinuc2<-substr(curtrimer,2,3)
        
        defdinuc1<-substr(oldtrimer,1,2)
        defdinuc2<-substr(oldtrimer,2,3)
        
        if(formdinuc1 %in% dinucs){
          didf[nrow(didf)+1,1]<-position
          didf[nrow(didf),2]<-"form"
          didf[nrow(didf),3]<-formdinuc1
          didf[nrow(didf),4]<-1
          didf[nrow(didf),5]<-mut
          
        }
        if(formdinuc2 %in% dinucs){
          didf[nrow(didf)+1,1]<-position
          didf[nrow(didf),2]<-"form"
          didf[nrow(didf),3]<-formdinuc2
          didf[nrow(didf),4]<-1
          didf[nrow(didf),5]<-mut
          
        }
        if(defdinuc1 %in% dinucs){
          didf[nrow(didf)+1,1]<-position
          didf[nrow(didf),2]<-"deform"
          didf[nrow(didf),3]<-defdinuc1
          didf[nrow(didf),4]<-(-1)
          didf[nrow(didf),5]<-mut
          
        }
        if(defdinuc2 %in% dinucs){
          didf[nrow(didf)+1,1]<-position
          didf[nrow(didf),2]<-"deform"
          didf[nrow(didf),3]<-defdinuc2
          didf[nrow(didf),4]<-(-1)
          didf[nrow(didf),5]<-mut
        }
        
      }
    } 
  }
}

didfyedek<-didf

didf$mutt<-paste(substr(didf$mut,1,1),substr(didf$mut,nchar(didf$mut),nchar(didf$mut)),sep=">" )

didf2 <- aggregate(didf[,4],by=list(didf$`form/deform`,didf$dinuc,didf$mutt),FUN=sum, na.rm=TRUE)

didf3<-aggregate(didf2[,4],by=list(didf2$Group.1,didf2$Group.2),FUN=sum, na.rm=TRUE)

didf4<-dcast(didf3, Group.2~Group.1, value.var="x")

##get reference genome as dataframe-------
aln2 <- import.fasta(argv$fa)
ref<-as.data.frame(matrix(0, nrow=length(aln2), ncol=2))
names(ref)<-c("header","seqs")
for(node in 1:length(aln2)){
  ref$header[node]<-names(aln2)[node]
  a<-gsub("*,","",toString(aln2[[node]]))
  ref$seqs[node]<-gsub("* ","",a)
}
#-----------------------------------------

for ( i in 1:nrow(didf4)){
  didf4$ref_count[i]<- str_count(ref$seqs[1], didf4$Group.2[i])
  
}

didf4$defoverefcount<- didf4$deform/ didf4$ref_count
didf4$defoverefcount<- (-1)* didf4$defoverefcount

didf4$Group.2<- gsub('T', 'U', didf4$Group.2)
de <- ggplot(didf4, aes(x= fct_reorder(Group.2, -defoverefcount)  , y = defoverefcount)) + 
  geom_bar(stat = "identity", fill="tan2") + xlab("Dinucleotides")+ylab("Normalized deformed counts")+theme_classic()


fo<-ggplot(didf4, aes(x= fct_reorder(Group.2, -form)   , y = form)) + 
  geom_bar(stat = "identity", fill="steelblue") + xlab("Dinucleotides")+ylab("Form count")+
  theme_classic()


fig4<-de/fo+plot_annotation(tag_levels = 'A')

ggsave(filename = argv$f, fig4,
       width = 4.2, height = 4.2,dpi = 100, units = "in", device='png')


