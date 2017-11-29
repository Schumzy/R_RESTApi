#############################################
## on local machine, with RClient installed:
#############################################

library(mrsdeploy)

# login to remote machine
remoteLogin("http://matleo-mlserver.westeurope.cloudapp.azure.com:12800", ## insert your vm here (need to use port 12800)
            username = "admin",
            password = "PwF/uOnBo1",
            session = FALSE) 


# load trained models
modellarge <- readRDS(file = "../models/model_rf_500trees_60000.rds")
modelsmall <- readRDS(file = "../models/model_rf_50trees_60000.rds")


################################################
# create REST Apis for prediction
################################################

#######################
## Empty Model ####
#######################

predictempty <- function(dataframe_transp){
    "0" 
}

api_empty <- publishService(
    "modelEmpty",
    code = predictempty,
    inputs = list(dataframe_transp = "data.frame"),
    outputs = list(label = "numeric"),
    v = "v1.0.0"
)

########################################
## Models with transposed dataframe #### # This was a hack to faciliate the json post call
########################################

# small random Forest model
predictsmall_transp <- function(dataframe_transp){
    library(randomForest)
    mat <- matrix(nrow = 1, ncol = nrow(dataframe_transp))
    dataframe <- as.data.frame(mat)
    dataframe[1,] <- dataframe_transp[,1]
    predict(modelsmall, newdata = dataframe, type = "response")
}

api_small_transp <- publishService( # takes about 1min
    "modelSmall_transp",
    code = predictsmall_transp,
    model = modelsmall,
    inputs = list(dataframe_transp = "data.frame"),
    outputs = list(label = "numeric"),
    v = "v1.0.0"
)

# Large random Forest model -> publishing did not work 
# predictlarge_transp <- function(dataframe_transp){
#     library(randomForest) # necessary!
#     mat <- matrix(nrow = 1, ncol = nrow(dataframe_transp))
#     dataframe <- as.data.frame(mat)
#     dataframe[1,] <- dataframe_transp[,1]
#     predict(modellarge, newdata = dataframe, type = "response") 
# }
# 
# api_large_transp <- publishService( # takes a long time
#     "modelLarge_transp",
#     code = predictlarge_transp,
#     model = modellarge,
#     inputs = list(dataframe_transp = "data.frame"),
#     outputs = list(label = "numeric"),
#     v = "v1.0.0"
# )

####################################
## models with normal dataframe #### # this is the more typical R way, but the json post call is more involved
####################################

# Small random Forest Model
predictsmall <- function(dataframe){
    library(randomForest) # necessary!
    predict(modelsmall, newdata = dataframe, type = "response")
}

api_small <- publishService(
    "modelSmall",
    code = predictsmall,
    model = modelsmall,
    inputs = list(dataframe = "data.frame"),
    outputs = list(label = "numeric"),
    v = "v1.0.0"
)

# Large random Forest Model -> publishing did not work 
# predictlarge <- function(dataframe){
#     library(randomForest) # necessary!
#     predict(modellarge, newdata = dataframe, type = "response") 
# }
# 
# api_large <- publishService( # takes a long time
#     "modelLarge",
#     code = predictlarge,
#     model = modellarge,
#     inputs = list(dataframe = "data.frame"),
#     outputs = list(label = "numeric"),
#     v = "v1.0.0"
# )

# for these APIs, the call in json is a bit more involved, but can be pasted together as follows:
n <- 784
var.nm <- character(n)
for(i in 1:n){
    var.nm[i] <- paste0(" \"V",i,"\"", ":[", 0, "],")
}
cat(var.nm)
var.nm.collapsed <- paste(var.nm, collapse = "")
cat(var.nm.collapsed)
var.nm.collapsed.fin <- substr(var.nm.collapsed, start = 1, stop = nchar(var.nm.collapsed)-1)
cat(var.nm.collapsed.fin)
call <- paste("{", " \"dataframe\":{ ", var.nm.collapsed.fin, "}}")
cat(call) # copy this output to e.g. postman



##############################################
# Get an already created Realtime Rest API Service
##############################################

api_empty <- getService("modelEmpty", "v1.0.0")
api_small_transp <- getService("modelSmall_transp", "v1.0.0")
#api_large_transp <- getService("modelLarge_transp", "v1.0.0")

##########################################################
# Post calls to realtime REST API                #
##########################################################

## generate test data
source("readMNISTintoR.R")
l.mnist <- load_mnist() # a list
m.test <- cbind(l.mnist$test$x$x, l.mnist$test$y)
d.test <- as.data.frame(m.test)
colnames(d.test)[785] <- "Y"
d.test$Y <- as.factor(d.test$Y)


## post calls to REST Apis

# empty model
result <- api_empty$predictempty(dtest[1,-785]) # works since the empty api does not care about input at all
str(result)
result <- api_empty$predictempty(dft)
str(result)


# call for vector aka transposed dataframe
# create one observation in transposed dataframe
(dft <- data.frame(image = as.numeric(dtest[1,-785])))

result <- api_small_transp$predictsmall_transp(dft)
str(result)
result <- api_small_transp$predictsmall_transp(data.frame(image = rep(0,784)))
str(result)


# call for normal dataframe
result <- api_small$predictsmall(dtest[1,-785])
str(result)


##############################################
# list or delete Service
##############################################

listServices() # lists all published web services
deleteService("name", v = "version") # e.g. deleteService("rxDModellarge", v = "v1.0.0")


####################################
## Get Swagger files for Postman ####
####################################
# Note: after importing these swagger files into Postman, you need to replace  
# the url https:///api with http://http://matleo-mlserver.westeurope.cloudapp.azure.com:12800/api in all calls in Postman
# Postman Authorization setup: https://blogs.msdn.microsoft.com/mlserver/2017/02/22/rest-calls-using-postman-for-r-server-o16n-2/

swagger_small <- api_small$swagger()
write(swagger_small, "swaggerFiles/swagger_api_small.json") 
swagger_empty <- api_empty$swagger()
write(swagger_empty, "swaggerFiles/swagger_api_empty.json") 
swagger_small_transp <- api_small_transp$swagger()
write(swagger_small_transp, "swaggerFiles/swagger_api_small_transp.json") 

