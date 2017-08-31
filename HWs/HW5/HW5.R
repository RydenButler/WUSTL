library(stm)
library(jsonlite)
setwd("~/Documents/GitHub/WUSTL/HWs/HW5")

##############
# Question 1 #
##############

# Load in data
Data <- read_json('nyt_ac.json')

# Isolate texts 
Texts <- unlist(lapply(Data, function(x) x$body$body_text))
# Isolate desk info
Desks <- unlist(lapply(Data, function(x) x$meta$dsk))

# Process and prepare documents for stm
ProcessedTexts <- textProcessor(Texts)
PreppedDocs <- prepDocuments(ProcessedTexts$documents, ProcessedTexts$vocab)

# Fit stm model
Fit <- stm(PreppedDocs$documents, 
           PreppedDocs$vocab, 
           K = 8, 
           prevalence = ~ Desks,
           seed = 1)
# Check topics
labelTopics(Fit)
# 1: arts
# 2: basketball
# 3: business
# 4: football
# 5: electoral politics
# 6: 2004 presidential election
# 7: military
# 8: Israel

# Fit stm w/o conditioning on desk
VanillaFit <- stm(PreppedDocs$documents,
                  PreppedDocs$vocab,
                  K = 8,
                  seed = 1)

# Compare difference in topic proportions
# In most all instances this is minimal
round(Fit$theta - VanillaFit$theta,3)

##############
# Question 2 #
##############

MachDTM <- read.csv('HW5DTM.csv')
NormalizedDTM <- t(apply(MachDTM, 1, function(x) x/sum(x)))

PCA <- prcomp(NormalizedDTM, scale. = T) 
plot(summary(PCA)[[6]][3,], pch = 19, cex = 0.1, 
     xlab = 'Principal Component', ylab = 'Cumulative Proportion Variance Explained')
plot(summary(PCA)[[6]][2,], pch = 19, cex = 0.5, 
     xlab = 'Principal Component', ylab = 'Proportion Variance Explained')
# Each principal component contains relatively little information about the 
# various dimensions of the data. Summarizing 80% of the variance explained 
# via the PCA requires over 100 principal components.

plot(PCA$x[,1], PCA$x[,2], type = 'n', xlab = 'PC1', ylab = 'PC2')
text(PCA$x[,1], PCA$x[,2], as.character(1:188))

sort(PCA$rotation[,1]) # diplomacy/thought
sort(PCA$rotation[,2]) # violence/force
# Based on the kinds of words that load highly on each dimension, the first
# PC seems related to diplomacy ("ruler", "will", "way", "human", "shrewd")
# while the second PC loads highly on aggressive words ("kill", "cruel", 
# "soldier", "despis"). These suggest that the primary variation in The Prince
# is explained by both diplomatic and military concepts

##############
# Question 3 #
##############

DX <- dist(NormalizedDTM)
mds_scale <- cmdscale(DX, k = 2)
PCATwo <- prcomp(NormalizedDTM)
cor(mds_scale[,1], PCATwo$x[,1]) # cor = -1
DXTwo <- dist(NormalizedDTM, method = 'manhattan')
mds_scale_two <- cmdscale(DXTwo, k = 2)
cor(mds_scale_two[,1], PCATwo$x[,1]) # cor = -0.939978

