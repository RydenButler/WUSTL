setwd("~/Documents/GitHub/WUSTL/HWs/HW3")

# Question 1

# Read in document-term matrix
DTM <- read.csv('HW3DTM.csv')
# Normalize rows
DTM_norm <- DTM[ , -1]/rowSums(DTM[ , -1])
# Empty plot
plot(1, type='n', xlim = c(0,nrow(DTM_norm)), ylim=c(0,3),
     xlab = 'N Clusters', ylab = 'Total Sum of Squares')
# Plot the total sum of squares (objective functions) for each number of clusters
sapply(2:(nrow(DTM_norm)-1), FUN = function(n.clust){points(x=n.clust,
                                             y=kmeans(DTM_norm, 
                                                      centers = n.clust)$tot.withinss,
                                             pch='+')})
# set seed
set.seed(1)
# Calculate kmeans
K <- kmeans(DTM_norm, centers = 6)
# Calculate NotK
NotK <- t(sapply(1:6, FUN=function(x){colMeans(K$centers[-x, ])}))
# DiffK
DiffK <- K$centers - NotK
# Find top 10 most frequent words in each cluster
Labels <- t(apply(DiffK, 1, function(x) names(sort(x, decreasing = T)[1:10])))
# 1 (Elections): vote, republican, state, democrat, voter, elect, poll, senat, bush, ballot
# 2 (Finance): said, it, ha, compani, peopl, will, can, dr, million, unit
# 3 (Sports-Playing): wa, team, hi, game, play, season, said, coach, first, player
# 4 (Sports-Management): g, f, list, injur, place, c, contract, manag, declin, leagu
# 5 (The Arts): s, hi, music, play, work, wa, thi, perform, theater, opera
# 6(2004 Presidential Election): mr, said, hi, bush, kerri, wa, campaign, presid, peterson, report

# Hand labels
# 1 (Presidential Elections)
# 2 (Shopping)
# 3 (Current Events)
# 4 (Baseball Contracts)
# 5 (The Arts)
# 6 (Elections)

# Question 3


