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


