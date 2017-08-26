library(glmnet)

setwd("~/Documents/GitHub/WUSTL/HWs/HW4")

load('StudentDrinking.RData')

# Question 1

# OLS
OLS <- lm(alcohol ~ X)
# LASSO
LASSO <- cv.glmnet(x = X, y = alcohol, alpha = 1, nfolds=5, type.measure="mse")
# Ridge
RIDGE <- cv.glmnet(x = X, y = alcohol, alpha = 0, nfolds=5, type.measure="mse")
# Elastic Net
ENET <- cv.glmnet(x = X, y = alcohol, alpha = 0.5, nfolds=5, type.measure="mse")
# alpha = 0.5 implies that we balance between ridge and lasso regressions. 
# This means that the model shrinks coefficients towards zero while under
#   the constraint of the ridge regression.

# Lasso matrix
coef(LASSO, s=LASSO$lambda)
# Ridge matrix
coef(RIDGE, s=RIDGE$lambda)
# Elastic net matrix
coef(ENET, s=ENET$lambda)

# Plot across lambdas
plot(1, type='n', xlim=c(0,100), ylim=c(0,1), xlab = 'lambda', ylab='Estimate')
abline(h=OLS$coefficients[3])
points(x=1:66, y=coef(LASSO, s=LASSO$lambda)[3,], pch='+', col='blue')
points(x=1:99, y=coef(RIDGE, s=RIDGE$lambda)[3,], pch='+', col='red')
points(x=1:67, y=coef(ENET, s=ENET$lambda)[3,], pch='+', col='green')

# Question 2

# Separate test and training sets
FirstTwenty <- cbind(alcohol[1:20], X[1:20, ])
TrainingData <- cbind(alcohol[21:length(alcohol)], X[21:nrow(X),])
colnames(TrainingData)[1] <- 'alcohol'

# OLS
OLS <- lm(alcohol ~ ., data=as.data.frame(TrainingData))
# LASSO
LASSO <- cv.glmnet(x = TrainingData[,-1], y = TrainingData[,1], alpha = 1, 
                   nfolds=10, type.measure="mse")
# Ridge
RIDGE <- cv.glmnet(x = TrainingData[,-1], y = TrainingData[,1], alpha = 0, 
                   nfolds=10, type.measure="mse")
# Elastic Net
ENET <- cv.glmnet(x = TrainingData[,-1], y = TrainingData[,1], alpha = 0.5, 
                  nfolds=10, type.measure="mse")
# Random Forest
library(randomForest)
TREES <- randomForest(x = TrainingData[,-1], y = TrainingData[,1])

# Predict each
PredictOLS <- predict(OLS, newdata = as.data.frame(TrainingData[,-1]))
PredictLASSO <- predict.cv.glmnet(LASSO, newx = TrainingData[,-1])
PredictRIDGE <- predict.cv.glmnet(RIDGE, newx = TrainingData[,-1])
PredictENET <- predict.cv.glmnet(ENET, newx = TrainingData[,-1])
PredictTREES <- predict(TREES, newdata = TrainingData[,-1])

# Calculate weights
w <- coef(lm(TrainingData[,1] ~ PredictOLS + PredictLASSO + PredictRIDGE + PredictENET + PredictTREES - 1))

# Predict from validation set
OLSValid <- predict(OLS, newdata = as.data.frame(FirstTwenty[,-1]))
LASSOValid <- predict.cv.glmnet(LASSO, newx = FirstTwenty[,-1])
RIDGEValid <- predict.cv.glmnet(RIDGE, newx = FirstTwenty[,-1])
ENETValid <- predict.cv.glmnet(ENET, newx = FirstTwenty[,-1])
TREESValid <- predict(TREES, newdata = FirstTwenty[,-1])

# Combine model predictions
Predictions <- cbind(OLSValid, LASSOValid, RIDGEValid, ENETValid, TREESValid)
# Calculate (un)weighted pedictions
UnWeightedAvg <- rowMeans(Predictions)
WeightedAvg <- rowMeans(sweep(Predictions,
                              2,
                              w,
                              `*`))
# Combine all predictions
PredictionMatrix <- cbind(Predictions, UnWeightedAvg, WeightedAvg)
# Rename columns
colnames(PredictionMatrix) <- c('OLS', 'LASSO', 'Ridge', 'ENet', 'Trees', 
                                'Unweighted', 'Weighted')
# Find correlations
cor(PredictionMatrix)

# Average absolute difference
apply(PredictionMatrix, 2, function(x) sum(abs(FirstTwenty[,1] - x)/length(FirstTwenty[,1])))

# OLS seems to perform best, with an average absolute difference of 0.838
# The weighted average prediction seems to do the worst, with an average absolute difference of 2.143
# I suspect this answer is incorrect, but there's not a whole lot of guidance in the 
#   homework questions or slides that indicates how to properly calculate this