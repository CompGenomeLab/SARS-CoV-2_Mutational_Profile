# MUTATION PROFILE PLOT GENERATOR
# WRITTEN IN ADEBALI LAB - SABANCI UNIVERSITY
# UPDATED FEBRUARY 2021
# adebalilab.org

## library dependencies
library(dplyr)
library(plotly)
library(argparser)

# Create a parser
p <- arg_parser("File for mutation profile plotter:")

# Add command line arguments
p <- add_argument(p, "-i", help="input trinucleotide normalized mutation file")
p <- add_argument(p, "-o", help="name of the plot")

# Parse the command line arguments
argv <- parse_args(p)

## NOTE THAT CODE HAVE U AND T SIMULTANEOUSLY 
## IF YOU WORK ON DNA SEQUENCES CHANGE EVERY U INTO T THAT OCCURS WITHIN THE CODE
## IF YOU WORK ON RNA SEQUENCES THIS CODE CAN BE USED WITHOUT ANY MODIFICATION

df <- read.table(argv$i, header=F, check.names=FALSE) #insert file of the name here with the same format and mutation&trinucleotide of trinuc_freq.tsv

names(df) <- c("mutation","trinuc","count") #first column should have mutation type, second should have trinucleotide type and 


df <- df %>% 
  mutate(count = count / 100) ##this is for adjusting the y axis values by dividing the counts, it is optional & can be removed or edited

my_range <- ceiling(max(df$count, na.rm = TRUE)) + 0.1

out <- split( df , f = df$mutation )

##################### figure frames #########################

#C>A, C>G, C>T, T>A, T>C, T>G
#G>T, G>C, G>A, A>T, A>G, A>C


ca <- out[[4]]
ca <- droplevels(ca)

cg <- out[[5]]
cg <- droplevels(cg)

ct <- out[[6]]
ct <- droplevels(ct)


ta <- out[[10]]
ta <- droplevels(ta)

tc <- out[[11]]
tc <- droplevels(tc)

tg <- out[[12]]
tg <- droplevels(tg)

################

gt <- out[[9]]
gt <- droplevels(gt)
x = rev(c("AGA", "CGA", "GGA", "UGA" ,"AGC" ,"CGC", "GGC", "UGC" ,"AGG" ,"CGG" ,"GGG" ,"UGG", "AGU", "CGU", "GGU" ,"UGU"))
gt <- gt %>% slice(match(x, trinuc))
gt$trinuc <- factor(gt$trinuc, levels = c(as.character(gt$trinuc)))

gc <- out[[8]]
gc <- droplevels(gc)
gc <- gc %>% slice(match(x, trinuc))
gc$trinuc <- factor(gc$trinuc, levels = c(as.character(gc$trinuc)))


ga <- out[[7]]
ga <- droplevels(ga)
ga <- ga %>% slice(match(x, trinuc))
ga$trinuc <- factor(ga$trinuc, levels = c(as.character(ga$trinuc)))



at <- out[[3]]
at <- droplevels(at)
x = rev(c("AAA", "CAA", "GAA", "UAA", "AAC", "CAC", "GAC", "UAC", "AAG", "CAG", "GAG", "UAG" ,"AAU" ,"CAU", "GAU" ,"UAU"))
at <- at %>% slice(match(x, trinuc))
at$trinuc <- factor(at$trinuc, levels = c(as.character(at$trinuc)))

ag <- out[[2]]
ag <- droplevels(ag)
ag <- ag %>% slice(match(x, trinuc))
ag$trinuc <- factor(ag$trinuc, levels = c(as.character(ag$trinuc)))


ac <- out[[1]]
ac <- droplevels(ac)
ac <- ac %>% slice(match(x, trinuc))
ac$trinuc <- factor(ac$trinuc, levels = c(as.character(ac$trinuc)))



##################### figure frames #########################


#C>A, C>G, C>T, T>A, T>C, T>G
#G>T, G>C, G>A, A>T, A>G, A>C



