## SERVER side

# load packages
library(plumber)
library(jsonlite)
library(randomForest)
library(digiterEmpty)
library(digiterSmall)
library(digiterLarge)

#* @post /predictemptypkg
predict.rf <- function(req){
    # access data
    json <- req$postBody # access the json directly
    list <- fromJSON(json)
    prediction <- predict_digit_empty(list)
    return(as.numeric(as.character(prediction)))
}

#* @post /predictsmallpkg
predict.rf <- function(req){
    # access data
    json <- req$postBody # access the json directly
    list <- fromJSON(json)
    prediction <- predict_digit_small(list)
    return(as.numeric(as.character(prediction)))
}

#* @post /predictlargepkg
predict.rf <- function(req){
    # access data
    json <- req$postBody # access the json directly
    list <- fromJSON(json)
    prediction <- predict_digit_large(list)
    return(as.numeric(as.character(prediction)))
}
