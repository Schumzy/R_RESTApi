#######################
## Data Preprocessing #
#######################

# functions for reading in MNIST data set
source("../utilitiy_functions/readMNISTintoR.R")
# read in MNIST data into R
l.mnist <- load_mnist() # a list

# extract following matrices from the list
m.train.predictors <- l.mnist$train$x$x
m.train.labels <- l.mnist$train$y
m.test.predictors <- l.mnist$test$x$x
m.test.labels <- l.mnist$test$y

# Generate train data frame 
m.train <- cbind(m.train.predictors, m.train.labels)
d.train <- as.data.frame(m.train)
colnames(d.train)[785] <- "Y"
d.train$Y <- as.factor(d.train$Y)
saveRDS(d.train, file = "../mnist_dataframes/mnist_train_dataframe.rds")

# generate test data frame analogously
m.test <- cbind(m.test.predictors, m.test.labels)
d.test <- as.data.frame(m.test)
colnames(d.test)[785] <- "Y"
d.test$Y <- as.factor(d.test$Y)
saveRDS(d.test, file = "../mnist_dataframes/mnist_test_dataframe.rds")


##################
# Model Training #
##################

## Train Model on train data with ntree=500 (default) ####
library(randomForest)
set.seed(1)
sys.time.seq <- system.time(
    model.rf <- randomForest(x = d.train[, -785], y = d.train[, 785], do.trace = TRUE) 
)[3]

saveRDS(model.rf, file = "../models/model_rf_500trees_60000.rds") 
saveRDS(sys.time.seq, file = "../models/sys_time_seq_model_rf_500trees_60000.rds") 

## Train Model on train data with ntree=50 ####
set.seed(1)
sys.time.seq <- system.time(
    model.rf <- randomForest(x = d.train[, -785], y = d.train[, 785], do.trace = TRUE, ntree = 50) 
)[3]

saveRDS(model.rf, file = "../models/model_rf_50trees_60000.rds") 
saveRDS(sys.time.seq, file = "../models/sys_time_seq_model_rf_50trees_60000.rds") 



##############################################
# Model Training for ML Server Realtime APIs #
##############################################

# Remark: for Realtime APIs you can only use functions of either the RevoScaleR or the MicrosoftML package for model training. 


## Create a formula for a model with a large number of variables:
xnam <- paste0("V", 1:784)
(fmla <- as.formula(paste("Y ~ ", paste(xnam, collapse= "+"))))


# using rxDForest from RevoScaleR: Parallel External Memory Algorithm for Classification and Regression Decision Forests

## Train Model on train data with ntree=50 ####
ntree <- 50 
sys.time.seq <- system.time(
    rxDModelsmall <- rxDForest(formula = fmla, data = d.train, nTree = ntree)
)[3]
# Elapsed time for DForestEstimation: 2712.877 secs.
# Elapsed time for BxDTreeBase: 2718.325 secs.

saveRDS(rxDModelsmall, file = paste0("../models/model_rxDf_",ntree,"trees_60000.rds"))  
saveRDS(sys.time.seq, file = paste0("../models/sys_time_seq_model_rxDf_", ntree,"trees_60000.rds")) 



## Train Model on train data with ntree=500 ####
ntree <- 500 
sys.time.seq <- system.time(
    rxDModellarge <- rxDForest(formula = fmla, data = d.train, nTree = ntree)
)[3]
# Elapsed time for DForestEstimation: 10904.847 secs.
# Elapsed time for BxDTreeBase: 10928.858 secs.
saveRDS(rxDModellarge, file = paste0("../models/model_rxDf_",ntree,"trees_60000.rds")) 
saveRDS(sys.time.seq, file = paste0("../models/sys_time_seq_model_rxDf_", ntree,"trees_60000.rds")) 









