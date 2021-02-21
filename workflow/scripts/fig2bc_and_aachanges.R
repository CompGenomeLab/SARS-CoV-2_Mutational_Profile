#Highly occuring mutations
library(ggplot2)
library(ggthemes)
library(reshape2)
library(stringi)
library(argparser)
library(rjson)

################################
# Create a parser
p <- arg_parser("producing Figure 2b and 2c")
p <- add_argument(p, "-t", help="input, mutational counts pos trimer")
p <- add_argument(p, "-anc", help="input, ancestral sequences")
p <- add_argument(p, "-ref", help="input, reference gff file")
p <- add_argument(p, "-c", help="input, codon table")
p <- add_argument(p, "-a", help="input, aminoacid table")
p <- add_argument(p, "-tsv", help="output, tsv file")
p <- add_argument(p, "-aa", help="output, all aminoacids")
p <- add_argument(p, "-f2b", help="output, figure 2b")
p <- add_argument(p, "-f2c", help="output, figure 2c")
# Parse the command line arguments
argv <- parse_args(p)
################################

muts<-read.table(argv$t, header=TRUE)
highmuts<-as.data.frame(matrix(0,nrow = 0, ncol=4))
colnames(highmuts)<-c("pos","mut","trimer","count")
for(i in 1:nrow(muts)){
  for(t in 3:ncol(muts)){
    if(muts[i,t] > 0){
      highmuts[nrow(highmuts)+1,1]<-muts[i,1] #pos
      highmuts[nrow(highmuts),2]<-as.character(muts[i,2])#mut
      highmuts[nrow(highmuts),3]<-paste(substr(colnames(muts[t]),1,1),substr(muts[i,2],1,1),substr(colnames(muts[t]),3,3),sep = "")
      highmuts[nrow(highmuts),4]<-muts[i,t] #count
    }
  }
}
mutbytype <- aggregate(muts[,3:ncol(muts)],by=list(muts$mut),FUN=sum, na.rm=TRUE)
for( i in 1:nrow(highmuts)){
  mut<-highmuts$mut[i]
  for(t in 1:nrow(mutbytype)){
    if(mut==mutbytype$Group.1[t]){
      trimer<-highmuts$trimer[i]
      for( c in 2:ncol(mutbytype)){
        if(trimer== paste(substr(colnames(mutbytype)[c],1,1),substr(mutbytype$Group.1[t],1,1),substr(colnames(mutbytype)[c],3,3),sep=""))
          highmuts$total[i]<-mutbytype[t,c]}
    }
  }
}
highmuts$percent<-(highmuts$count/highmuts$total)*100
highmuts$per<-"0-10"
highmuts$per[which(highmuts$percent>10)]<-"10-15"
highmuts$per[which(highmuts$percent>15)]<-"15-25"
highmuts$per[which(highmuts$percent>25)]<-"more than 25"
highmuts$per<-factor(highmuts$per,levels=c("0-10","10-15","15-25","more than 25"))
mutbypos <- aggregate(muts[,3:ncol(muts)],by=list(muts$pos),FUN=sum, na.rm=TRUE)
mutbypos<-melt(data = mutbypos, id.vars = c("Group.1"), measure.vars = c(names(mutbypos)[c(2:ncol(mutbypos))]))
mutbypos <- aggregate(mutbypos[,3],by=list(mutbypos$Group.1),FUN=sum, na.rm=TRUE)
colnames(mutbypos)<-c("pos","mut")
highmuts$pos<-as.numeric(highmuts$pos)
highmuts$trimer<- gsub('T', 'U', highmuts$trimer)
highmuts$mut<- gsub('T', 'U', highmuts$mut)
highmuts<-highmuts[order(highmuts$percent,decreasing = T),]
highmuts$mut <- reorder(highmuts$mut, highmuts$percent)
highmuts$mut <- factor(highmuts$mut, levels=levels(highmuts$mut))
fig2c<-ggplot(mutbypos[which(mutbypos$mut>0),],aes(y=mut, x=pos)) +
  geom_bar( stat="identity",color="mediumpurple4")+
  geom_point(highmuts[which(highmuts$percent>10 & highmuts$count>8),], mapping=aes(x=pos,y=count,color=mut,shape=per),size=3)+
  scale_color_manual(values=c("#df4e4b","#a9cf71","#90b558","#c63532","#25acd3","#3fc6ed","#878888","#d1acac","#abacac","#ebc6c6","#1a1a1a"))+
  theme_classic()+theme(legend.position=c(0.9,0.8),
                        legend.justification = "right",
                        legend.direction="vertical",
                        legend.background = element_blank())+
  labs(shape="Impact on signatures (%)",color="Mutation type")+guides(color = FALSE)+
  xlab("Nucleotide Position")+
  ylab("Number of mutations in tree")
ggsave(filename = argv$f2c, fig2c,
       width = 15, height = 3,dpi = 700, units = "in", device='png')

