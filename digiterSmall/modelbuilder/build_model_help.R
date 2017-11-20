setwd("~/02_Projekte/00_Operationalisierung/operationalisierung/digiterSmall/modelbuilder")

library(devtools)

modelsmall <- readRDS(file = "../../models/model_rf_50trees_60000.rds")
devtools::use_data(modelsmall, internal = TRUE, overwrite = TRUE) #save modelsmall in sysdata.rda
