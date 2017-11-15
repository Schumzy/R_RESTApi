## CLIENT side

library(jsonlite)
library(httr)

## input: data frame with one observation with 784 = 28x28 values between 0 and 255 (= 1 image, without label)
## translates data frame to JSON, sends a POST request to REST Api where a prediction of the label of this digit is made
## output: predicted label of the image
## Error handling für NAs: Falls data.frame NAs hat, gibt in predict.randomForest() error

post.df.to.server <- function(data.frame, url){
    json <- toJSON(data.frame)
    res <- POST(url = url, body = json, verbose(), accept_json()) 
    return(content(res))
}

# Testing
obs <- 1

#d.test <- readRDS("/mnist_dataframes/mnist_test_dataframe.rds")
d.test <- readRDS("C:/Users/vepo/Documents/GitRepo/operationalisierung/mnist_dataframes/mnist_test_dataframe.rds")
test <- as.numeric(d.test[obs, -785])

## post request to localhost ####
# on laptop
GET("localhost:8080/test", verbose())
post.df.to.server(d.test[obs,-785], "localhost:8080/predictemptypkg")
post.df.to.server(d.test[obs,-785], "localhost:8080/predictsmallpkg")
post.df.to.server(d.test[obs,-785], "localhost:8080/predictlargepkg")


# on VM
post.df.to.server(d.test[obs,-785], "localhost:8080/predictemptypkg")
post.df.to.server(d.test[obs,-785], "localhost:8080/predictsmallpkg")
post.df.to.server(d.test[obs,-785], "localhost:8080/predictlargepkg")

## post request from laptop to Azure VM ####
GET("lin-op-vm.westeurope.cloudapp.azure.com:8080/test", verbose())
post.df.to.server(d.test[obs,-785], "lin-op-vm.westeurope.cloudapp.azure.com:8080/predictemptypkg")
post.df.to.server(d.test[obs,-785], "lin-op-vm.westeurope.cloudapp.azure.com:8080/predictsmallpkg")
post.df.to.server(d.test[obs,-785], "lin-op-vm.westeurope.cloudapp.azure.com:8080/predictlargepkg")
#without data.frame
post.df.to.server(test, "lin-op-vm.westeurope.cloudapp.azure.com:8080/predictemptypkg")
post.df.to.server(test, "lin-op-vm.westeurope.cloudapp.azure.com:8080/predictsmallpkg")
post.df.to.server(test, "lin-op-vm.westeurope.cloudapp.azure.com:8080/predictlargepkg")
