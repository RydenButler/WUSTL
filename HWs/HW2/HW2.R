setwd("~/Documents/GitHub/WUSTL/HWs/HW2")
UnigramDTM <- read.csv('HW2Unigrams.csv')
TrigramDTM <- read.csv('HW2Trigrams.csv')

# Independent Linear Discriminant: Unigrams
UnigramY <- UnigramDTM[ , 1]
UnigramX <- UnigramDTM[ , -1]/rowSums(UnigramDTM[ , -1])

UnigramSessionsMu <- colMeans(UnigramX[which(UnigramY == 'sessions'), ])
UnigramShelbyMu <- colMeans(UnigramX[which(UnigramY == 'shelby'), ])
UnigramSessionsSigma <- apply(UnigramX[which(UnigramY == 'sessions'), ], 2,  var)
UnigramShelbySigma <- apply(UnigramX[which(UnigramY == 'shelby'), ], 2,  var)

UnigramTheta <- (UnigramSessionsMu - UnigramShelbyMu)/(UnigramSessionsSigma + UnigramShelbySigma)
UnigramThetaCutoff <- ifelse(UnigramTheta < 0.025 & UnigramTheta > -0.025, 0, UnigramTheta)

# Independent Linear Discriminant: Trigrams
TrigramY <- TrigramDTM[ , 1]
TrigramX <- TrigramDTM[ , -1]/rowSums(TrigramDTM[ , -1])
TrigramSessionsMu <- colMeans(TrigramX[which(TrigramY == 'sessions'), ])
TrigramShelbyMu <- colMeans(TrigramX[which(TrigramY == 'shelby'), ])
TrigramSessionsSigma <- apply(TrigramX[which(TrigramY == 'sessions'), ], 2,  var)
TrigramShelbySigma <- apply(TrigramX[which(TrigramY == 'shelby'), ], 2,  var)

TrigramTheta <- (TrigramSessionsMu - TrigramShelbyMu)/(TrigramSessionsSigma + TrigramShelbySigma)
TrigramThetaCutoff <- ifelse(TrigramTheta < 0.025 & TrigramTheta > -0.025, 0, TrigramTheta)

TrigramP = t(TrigramThetaCutoff*t(TrigramX))

# Standardized Mean Difference: Unigram
UnigramStdDiff <- (UnigramSessionsMu - UnigramShelbyMu)/(sqrt(
  (UnigramSessionsSigma/length(which(UnigramY == 'sessions'))) +
  (UnigramShelbySigma/length(which(UnigramY == 'shelby')))
  ))

# Standardized Mean Difference: Trigram
TrigramStdDiff <- (TrigramSessionsMu - TrigramShelbyMu)/(sqrt(
  (TrigramSessionsSigma/length(which(TrigramY == 'sessions'))) +
    (TrigramShelbySigma/length(which(TrigramY == 'shelby')))
))

# Standardized Log Odds: Unigrams
UnigramXCount <- UnigramDTM[ , -1]
UnigramSessionsX <- colSums(UnigramXCount[which(UnigramY == 'sessions'), ])
UnigramShelbyX <- colSums(UnigramXCount[which(UnigramY == 'shelby'), ])
alpha <- rep(1, ncol(UnigramXCount))
UnigramSessionsPi <- (UnigramSessionsX + alpha)/(sum(UnigramSessionsX) + sum(alpha))
UnigramShelbyPi <- (UnigramShelbyX + alpha)/(sum(UnigramShelbyX) + sum(alpha))
UnigramLogOddsRatio <- log(UnigramSessionsPi/(1-UnigramSessionsPi)) - log(UnigramShelbyPi/(1-UnigramShelbyPi))
UnigramVarLogOdds <- (1/(UnigramSessionsX + alpha)) + (1/(UnigramShelbyX + alpha))
UnigramStdLogOdds <- UnigramLogOddsRatio/sqrt(UnigramVarLogOdds)

