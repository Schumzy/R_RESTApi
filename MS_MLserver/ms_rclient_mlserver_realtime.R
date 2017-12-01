# Real-time web service

library(mrsdeploy)
library(RevoScaleR)
library(MicrosoftML)

remoteLogin("http://matleo-mlserver.westeurope.cloudapp.azure.com:12800", # insert your vm here (need to use port 12800)
            username = "admin",
            password = "PwF/uOnBo1",
            session = FALSE) 

# you have to fit model using functions of RevoScaleR 
# as described in https://docs.microsoft.com/de-de/machine-learning-server/operationalize/concept-what-are-web-services
# (functions of "normal" R packages not possible)

# There are additional restrictions on the input dataframe format for microsoftml models:
   
# The dataframe must have the *same number of columns* as the formula specified for the model.
# The dataframe must be *in the exact same order* as the formula specified for the model.
# The *columns* must be of the *same data type as the training data*. Type casting is not possible.

# There are two functions available for fitting a random forest: RevoScaleR::rxDForest and MicrosoftML::rxFastForest
# But rxFastForest from MicrosoftML-> only regression or binary classification possible
# so we use rxDForest


############################
# load trained models
############################

rxDModelsmall <- readRDS(file = "../models/model_rxDf_50trees_60000.rds")
rxDModellarge <- readRDS(file = "../models/model_rxDf_500trees_60000.rds")


############################
# prediction local
############################

# generate test data frame 
source("readMNISTintoR.R")
l.mnist <- load_mnist() # a list
m.test <- cbind(l.mnist$test$x$x, l.mnist$test$y)
d.test <- as.data.frame(m.test)
colnames(d.test)[785] <- "Y"
d.test$Y <- as.factor(d.test$Y)

# prediction local
rxPredict(rxDModelsmall, data = d.test[1,-785])  
rxPredict(rxDModellarge, data = d.test[1,-785]) # takes 10 times longer than for model small


############################
# Create Realtime Rest API
############################

realtimeApi_small <- publishService(
    serviceType = "Realtime",
    name = "rxDModelsmall",
    code = NULL,
    model = rxDModelsmall,
    v = "v1.0.0",
    alias = "rxDModelsmallService"
)

realtimeApi_large <- publishService(
    serviceType = "Realtime",
    name = "rxDModellarge",
    code = NULL,
    model = rxDModellarge,
    v = "v1.0.0",
    alias = "rxDModellargeService"
)


##############################################
# Get already created Realtime Rest API
##############################################

realtimeApi_small <- getService("rxDModelsmall", "v1.0.0")
realtimeApi_large <- getService("rxDModellarge", "v1.0.0")


##########################################################
# Post calls to realtime REST API                #
##########################################################

result <- realtimeApi_small$rxDModelsmallService(d.test[1,-785])
str(result) # so the predicted label is accessed via:
result$outputParameters$outputData$Y_Pred

result <- realtimeApi_large$rxDModellargeService(d.test[1,-785])
result$outputParameters$outputData$Y_Pred


##############################################
# list or delete Service
##############################################

listServices() # lists all published web services
deleteService("name", v = "version") # e.g. deleteService("rxDModellarge", v = "v1.0.0")

##########################################################
#         Get Service-specific Swagger File in R         #
##########################################################

# Note: in all calls in Postman need to adjust https:///api with http://matleo-mlserver.westeurope.cloudapp.azure.com:12800/api
# Postman Authorization setup: https://blogs.msdn.microsoft.com/mlserver/2017/02/22/rest-calls-using-postman-for-r-server-o16n-2/

rtSwagger_small <- realtimeApi_small$swagger()
write(rtSwagger_small, "swaggerFiles/swagger_realtime_api_small.json") 

rtSwagger_large <- realtimeApi_large$swagger()
write(rtSwagger_large, "swaggerFiles/swagger_realtime_api_large.json") 


# Share Swagger-based JSON with those who need to consume it, 
# e.g. if you want to send a post request using a REST client like Postman


