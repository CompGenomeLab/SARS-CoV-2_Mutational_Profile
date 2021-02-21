# NORMALIZED MUTATION COUNTS CORRELATION WITH DIFFERENT IDENTITY THRESHOLDS
# WRITTEN IN ADEBALI LAB - SABANCI UNIVERSITY
# UPDATED FEBRUARY 2021
# adebalilab.org

library(dplyr)
library(plotly)
library(ggpubr)

df <- read.table("trinuc_freq_099.tsv", header=F, check.names=FALSE) ## 0.99 THRESHOLD NORMALIZED MUTATION COUNTS

names(df) <- c("mutation","trinuc","count_099")

df_temp <- read.table("trinuc_freq_0995.tsv", header=F, check.names=FALSE) ## 0.995 THRESHOLD NORMALIZED MUTATION COUNTS
names(df_temp) <- c("mutation","trinuc","count_0995")

df <- merge(df, df_temp, by.df=c("mutation","trinuc"), by.df_temp=c("mutation","trinuc"))

df_temp <- read.table("trinuc_freq_0999.tsv", header=F, check.names=FALSE) ## 0.999 THRESHOLD NORMALIZED MUTATION COUNTS
names(df_temp) <- c("mutation","trinuc","count_0999")

df <- merge(df, df_temp, by.df=c("mutation","trinuc"), by.df_temp=c("mutation","trinuc"))

df <- df %>% 
  mutate(count_099 = count_099 / 100)  ##these are for adjusting the y axis values by dividing the counts, it is optional & can be removed or edited
df <- df %>% 
  mutate(count_0995 = count_0995 / 100) 
df <- df %>% 
  mutate(count_0999 = count_0999 / 100) 

#### .99 AND .995 CORRELATION ####
fig <- plot_ly(data = df, type = "scatter", mode = "markers", x = ~count_099, y = ~count_0995, color = ~mutation,colors = "Set1",text = ~paste("trinucleotide", trinuc))

fig <- layout(fig, xaxis = list(type = "log",title = "Normalized Mutations on 0.99 Similarity (log)"),
              yaxis = list(type = "log",title = "Normalized Mutations on 0.995 Similarity (log)"))

fig

## correlation stats
#kendall non-parametric
p <- ggscatter(df, x = "count_099", y = "count_0995", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "kendall",
          xlab = "Normalized Mutations on 0.99 Similarity (log) & Kendall Correlation", ylab = "Normalized Mutations on 0.995 Similarity (log)")

p <- p + xscale("log2", .format = TRUE) + yscale("log2", .format = TRUE) 
p

#spearman non-parametric
p <- ggscatter(df, x = "count_099", y = "count_0995", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "spearman",
               xlab = "Normalized Mutations on 0.99 Similarity (log) & Spearman Correlation", ylab = "Normalized Mutations on 0.995 Similarity (log)")

p <- p + xscale("log2", .format = TRUE) + yscale("log2", .format = TRUE) 
p

#pearson parametric
p <- ggscatter(df, x = "count_099", y = "count_0995", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "pearson",
               xlab = "Normalized Mutations on 0.99 Similarity (log) & Pearson Correlation", ylab = "Normalized Mutations on 0.995 Similarity (log)")

p <- p + xscale("log2", .format = TRUE) + yscale("log2", .format = TRUE) 
p

#### .99 AND .999 CORRELATION ####
fig <- plot_ly(data = df, type = "scatter", mode = "markers", x = ~count_099, y = ~count_0999, color = ~mutation,colors = "Set1",text = ~paste("trinucleotide", trinuc))

fig <- layout(fig, xaxis = list(type = "log",title = "Normalized Mutations on 0.99 Similarity (log)"),
              yaxis = list(type = "log",title = "Normalized Mutations on 0.999 Similarity (log)"))

fig

## correlation stats
#kendall non-parametric
p <- ggscatter(df, x = "count_099", y = "count_0999", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "kendall",
               xlab = "Normalized Mutations on 0.99 Similarity (log) & Kendall Correlation", ylab = "Normalized Mutations on 0.999 Similarity (log)")

p <- p + xscale("log2", .format = TRUE) + yscale("log2", .format = TRUE) 
p

#spearman non-parametric
p <- ggscatter(df, x = "count_099", y = "count_0999", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "spearman",
               xlab = "Normalized Mutations on 0.99 Similarity (log) & Spearman Correlation", ylab = "Normalized Mutations on 0.999 Similarity (log)")

p <- p + xscale("log2", .format = TRUE) + yscale("log2", .format = TRUE) 
p

#pearson parametric
p <- ggscatter(df, x = "count_099", y = "count_0999", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "pearson",
               xlab = "Normalized Mutations on 0.99 Similarity (log) & Pearson Correlation", ylab = "Normalized Mutations on 0.999 Similarity (log)")

p <- p + xscale("log2", .format = TRUE) + yscale("log2", .format = TRUE) 
p


#### .995 AND .999 CORRELATION ####

fig <- plot_ly(data = df, type = "scatter", mode = "markers", x = ~count_0995, y = ~count_0999, color = ~mutation,colors = "Set1",text = ~paste("trinucleotide", trinuc))

fig <- layout(fig, xaxis = list(type = "log",title = "Normalized Mutations on 0.995 Similarity (log)"),
              yaxis = list(type = "log",title = "Normalized Mutations on 0.999 Similarity (log)"))

fig

## correlation stats
#kendall non-parametric
p <- ggscatter(df, x = "count_0995", y = "count_0999", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "kendall",
               xlab = "Normalized Mutations on 0.995 Similarity (log) & Kendall Correlation", ylab = "Normalized Mutations on 0.999 Similarity (log)")

p <- p + xscale("log2", .format = TRUE) + yscale("log2", .format = TRUE) 
p

#spearman non-parametric
p <- ggscatter(df, x = "count_0995", y = "count_0999", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "spearman",
               xlab = "Normalized Mutations on 0.995 Similarity (log) & Spearman Correlation", ylab = "Normalized Mutations on 0.999 Similarity (log)")

p <- p + xscale("log2", .format = TRUE) + yscale("log2", .format = TRUE) 
p

#pearson parametric
p <- ggscatter(df, x = "count_0995", y = "count_0999", 
               add = "reg.line", conf.int = TRUE, 
               cor.coef = TRUE, cor.method = "pearson",
               xlab = "Normalized Mutations on 0.995 Similarity (log) & Pearson Correlation", ylab = "Normalized Mutations on 0.999 Similarity (log)")

p <- p + xscale("log2", .format = TRUE) + yscale("log2", .format = TRUE) 
p
