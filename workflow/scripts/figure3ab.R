library(stringr)
library(stringi)
library(reshape2)
library(forcats)
library(patchwork)
library(argparser)
library(rjson)
library(Bios2cor)
library(ggplot2)

################################
# Create a parser
p <- arg_parser("producing Figure 3a and 3b")
p <- add_argument(p, "-u", help="input, homosapiens codon usage file")
p <- add_argument(p, "-anc", help="input, ancestral sequences")
p <- add_argument(p, "-gff", help="input, reference gff file")
p <- add_argument(p, "-fa", help="input, reference fasta file")
p <- add_argument(p, "-c", help="input, codon table")
p <- add_argument(p, "-a", help="input, aminoacid table")
p <- add_argument(p, "-rel", help="output, human sars relative codons")
p <- add_argument(p, "-fd", help="output, form deformed codons")
p <- add_argument(p, "-f3", help="output, figure 3")
# Parse the command line arguments
argv <- parse_args(p)
################################

###for just calculating reference genome
gff<-as.data.frame(read.table(argv$gff, fill = TRUE ))
gff<-gff[grepl("CDS",gff$V3 ),]
gff<-gff[-c(3),] #orf1a removed since orf1ab is the main focus and it comprehends orf1a
orflist<-c("ORF1a" , "ORF1b","ORF2","ORF3","ORF4","ORF5","ORF6","ORF7a","ORF7b","ORF8","ORF9","ORF10")
gff$V8<-orflist
gff<-gff[,1:8]
muts <- fromJSON(file=argv$anc)
allnodes<-muts$nodes
codons<-read.table(argv$c,header=TRUE)
codons$codons<-as.character(codons$codons)
codondf<-as.data.frame(matrix(0, nrow=length(allnodes), ncol=nrow(codons)+1))
colnames(codondf)<-c("header",codons$codons)
row.names(gff)<-1:nrow(gff)
treedf<-as.data.frame(matrix(0, nrow=0, ncol=nrow(codons)+2))
colnames(treedf)<-c("position","form/deform",codons$codons)
for(i in 1:length(allnodes)){
 mutations<-allnodes[i][[1]]$muts
 if(length(mutations)>0){
 for (n in 1:length(mutations)){
 if(!str_detect(mutations[n],"-") & !str_detect(mutations[n],"N")){
 mut<-mutations[n]
 old<-substr(mut,1,1)
 new<-substr(mut,nchar(mut),nchar(mut))
 position<-as.integer(substr(mut,2,nchar(mut)-1))
 if(length(which((gff$V4 <= position & position<=gff$V5)))!=0){
 orfrowf<-which(gff$V4 <= position & position <=gff$V5)
 for(orfrow in orfrowf){
 orfseq<-substr(allnodes[i][[1]]$sequence,gff$V4[orfrow],gff$V5[orfrow])
 codes<-unlist(stri_extract_all(orfseq,regex = "..."))
 form<-codes[floor((position-gff$V4[orfrow])/3)+1]
 nucpos<-((position-gff$V4[orfrow])%%3)+1
 deform<-form
 if(nucpos==1){if(n+1<=length(mutations)){if(as.integer(substr(mutations[n+1],2,nchar(mutations[n+1])-1))==position+1){
 substr(deform,2,2)<-substr(mutations[n+1],1,1)}}
 if(n+2<=length(mutations)){if(as.integer(substr(mutations[n+2],2,nchar(mutations[n+2])-1))==position+2){
 substr(deform,3,3)<-substr(mutations[n+2],1,1)
 }}}
 if(nucpos==2){if(n-1!=0){if(as.integer(substr(mutations[n-1],2,nchar(mutations[n-1])-1))==position-1){
 substr(deform,1,1)<-substr(mutations[n-1],1,1)}}
 if(n+1<=length(mutations)){if(as.integer(substr(mutations[n+1],2,nchar(mutations[n+1])-1))==position+1){
 substr(deform,3,3)<-substr(mutations[n+1],1,1)
 }}}
 if(nucpos==3){if(n-1!=0){if(as.integer(substr(mutations[n-1],2,nchar(mutations[n-1])-1))==position-1){
 substr(deform,2,2)<-substr(mutations[n-1],1,1)}}
 if(n-2>0){if(as.integer(substr(mutations[n-2],2,nchar(mutations[n-2])-1))==position-2){
 substr(deform,1,1)<-substr(mutations[n-2],1,1)
 }}}
 treedf[nrow(treedf)+1,]<-0
 treedf[nrow(treedf),which(names(treedf)==form)]<-treedf[nrow(treedf),which(names(treedf)==form)]+1
 treedf[nrow(treedf),1]<-position
 treedf[nrow(treedf), 2]<-"form"
 substr(deform,((position-gff$V4[orfrow])%%3)+1,((position-gff$V4[orfrow])%%3)+1)<-old
 treedf[nrow(treedf)+1,]<-0
 treedf[nrow(treedf), which(names(treedf)==deform)]<-treedf[nrow(treedf), which(names(treedf)==deform)]+1
 treedf[nrow(treedf), 1]<-position
 treedf[nrow(treedf), 2]<-"deform"
 }
 
 }
 } 
 }
 }
}
df2 <- aggregate(treedf[,3:ncol(treedf)],by=list(treedf$position,treedf$`form/deform`),FUN=sum, na.rm=TRUE)
df2<-df2[order(df2$Group.1),]
write.table(df2,argv$fd,sep = "\t", quote = FALSE, row.names = FALSE)
colnames(df2)<-c("position","form/deform",codons$codons)
df3<-melt(data = df2, id.vars = c("position", "form/deform"), measure.vars = c(names(df2)[c(3:ncol(df2))]))
df4<-dcast(df3, position+variable ~ `form/deform`, value.var="value")
df4$net<-df4$form-df4$deform
bypos<- aggregate(df4[,5],by=list(df4$position),FUN=sum, na.rm=TRUE)
bycod<- aggregate(df4[,5],by=list(df4$variable),FUN=sum, na.rm=TRUE)
bycodlog<- aggregate(df4[,c(3,4,5)],by=list(df4$variable),FUN=sum, na.rm=TRUE)
bycodlog$loged<-log2(bycodlog$form/bycodlog$deform)
aainfo<-as.data.frame(read.table(argv$a))
aainfo$V1<-as.character(aainfo$V1)
bycodlog$aa<-0
for( i in 1:nrow(bycodlog)){
 if(bycodlog$Group.1[i] %in% aainfo$V1){
 bycodlog$aa[i]<-as.character(aainfo[which(aainfo$V1==bycodlog$Group.1[i]),2])}
}
bycodlog[which(bycodlog$aa==0),6]<-"*"
bycodlog$Group.1<- gsub('T', 'U', bycodlog$Group.1)
bycodlog$Group.1<-as.character(bycodlog$Group.1)
fig3a<-ggplot(data=subset(bycodlog, bycodlog$aa != "*") , aes(y=loged,x=fct_reorder(Group.1, aa),fill=aa)) +
 geom_bar(stat="identity",fill="deepskyblue4") +theme_classic()+ ylab("log2 normalized codon change")+xlab("")+
 facet_grid(~aa, scales = "free_x", space = "free_x")+
 theme(axis.text.x = element_text(angle = 60, hjust = 1),strip.background.x = element_blank(),
 legend.position= "bottom",legend.direction = "horizontal",legend.justification = "right",
 panel.grid.major = element_blank(),
 panel.grid.minor = element_blank(),
 strip.background = element_blank(),
 
 axis.line.x.top = element_line(colour="gray"),
 axis.line.y=element_line(colour="gray"),
 panel.border = element_rect(colour = "gray", fill = NA))
