setwd("~/02_Projekte/00_Operationalisierung/operationalisierung/digiterSmall/modelbuilder")

library(devtools)

modelsmall <- readRDS(file = "../../models/model_rf_500trees_60000.rds")
devtools::use_data(modellarge, internal = TRUE, overwrite = TRUE) #save modellarge in sysdata.rda
