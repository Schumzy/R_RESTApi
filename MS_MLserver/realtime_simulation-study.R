#############################################
## on local machine, with RClient installed:
#############################################

library(mrsdeploy)
library(RevoScaleR)
library(MicrosoftML)

####################################
# Connect to server
####################################

remoteLogin("http://lin-mlserver.westeurope.cloudapp.azure.com:12800", 
            username = "admin",
            password = "PwF/uOnBo1",
            session = FALSE) 

####################################
# Read in MNIST Data
####################################

# functions for reading in MNIST data set
source("readMNISTintoR.R")
# read in MNIST data into R
l.mnist <- load_mnist() # a list

# Generate train data frame
m.train <- cbind(l.mnist$train$x$x, l.mnist$train$y)
d.train <- as.data.frame(m.train)
colnames(d.train)[785] <- "Y"
d.train$Y <- as.factor(d.train$Y)

# generate test data frame analogously
m.test <- cbind(l.mnist$test$x$x, l.mnist$test$y)
d.test <- as.data.frame(m.test)
colnames(d.test)[785] <- "Y"
d.test$Y <- as.factor(d.test$Y)


########################################################################
# new train set with binary response to fit models using other rx Functions
########################################################################

d.train.bin <- d.train
d.train.bin$Y <- ifelse(as.numeric(as.character(d.train$Y)) %% 2 == 0 , 0, 1)

########################################################################
# simulation setup
########################################################################


combinations <- cbind(c(8, 78, 784, 784), c(60000, 60000, 60000, 6000))
models <- vector(mode = "list", length = nrow(combinations))
times <- matrix(nrow = nrow(combinations), ncol = 4)
colnames(times) <-  c("time.fit", "time.publish", "mean.time.pred.loc", "mean.time.pred.api")

npred <- 100


############################################################
# revoScaleR functions
############################################################

##############################
# revoScaleR: rxLogit (binary) 
##############################

for(i in 1:nrow(combinations)){
    c <- combinations[i,1]
    n <- combinations[i,2]
    
    cat(combinations[i,])
    
    # sample c columns out of data set (since taking the first few results in cols with only 0's)
    set.seed(1)
    cols <- sort(sample(1:784, size = c))
    
    ## Create a formula for a model with all c variables:
    xnam <- paste0("V", cols)
    (fmla <- as.formula(paste("Y ~ ", paste(xnam, collapse= "+"))))
    
    # fit model 
    time.fit <- system.time(
        model <- rxLogit(formula = fmla, data = d.train.bin[1:n, c(cols, 785)]) 
    )[3]
    models[[i]] <- model
    
    # api generation
    time.publish <- system.time(
        rt_api <- publishService(
            serviceType = "Realtime",
            name = paste0("rxLogit_", n,"obs_",c, "columns"),
            code = NULL,
            model = model,
            v = "v1.0.0",
            alias = "apipredict"
        )
    )[3]
    
    # local 100 predictions
    time.pred.loc <- system.time(
        for(j in 1:npred){
            rxPredict(model, data = d.test[j,cols]) 
        }
    )[3]/npred
    
    # rest call 100 predictions
    time.pred.api <- system.time(
        for(j in 1:npred){
            result <- rt_api$apipredict(d.test[j,cols]) 
        }
    )[3]/npred
  
    # save times
    times[i,] <- c(time.fit, time.publish, time.pred.loc, time.pred.api)
}
times <- cbind(combinations, times)
colnames(times)[1:2] <- c("features", "n")
saveRDS(times, file = paste0("realtime_simulation-study_output/mean_times_rxLogit_fit.rds")) 
saveRDS(models, file = paste0("realtime_simulation-study_output/models_rxLogit_fit.rds"))


##############################
# revoScalR: rxDTree (multiclass) 
##############################

for(i in 1:nrow(combinations)){
    c <- combinations[i,1]
    n <- combinations[i,2]
    
    cat(combinations[i,])
    
    # sample c columns out of data set (since taking the first few results in cols with only 0's)
    set.seed(1)
    cols <- sort(sample(1:784, size = c))
    
    ## Create a formula for a model with all c variables:
    xnam <- paste0("V", cols)
    (fmla <- as.formula(paste("Y ~ ", paste(xnam, collapse= "+"))))
    
    # fit model 
    time.fit <- system.time(
        model <- rxDTree(formula = fmla, data = d.train.bin[1:n, c(cols, 785)]) 
    )[3]
    models[[i]] <- model
    
    # api generation
    time.publish <- system.time(
        rt_api <- publishService(
            serviceType = "Realtime",
            name = paste0("rxDTree_", n,"obs_",c, "columns"),
            code = NULL,
            model = model,
            v = "v1.0.0",
            alias = "apipredict"
        )
    )[3]
    
    # local prediction
    time.pred.loc <- system.time(
        for(j in 1:npred){
            rxPredict(model, data = d.test[j,cols]) 
        }
    )[3]/npred
    
    # rest call prediction
    time.pred.api <- system.time(
        for(j in 1:npred){
            result <- rt_api$apipredict(d.test[j,cols]) 
        }
    )[3]/npred
   
    # save times
    times[i,] <- c(time.fit, time.publish, time.pred.loc, time.pred.api)
}
times <- cbind(combinations, times)
colnames(times)[1:2] <- c("features", "n")
saveRDS(times, file = paste0("realtime_simulation-study_output/mean_times_rxDTree_fit.rds")) 
saveRDS(models, file = paste0("realtime_simulation-study_output/models_rxDTree_fit.rds"))




############################################################
# MicrosoftML functions
############################################################


##############
# bug: 
##############
# bug: rxPredict.mlModel() needs a response column in data set with new observations for which you want to do a prediction
# Conclusion: for now, the MicrosoftML functions cannot be used unless this bug gets fixed.
# Detailed analysis of the bug as follows. First we look at the examples published from MS and why these are working, 
# afterwards we try if we can use a dummy response column (containing NAs) for our data set and see that it is not working. 

## Example 1 from MS -> only working since they use train = test set ####

logitModel <- rxLogisticRegression(isCase ~ age + parity + education + spontaneous + induced,
                                   transforms = list(isCase = case == 1),
                                   data = infert)
# Print a summary of the model
summary(logitModel)

# Score to a data frame
scoreDF <- rxPredict(logitModel, data = infert, 
                     extraVarsToWrite = "isCase")



## Example 2 from MS -> only working because there is a response column ####

testObs <- rnorm(nrow(iris)) > 0
testIris <- iris[testObs,]
trainIris <- iris[!testObs,]

multiLogit <- rxLogisticRegression(
    formula = Species~Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,
    type = "multiClass", data = trainIris)

# Score the model
scoreMultiDF <- rxPredict(multiLogit, data = testIris) # 



## Example with our data ####

c <- 8
cols <- sort(sample(1:784, size = c))

model <- rxLogisticRegression(formula = fmla, data = d.train.bin[, c(cols, 785)]) 

# not working with dummy response column (only NAs)
d.test.dummy.response <- d.test
d.test.dummy.response$Y <- rep(NA, nrow(d.test.dummy.response))
rxPredict(model, data = d.test.dummy.response[1,c(cols, 785)]) 

# only using test = train works, so their prediction function indeed uses the response somehow
rxPredict(model, data = d.train.bin[1,c(cols, 785)])

# conclusion: don't use MicrosoftML functions for model training unless this bug is fixed. 