fig_ca <- plot_ly(
  x = ca$trinuc,
  y = ca$count,
  type="bar",
  color = I("#2ac0eb"),
  text = paste("mutation type:",ca$mutation),
  
)

fig_gt <- plot_ly(
  x = gt$trinuc,
  y = gt$count,
  type="bar",
  color = I("#2ac0eb"),
  text = paste("mutation type:",gt$mutation),
  
)


fig_cg <- plot_ly(
  x = cg$trinuc,
  y = cg$count,
  type="bar",
  color = I("#1d1d1d"),
  text = paste("mutation type:",cg$mutation)
  
)

fig_gc <- plot_ly(
  x = gc$trinuc,
  y = gc$count,
  type="bar",
  color = I("#1d1d1d"),
  text = paste("mutation type:",gc$mutation)
  
)

fig_ct <- plot_ly(
  x = ct$trinuc,
  y = ct$count,
  type="bar",
  color = I("#dc3b38"),
  text = paste("mutation type:",ct$mutation)
  
)

fig_ga <- plot_ly(
  x = ga$trinuc,
  y = ga$count,
  type="bar",
  color = I("#dc3b38"),
  text = paste("mutation type:",ga$mutation)
  
)

fig_ta <- plot_ly(
  x = ta$trinuc,
  y = ta$count,
  type="bar",
  color = I("#979898"),
  text = paste("mutation type:",ta$mutation)
  
)

fig_at <- plot_ly(
  x = at$trinuc,
  y = at$count,
  type="bar",
  color = I("#979898"),
  text = paste("mutation type:",at$mutation)
  
)

fig_tc <- plot_ly(
  x = tc$trinuc,
  y = tc$count,
  type="bar",
  color = I("#a0ca62"),
  text = paste("mutation type:",tc$mutation)
  
)

fig_ag <- plot_ly(
  x = ag$trinuc,
  y = ag$count,
  type="bar",
  color = I("#a0ca62"),
  text = paste("mutation type:",ag$mutation)
  
)

fig_tg <- plot_ly(
  x = tg$trinuc,
  y = tg$count,
  type="bar",
  color = I("#e9c0c0"),
  text = paste("mutation type:",tg$mutation)
)

fig_ac <- plot_ly(
  x = ac$trinuc,
  y = ac$count,
  type="bar",
  color = I("#e9c0c0"),
  text = paste("mutation type:",ac$mutation)
)

f <- list(
  family = "Arial",
  size = 20,
  color = "#000000"
)

ax <- list(
  zeroline = TRUE,
  #  mirror = "ticks",
  gridcolor = toRGB("gray50"),
  gridwidth = .5,
  title = "Normalized Mutation Counts",
  titlefont = f,
  range = c(0,my_range) # You can change this range variable to change Y range on the graph to have a better visualization
  
)

#C>A, C>G, C>T, T>A, T>C, T>G
#G>T, G>C, G>A, A>T, A>G, A>C


p <- subplot(margin = c(0.002,0.002,0.002,.1),fig_ca,fig_cg,fig_ct,fig_ta,fig_tc,fig_tg,fig_gt,fig_gc,fig_ga,fig_at,fig_ag,fig_ac,shareY = T,nrows = 2,heights = c(.5,.4)) %>% hide_legend() %>% layout(xaxis = list(title="C>A",titlefont = f),xaxis2 = list(title="C>G",titlefont = f),xaxis3 = list(title="C>U",titlefont = f),xaxis4 = list(title="U>A",titlefont = f),xaxis5 = list(title="U>C",titlefont = f),xaxis6 = list(title="U>G",titlefont = f),yaxis = ax,
                                                                                                                                                                                                        xaxis7 = list(title="G>U",titlefont = f),xaxis8 = list(title="G>C",titlefont = f),xaxis9 = list(title="G>A",titlefont = f),xaxis10 = list(title="A>U",titlefont = f),xaxis11 = list(title="A>G",titlefont = f),xaxis12 = list(title="A>C",titlefont = f),yaxis2 = ax)

export(p, argv$o)