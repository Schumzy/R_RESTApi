#' Predicts the digit based on a gray-scale image
#'
#' @param image A 784 (28x28) length vector with gray-scale values between 0-255.
#'
#' @return The predicted digit.
#' @import randomForest
#' @export
predict_digit_large <- function(image) {

    if (length(image) != 784) {
        stop("wrong image format. Need a 784 vector with values 0-255.")
    }

    #modelsmall available in the package
    prediction <- predict(modellarge, image, type = "response")
    return(as.numeric(as.character(prediction)))
}

#Test
#d.test <- readRDS("C:/Users/vepo/Documents/GitRepo/operationalisierung/mnist_dataframes/mnist_test_dataframe.rds")
#predict_digit_small(d.test[1,-785])
