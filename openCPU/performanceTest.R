library(RCurl)
library(jsonlite)
library(digiterLarge)

#train <- read.csv("modelbuilder/train.csv")
#d.test
train <- readRDS("mnist_dataframes/mnist_test_dataframe.rds")

#function with OpenCPU in docker
get_prediction_from_openCPU <- function(image) {
    
    # for Laptop IP: 
    # json <- postForm("http://172.18.120.211/ocpu/library/digiterLarge/R/predict_digit_large/json",
    #                 .params = list(image=paste('c(', paste(image,collapse = ","), ')', sep = "")))
     json <- postForm("http://localhost:80/ocpu/library/digiterLarge/R/predict_digit_large/json",
                     .params = list(image=paste('c(', paste(image,collapse = ","), ')', sep = "")))
    
    # for VM:
    #json <- postForm("http://lin-op-vm.westeurope.cloudapp.azure.com/ocpu/library/digiterLarge/R/predict_digit_large/json",
    #                 .params = list(image=paste('c(', paste(image,collapse = ","), ')', sep = "")))
    
    as.numeric(fromJSON(json))
    
}

#function for local use
get_prediction_local <- function(image) {
    as.numeric(as.character(predict_digit_large(as.numeric(image))))
}

#test in RStudio
system.time({
    correct <- 0
    n <- 10
    p <- numeric(n)
    for(i in 1:n) {
        p[i] <- get_prediction_local(train[i,-785])
        if(p[i]==train[i,785]) correct <- correct + 1
    }
    p
    correct / n
    }
)

# test with OpenCPU in docker
system.time({
    correct <- 0
    n <- 10
    p <- numeric(n)
    for(i in 1:10) {
        p[i] <- get_prediction_from_openCPU(train[i,-785])
        if(p[i]==train[i,785]) correct <- correct + 1
    }
    p
    correct / n
    }
)