###############################################################################
#### Fig3b 
###############################################################################
###creating the codon numbers table for Sars-CoV-2
codons<-read.table(argv$c,header=TRUE)
codons$codons<-as.character(codons$codons)
aln2 <- import.fasta(argv$fa)
ref<-as.data.frame(matrix(0, nrow=length(aln2), ncol=2))
names(ref)<-c("header","seqs")
for(node in 1:length(aln2)){
 ref$header[node]<-names(aln2)[node]
 a<-gsub("*,","",toString(aln2[[node]]))
 ref$seqs[node]<-gsub("* ","",a)
}
refdf<-as.data.frame(matrix(0, 1, ncol=nrow(codons)+1))
colnames(refdf)<-c("header",codons$codons)
for(t in 1:nrow(gff)){
 orf<-substr(ref$seqs[1],gff$V4[t],gff$V5[t])
 codes<-unlist(stri_extract_all(orf,regex = "..."))
 for(c in 2:ncol(refdf)){
 refdf[1,c]<- refdf[1,c]+sum(str_count(codes, names(refdf)[c] ))
 }
}
refdf<-melt(data = refdf, id.vars = c("header"), measure.vars = c(names(refdf)[c(2:ncol(refdf))]))
refdf$aa<-0
for( i in 1:nrow(refdf)){
 if(refdf$variable[i] %in% aainfo$V1){
 refdf$aa[i]<-as.character(aainfo[which(aainfo$V1==refdf$variable[i]),2])}
}
refdf[which(refdf$aa==0),4]<-"*"
refdf$total<-0
for( i in 1:nrow(refdf)){refdf$total[i]<-sum(refdf[which(refdf$aa==refdf$aa[i]),3])}
refdf$percent<-refdf$value/refdf$total*100
colnames(refdf)<-c("header","codon","count","aa","total","percent")
#########################################################################################
###creating the codon numbers table for hg38 and comparison with Sars-CoV-2
human<-as.data.frame(read.table(argv$u,header=T))
human$percent<-human$relative_frequency*100
colnames(refdf)[2]<-"codon"
human$codon<- gsub('U', 'T', human$codon)
humsars<-merge(human,refdf,by="codon")
colnames(humsars)[4]<-"hum_percent"
colnames(humsars)[9]<-"sars_percent"
humsars<-melt(data = humsars, id.vars = c("codon", "amino_acid"), measure.vars = c("sars_percent", "hum_percent"))
humsars$relativeratio<-0
for( i in 1:nrow(humsars)){
 sum<-sum(humsars[which(humsars$codon==humsars$codon[i]),4])
 humsars$relativeratio[i]<-humsars$value[i]/sum
}
humsars$codon<- gsub('T', 'U', humsars$codon)
humsars<-humsars[order(humsars$codon),]
fig3b<-ggplot(subset(humsars,amino_acid!="*") , aes(x=fct_reorder(codon, as.numeric(amino_acid)), y=relativeratio,fill=variable)) +
 geom_col()+ theme(panel.grid.major.x = element_line(color = "gray80", size = 0.3),panel.background = element_rect(fill = "white"),plot.title = element_text(hjust = 0.5))+
 geom_hline(yintercept=0.5,color="gray30", linetype="dashed" ,size=1)+xlab("Codons")+ylab("Relative codon usage ratio")+#facet_grid(~amino_acid, scales = "free_x", space = "free_x")+
 labs(fill="Codon's relative percent")+facet_grid(~amino_acid, scales = "free_x", space = "free_x")+
 theme_classic()+theme(legend.position="bottom")+theme(axis.text.x = element_text(angle = 60, hjust = 1),strip.background.x = element_blank(),
 legend.position= "bottom",legend.direction = "horizontal",legend.justification = "right",
 panel.grid.major = element_blank(),
 panel.grid.minor = element_blank(),
 strip.background = element_blank(),
 
 axis.line.x.top = element_line(colour="gray"),
 axis.line.y=element_line(colour="gray"),
 panel.border = element_rect(colour = "gray", fill = NA))+
 
 scale_fill_manual(values=c("#008b69","goldenrod"),name = "", labels = c( "SARS-CoV-2 ","Homo Sapiens"))
write.table(humsars,argv$rel,sep = "\t", quote = FALSE, row.names = FALSE)
fig3<-fig3a/fig3b+plot_annotation(tag_levels = 'A')
ggsave(filename = argv$f3, fig3,
       width = 10, height = 6.5,dpi = 500, units = "in", device='png')
