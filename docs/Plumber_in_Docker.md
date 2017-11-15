# [Plumber](https://www.rplumber.io/) in [Docker](https://www.docker.com/)

## Requirenments
* Installed [R](https://cran.r-project.org/) and integrated development environment (IDE) for R like [RStudio](https://www.rstudio.com/).
* You have some code, data and trained models which should be available over a REST service.
* Optional: Python and Anaconda to make requests.

## 1. Install Docker: 

This can be seen in the docs in *Install_Docker.md* in detail.

## 2. Make own R-Packages

If the code which should be available through the GET/POST requests uses many self-coded functions, it is recommended that one should save them within a created R package. How a R package is created is shown in *Create_RPackage.md*.

## 3. Structure of plumber

[Plumber](https://cran.r-project.org/web/packages/plumber/plumber.pdf) is an R package with is free available. Plumber is hosted on CRAN, so you can download and install the latest stable version and all of its dependencies by running in R:

```{r}
install.packages("plumber")
library(plumber)
```
> ### :information_source: Package plumber (version 0.4.2)
> The package plumber (version 0.4.2) depends on R (>= 3.0.0) and imports R6 (>= 2.0.0), stringi (>= 0.3.0), jsonlite (>= 0.9.16), httpuv (>= 1.2.3) and crayon (1.3.4).

For using plumber as REST API service, one have to use the following structure:
1. There should be one R script which deploys some functions with plumber. We call it *deploy_rf_pkg.R*. It has to look like this

* for GET 
```{r}
#* @get /predict
function.get<- function(){
    return( "Hello, Test" )
}
```
* for POST 
```{r}
#* @post /predictsmallpkg
function.post <- function(req){
    json <- req$postBody # access the json directly
    list <- fromJSON(json)
    result <- make_something(list)
    return(as.numeric(as.character(result))) #returns a numeric value
}
```

Our example can be found in *../plumber/deploy_rf_pkg.R* .

2. There should be one R script which install the needed R packages and run the script *deploy_rf_pkg.R* on the server. We call this script *install_and_runport.R*

```{r}
# load packages
library(plumber)
library(...)

r <- plumb("deploy_rf_pkg.R")
r$run(port=8080, host='0.0.0.0')
```
To use the R script in a Docker container one have to state `host='0.0.0.0'`. Our example can be found in *../plumber/install_and_runport.R* .

## 4. Make Dockerfile

For Windows:
- Search for an [r-base image](https://hub.docker.com/_/r-base/) on Docker Hub
- Create a Dockerfile (by using in PowerShell: `New-Item ~\plumber\Dockerfile –type file`).
- Type the commands in this file as follows (lines beginning with # are comments):

a.	Always begin with `FROM Ubuntu: <version>`
```{r}
# Use builds from launchpad
FROM r-base:3.4.2
```

b.	Copy your own R-packages:
```{r}
# Install R package
COPY  digiterEmpty_0.1.0.tar.gz /tmp
COPY  digiterSmall_0.1.0.tar.gz /tmp
COPY  digiterLarge_0.1.0.tar.gz /tmp
``` 

c.	Install all wanted packages
```{r}

RUN wget https://cran.r-project.org/src/contrib/jsonlite_1.5.tar.gz -P /tmp
RUN wget https://cran.r-project.org/src/contrib/plumber_0.4.2.tar.gz -P /tmp
RUN wget https://cran.r-project.org/src/contrib/randomForest_4.6-12.tar.gz -P /tmp 

#Dependencies of plumber:
RUN wget https://cran.r-project.org/src/contrib/R6_2.2.2.tar.gz -P /tmp
RUN wget https://cran.r-project.org/src/contrib/httpuv_1.3.5.tar.gz -P /tmp
RUN wget https://cran.r-project.org/src/contrib/crayon_1.3.4.tar.gz -P /tmp
RUN wget https://cran.r-project.org/src/contrib/Rcpp_0.12.13.tar.gz -P /tmp

RUN R CMD INSTALL /tmp/jsonlite_1.5.tar.gz --library=/usr/local/lib/R/site-library 
RUN R CMD INSTALL /tmp/R6_2.2.2.tar.gz --library=/usr/local/lib/R/site-library 
RUN R CMD INSTALL /tmp/crayon_1.3.4.tar.gz --library=/usr/local/lib/R/site-library 
RUN R CMD INSTALL /tmp/Rcpp_0.12.13.tar.gz --library=/usr/local/lib/R/site-library 
RUN R CMD INSTALL /tmp/httpuv_1.3.5.tar.gz --library=/usr/local/lib/R/site-library 
RUN R CMD INSTALL /tmp/plumber_0.4.2.tar.gz --library=/usr/local/lib/R/site-library 
RUN R CMD INSTALL /tmp/randomForest_4.6-12.tar.gz --library=/usr/local/lib/R/site-library 
RUN R CMD INSTALL /tmp/digiterEmpty_0.1.0.tar.gz --library=/usr/local/lib/R/site-library 
RUN R CMD INSTALL /tmp/digiterSmall_0.1.0.tar.gz --library=/usr/local/lib/R/site-library 
RUN R CMD INSTALL /tmp/digiterLarge_0.1.0.tar.gz --library=/usr/local/lib/R/site-library
```

d. Remove files not needed anymore
```{r}
#remove the tar.gz-files
RUN rm -rf /tmp/digiterEmpty_0.1.0.tar.gz \
    rm -rf /tmp/digiterSmall_0.1.0.tar.gz \
    rm -rf /tmp/digiterLarge_0.1.0.tar.gz \
    rm -rf /tmp/plumber_0.4.2.tar.gz \
    rm -rf /tmp/randomForest_4.6-12.tar.gz \
    rm -rf /tmp/jsonlite_1.5.tar.gz \
    rm -rf /tmp/R6_2.2.2.tar.gz \
    rm -rf /tmp/httpuv_1.3.5.tar.gz \
    rm -rf /tmp/crayon_1.3.4.tar.gz \
    rm -rf /tmp/Rcpp_0.12.13.tar.gz 
```

e.Make a new direction for R scripts and copy the two essential R scripts into this directory
```{r}
RUN mkdir -p /app/myscripts

# Copy R files into app/myscripts-folder
COPY install_and_runport.R /app/myscripts 
COPY deploy_rf_pkg.R /app/myscripts
```
f. Expose the using port:
```{r}
# Apache ports
EXPOSE 8080
```
Here is the port_number=8080!

> ### :information_source: Port structure
> It is recommended that one uses different ports for different applications!

g.	Set working direction and execute R script *install_and_runport.R*
```{r}
WORKDIR /app/myscripts
CMD ["Rscript", "install_and_runport.R"]
```
The whole example code can be seen in ../plumber/Dockerfile .

## 5. File directories
Put the *.tar.tz files* from the R packages and R scripts *deploy_rf_pkg.R* and *install_and_runport.R* into the same directory as the Dockerfile.

## 6. Create the Docker image 
For Windows in PowerShell:
a.	Set the directory from the dockerfile by `cd ~\plumber`
b.	`docker build . ` (This gives the image ID as `Successfully built 9f6825b856aa`). So in this example `<image ID>=9f6825b856aa` .
c.	`docker run -p port_number_container:port_number_host_computer --name <new image name> <image ID>` e.g. `docker run -p 8080:8080 --name plumber 9f6825b856aa`

> ### :information_source: For Linux
> Same procedure (items 4. - 6.) as in Windows except that you have to put a "sudo" before every docker command for using it as an administrator!

## 7. Make requests

If it stated “Starting server to listen on port 8080”, one can test the port and make GET/POST requests. The status **"200 OK"** means that the request has succeeded. You can make the requests using R directly, using [Postman](https://www.getpostman.com/ ), using Python or some other languages.
The url should look like this:

* Local:
http://localhost:port_number/predictsmallpkg

* On a virtual machine:
http://lin-op-vm.westeurope.cloudapp.azure.com:port_number/predictsmallpkg

Examples for requests can be seen in the repository IndustrialML/mlbenchmark (Python), specially in docs in *Make_Requests.md*, and *../plumber/post_request_to_RESTApi.R* (R).



