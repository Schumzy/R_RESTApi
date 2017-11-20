#' Predicts the digit based on a gray-scale image
#'
#' @param image A 784 (28x28) length vector with gray-scale values between 0-255.
#'
#' @return The predicted digit
#' @import randomForest
#' @export
predict_digit_small <- function(image) {

    if (length(image) != 784 ) { #|| max(image) > 255 || min(image)< 0
        stop("wrong image format. Need a 784 vector with values 0-255.")
    }

    #modelsmall available in the package
    prediction <- predict(modelsmall, image, type = "response")
    return(list(as.numeric(as.character(prediction))))

}

#Test
#d.test <- readRDS("../mnist_dataframes/mnist_test_dataframe.rds")
#predict_digit_small(d.test[1,-785])