################################################################### Fig2c end
fig2b<-ggplot(highmuts[which(highmuts$percent>10 & highmuts$count>8),], aes(fill=mut, y=percent, x=reorder(trimer,percent, FUN = "sum")) ) +
  geom_bar(position="stack", stat="identity",color="white",size=1.5)+theme_classic()+
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = c(.85, .3),
        legend.justification = c("bottom"),
        legend.box.just = "bottom",
        legend.margin = margin(6, 6, 6, 6))+
  scale_fill_manual(values=c("#df4e4b","#a9cf71","#90b558","#c63532","#25acd3","#3fc6ed","#878888","#d1acac","#abacac","#ebc6c6","#1a1a1a"))+
  ylab("Impact on signature (%)")+coord_flip()+labs(fill="Mutation Type")+xlab("Codons")+geom_text(aes(label=pos),size = 3, position = position_stack( vjust = 0.5))
ggsave(filename = argv$f2b, fig2b,
       width = 5, height = 6,dpi = 500, units = "in", device='png')
write.table(highmuts,argv$tsv,sep = "\t", quote = FALSE, row.names = FALSE)
##################################################################### Fig2b end
###for just calculating reference genome
gff<-as.data.frame(read.table(argv$ref, fill = TRUE ))
gff<-gff[grepl("CDS",gff$V3 ),]
gff<-gff[-c(3),] #orf1a removed since orf1ab is the main focus and it comprehends orf1a
orflist<-c("ORF1a" , "ORF1b","ORF2","ORF3","ORF4","ORF5","ORF6","ORF7a","ORF7b","ORF8","ORF9","ORF10")
gff$V8<-orflist
gff<-gff[,1:8]
####
highmuts<-highmuts[which(highmuts$pos %in% highmuts$pos[which(highmuts$count >8 & highmuts$percent>5)]),]
codons<-read.table(argv$c,header=TRUE)
codons$codons<-as.character(codons$codons)
muts <- fromJSON(file=argv$anc)
allnodes<-muts$nodes
aachanges<-as.data.frame(matrix(0,nrow = nrow(highmuts), ncol=nrow(codons)+ncol(highmuts)))
colnames(aachanges)<-c(colnames(highmuts),codons$codons)
aachanges[,c(1:ncol(highmuts))]<-highmuts
aachanges$formdef<-"deforming"
aachanges2<-aachanges
aachanges2$formdef<-"forming"
aachanges<-rbind(aachanges,aachanges2)
aachanges$mut<- gsub('U', 'T', aachanges$mut)
aachanges<-aachanges[order(aachanges$pos,aachanges$mut,aachanges$trimer),]
aachanges$orf<-NA
aachanges$aapos<-0
for(h in seq(1,nrow(aachanges),2)){
  position<-aachanges$pos[h]
  for(i in 1:length(allnodes)){
    muts<-allnodes[i][[1]]$muts
    if(length(muts)>0){
      muts<-as.integer(substr(muts,2,nchar(muts)-1))
      if(position %in% muts){
        n<-which(position==muts)
        mutations<-allnodes[i][[1]]$muts
        mut<-mutations[n]
        old<-substr(mut,1,1)
        new<-substr(mut,nchar(mut),nchar(mut))
        if(paste(old,new,sep=">")==aachanges$mut[h]){
          if(length(which((gff$V4 <= position & position<=gff$V5)))!=0){
            orfrowf<-which(gff$V4 <= position & position <=gff$V5)
            # normally we wouldnt need this loop but since orf7a and b intersect by 3 positions
            # when mutations are in these 3 positions we will have 2 orfs
            for(orfrow in orfrowf){  
              orfseq<-substr(allnodes[i][[1]]$sequence,gff$V4[orfrow],gff$V5[orfrow])
              codes<-unlist(stri_extract_all(orfseq,regex = "..."))
              form<-codes[floor((position-gff$V4[orfrow])/3)+1]
              nucpos<-((position-gff$V4[orfrow])%%3)+1
              deform<-form
              # when there is a mutation at previous or next position this should be initialized on deform
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
              aachanges[h+1,which(names(aachanges)==form)]<-aachanges[h+1,which(names(aachanges)==form)]+1
              substr(deform,((position-gff$V4[orfrow])%%3)+1,((position-gff$V4[orfrow])%%3)+1)<-old
              aachanges[h, which(names(aachanges)==deform)]<-aachanges[h, which(names(aachanges)==deform)]+1
              aachanges$orf[h]<-gff$V8[orfrow]
              aachanges$aapos[h]<-floor((position-gff$V4[orfrow])/3)+1
              aachanges$orf[h+1]<-gff$V8[orfrow]
              aachanges$aapos[h+1]<-floor((position-gff$V4[orfrow])/3)+1
            
            }
          }
        }
      }
    } 
  }
}
aac<-melt(data = aachanges, id.vars = c("pos","mut","trimer","count","formdef","aapos","orf"), measure.vars = c(names(aachanges)[c(8:(ncol(aachanges)-3))]))
aac<-aac[which(aac$value!=0),]
aainfo<-as.data.frame(read.table(argv$a))
aainfo$V1<-as.character(aainfo$V1)
aac$variable<-as.character(aac$variable)
aac$aa<-"*"
for( i in 1:nrow(aac)){
  if(aac$variable[i] %in% aainfo$V1){
    aac$aa[i]<-as.character(aainfo[which(aainfo$V1==aac$variable[i]),2])}
}

aac<-aac[order(aac$pos,aac$mut,aac$trimer),]
colnames(aac)[8]<-"codon"
write.table(aac,argv$aa,sep = "\t", quote = FALSE, row.names = FALSE)