library(argparser)

# Create a parser
p <- arg_parser("Get headers of sequences that pass quality controls")
p <- add_argument(p, "-i", help="input")
p <- add_argument(p, "-o", help="output")

# Parse the command line arguments
argv <- parse_args(p)

masterData <- read.csv(argv$i, sep=",",header = F)

masterData2<-as.data.frame(masterData[which(masterData$V2<30),])
masterData2<-as.data.frame(masterData2[which(masterData2$V3<200),])
masterData2<-as.data.frame(masterData2[which(masterData2$V4<200),])

# ggplot(masterData2[which(masterData2$V2>1),], aes(x=V2))+
#   geom_histogram(color="black", fill="lightblue",
#                  linetype="dashed")

headers<-as.data.frame(masterData2$V1)
colnames(headers)<-c("headers")
write.table(headers,argv$o, quote = FALSE, row.names = FALSE)
