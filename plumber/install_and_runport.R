# Run this script on SERVER

# load packages
library(plumber)
library(randomForest)
library(jsonlite)
library(digiterEmpty)
library(digiterSmall)
library(digiterLarge)

r <- plumb("deploy_rf_pkg.R")
r$run(port=8080, host='0.0.0.0')