# Standardized Log Odds: Trigrams
TrigramXCount <- TrigramDTM[ , -1]
TrigramSessionsX <- colSums(TrigramXCount[which(TrigramY == 'sessions'), ])
TrigramShelbyX <- colSums(TrigramXCount[which(TrigramY == 'shelby'), ])
alpha <- rep(1, ncol(TrigramXCount))
TrigramSessionsPi <- (TrigramSessionsX + alpha)/(sum(TrigramSessionsX) + sum(alpha))
TrigramShelbyPi <- (TrigramShelbyX + alpha)/(sum(TrigramShelbyX) + sum(alpha))
TrigramLogOddsRatio <- log(TrigramSessionsPi/(1-TrigramSessionsPi)) - log(TrigramShelbyPi/(1-TrigramShelbyPi))
TrigramVarLogOdds <- (1/(TrigramSessionsX + alpha)) + (1/(TrigramShelbyX + alpha))
TrigramStdLogOdds <- TrigramLogOddsRatio/sqrt(TrigramVarLogOdds)

# Plot Discrimination Parameters: Unigrams
# ILD
plot(1, type='n', 
     xlim = c(min(UnigramThetaCutoff), max(UnigramThetaCutoff)), 
     ylim = c(0, 20),
     xlab = "",
     ylab = "",
     axes=F,
     main = "Independent Linear Discrimination")
axis(1, at = seq(round(min(UnigramThetaCutoff),-2), round(max(UnigramThetaCutoff), -2), 200))
abline(v = 0, lty = 2)
text(x = -200, y = 1, "Shelby")
text(x = 200, y = 1, "Sessions")
text(x = c(head(sort(UnigramThetaCutoff), 10), 
           tail(sort(UnigramThetaCutoff), 10)),
     y = seq(1,20),
     labels = c(names(head(sort(UnigramThetaCutoff), 10)), 
                names(tail(sort(UnigramThetaCutoff), 10))),
     cex = 0.75)
# Std Diff
plot(1, type='n', 
     xlim = c(min(UnigramStdDiff), max(UnigramStdDiff)), 
     ylim = c(0, 20),
     xlab = "",
     ylab = "",
     axes=F,
     main = "Standard Difference")
axis(1, at = seq(round(min(UnigramStdDiff),-1), round(max(UnigramStdDiff), -1), 10))
abline(v = 0, lty = 2)
text(x = -20, y = 1, "Shelby")
text(x = 20, y = 1, "Sessions")
text(x = c(head(sort(UnigramStdDiff), 10), 
           tail(sort(UnigramStdDiff), 10)),
     y = seq(1,20),
     labels = c(names(head(sort(UnigramStdDiff), 10)), 
                names(tail(sort(UnigramStdDiff), 10))),
     cex = 0.75)
# Standardized Log Odds
plot(1, type='n', 
     xlim = c(min(UnigramStdLogOdds), max(UnigramStdLogOdds)), 
     ylim = c(0, 20),
     xlab = "",
     ylab = "",
     axes=F,
     main = "Standardized Log Odds")
axis(1, at = seq(round(min(UnigramStdLogOdds),-1), round(max(UnigramStdLogOdds), -1), 10))
abline(v = 0, lty = 2)
text(x = -5, y = 1, "Shelby")
text(x = 5, y = 1, "Sessions")
text(x = c(head(sort(UnigramStdLogOdds), 10), 
           tail(sort(UnigramStdLogOdds), 10)),
     y = seq(1,20),
     labels = c(names(head(sort(UnigramStdLogOdds), 10)), 
                names(tail(sort(UnigramStdLogOdds), 10))),
     cex = 0.75)

# Plot Discrimination Parameters: Trigrams
# ILD
plot(1, type='n', 
     xlim = c(round(min(TrigramThetaCutoff),-2), round(max(TrigramThetaCutoff),-2)), 
     ylim = c(0, 20),
     xlab = "",
     ylab = "",
     axes=F,
     main = "Independent Linear Discrimination")
axis(1, at = seq(round(min(TrigramThetaCutoff),-2), round(max(TrigramThetaCutoff), -2), 100))
abline(v = 0, lty = 2)
text(x = -100, y = 1, "Shelby")
text(x = 100, y = 1, "Sessions")
text(x = c(head(sort(TrigramThetaCutoff), 10), 
           tail(sort(TrigramThetaCutoff), 10)),
     y = seq(1,20),
     labels = c(names(head(sort(TrigramThetaCutoff), 10)), 
                names(tail(sort(TrigramThetaCutoff), 10))),
     cex = 0.75)

# Std Diff
plot(1, type='n', 
     xlim = c(min(TrigramStdDiff), max(TrigramStdDiff)), 
     ylim = c(0, 20),
     xlab = "",
     ylab = "",
     axes=F,
     main = "Standard Difference")
axis(1, at = seq(round(min(TrigramStdDiff),-1), round(max(TrigramStdDiff), -1), 10))
abline(v = 0, lty = 2)
text(x = -20, y = 1, "Shelby")
text(x = 20, y = 1, "Sessions")
text(x = c(head(sort(TrigramStdDiff), 10), 
           tail(sort(TrigramStdDiff), 10)),
     y = seq(1,20),
     labels = c(names(head(sort(TrigramStdDiff), 10)), 
                names(tail(sort(TrigramStdDiff), 10))),
     cex = 0.75)
# Standardized Log Odds
plot(1, type='n', 
     xlim = c(-50, 50), 
     ylim = c(0, 20),
     xlab = "",
     ylab = "",
     axes=F,
     main = "Standardized Log Odds")
axis(1, at = seq(-50, 50, 10))
abline(v = 0, lty = 2)
text(x = -30, y = 1, "Shelby")
text(x = 30, y = 1, "Sessions")
text(x = c(head(sort(TrigramStdLogOdds), 10), 
           tail(sort(TrigramStdLogOdds), 10)),
     y = seq(1,20),
     labels = c(names(head(sort(TrigramStdLogOdds), 10)), 
                names(tail(sort(TrigramStdLogOdds), 10))),
     cex = 0.75)

# The plots of the unigrams demonstrate that Shelby and Sessions have markedly
#   different types of messages that they deliver in press releases. Sessions's 
#   most discriminating words appear to be mundane (thursday, wednesday, month)
#   whereas Shelby is communicating on specific topics (prostitut,
#   fatherhood, pegasu, experiment).
# Generally the three measures of discrimination yield similar results. The 
#   primary difference between measures is range over which discrimination values
#   occur. Additionally, the standardized log odds appears to deeply distinguish
#   between senators' discriminating words, whereas the other methods yield a 
#   more continuous measure of discrimination.

#####################################
### Comparing Document Similarity ###
#####################################
SessionsSample <- TrigramDTM[sample(sum(TrigramDTM$speaker == 'sessions'), 100), ]
ShelbySample <- TrigramDTM[sample(sum(TrigramDTM$speaker == 'sessions'):sum(TrigramDTM$speaker == 'shelby'), 100), ]

SimilarityMatrix <- rbind(SessionsSample, ShelbySample)[-1]
# Euclidean Distance
EuclideanDistance <- apply(SimilarityMatrix, 
                           1, 
                           function(x){rowSums(sweep(SimilarityMatrix,
                                                     MARGIN = 2,
                                                     x,
                                                     `-`)^2)})

# Euclidean Distance: tf-idf
ExistingTerms <- which(colSums(SimilarityMatrix) > 0)
TFIDF <- log(nrow(SimilarityMatrix[,ExistingTerms])/colSums(SimilarityMatrix[,ExistingTerms]))
WeightedMatrix <- sweep(SimilarityMatrix[,ExistingTerms],
                        MARGIN = 2,
                        TFIDF,
                        `*`)
EuclideanTFIDF <- apply(WeightedMatrix, 
                           1, 
                           function(x){rowSums(sweep(WeightedMatrix,
                                                     MARGIN = 2,
                                                     x,
                                                     `-`)^2)})
# Cosine Similarity
Norms <- sqrt(rowSums(SimilarityMatrix^2))
Cosines <- SimilarityMatrix/Norms
CosineSimilarity <- t(as.matrix(Cosines)) %*% as.matrix(Cosines)

# Cosine Similarity: tf-idf
WeightedNorms <- sqrt(rowSums(WeightedMatrix))
CosinesTFIDF <- WeightedMatrix/WeightedNorms
CosineSimilarityTFIDF <- t(as.matrix(CosinesTFIDF)) %*% as.matrix(CosinesTFIDF)

# Normalized Trigrams
NormalizedTrigrams <- SimilarityMatrix/rowSums(SimilarityMatrix)

# Normalized Trigrams: tf-idf
NormalizedTrigramsTFIDF <- WeightedMatrix/rowSums(WeightedMatrix)

