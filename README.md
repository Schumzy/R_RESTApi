# R_RESTApi - Inference as a Service in R

This project was set up by Sonja Gassner and Veronica Pohl at Zühlke Engineering AG Schlieren, to gather the option to use a trained R model for production. We looked at the approach **"Inference as a Service"**. This means that the machine learning (ML) model is supposed to be deployed from R and an inference service is supposed to be made available as RESTful API.

## Project structure

The project is split into three sub-projects (three different possibilities to provide inference as a service using R models):  
* [Plumber](https://github.com/IndustrialML/R_RESTApi/tree/master/plumber)
* [OpenCPU](https://github.com/IndustrialML/R_RESTApi/tree/master/openCPU)
* //todo [Mircrosoft Machine Learning Server]()

All sub-projects take the MNIST data set of handwritten digits and train different models by using random forest. 
<img align="right" width="200" height="200" src="docs/images/plot_mnist.jpg">

There are three models involved in the prediction:
* **empty model**: This model does not uses the input data and predicts always the number 0.
* **small model**: This model does use the input data. It was trained with random forest by using 50 trees and 60000 observations.
* **large model**: This model does use the input data. It was trained with random forest by using 500 trees and 60000 observations.

The [docs](https://github.com/IndustrialML/R_RESTApi/tree/master/docs) directory contains detailed information about the three projects. 


The three projects were deployed on an Azure Linux Virtual Machine (VM). Details about the configuration of the VM can be found in the file [Configure_Azure_Linux_VM.md](https://github.com/IndustrialML/R_RESTApi/blob/master/docs/Configure_Azure_Linux_VM.md) in the docs directory.

## Plumber

### Requirements
* Installed [R](https://cran.r-project.org/) (version >= 3.0.0) and integrated development environment (IDE) for R like [RStudio](https://www.rstudio.com/).
* Installed [Docker](https://github.com/IndustrialML/R_RESTApi/blob/master/docs/Install_Docker.md)

### Getting started 
Assuming you have cloned at least the repository ["R_RESTApi"](https://github.com/IndustrialML/R_RESTApi) and installed the above requirements already.

#### 1. Create the Docker image 
For Windows in PowerShell:
1.	Set the directory from the dockerfile by `cd ~\R_RESTApi\plumber`
2.	`docker build . ` (This gives the image ID as `Successfully built 9f6825b856aa`). So in this example `<image ID>=9f6825b856aa` .
3.	`docker run -p 8080:8080 --name plumber 9f6825b856aa` So plumber runs on port 8080!

> ### :information_source: For Linux
> Same procedure as in Windows except that you have to put a "sudo" before every docker command for using it as an administrator!

#### 2. Make requests

If it stated “Starting server to listen on port 8080”, one can test the port and make GET/POST requests. The status **"200 OK"** means that the request has succeeded. You can make the requests using R directly, using [Postman](https://www.getpostman.com/ ), using Python or some other languages.
The url should look like this:

##### Local
* http://localhost:8080/predictemptypkg
* http://localhost:8080/predictsmallpkg
* http://localhost:8080/predictlargepkg

##### On a virtual machine
* http://lin-mlserver.westeurope.cloudapp.azure.com:8080/predictemptypkg
* http://lin-mlserver.westeurope.cloudapp.azure.com:8080/predictsmallpkg
* http://lin-mlserver.westeurope.cloudapp.azure.com:8080/predictlargepkg

Examples for requests can be seen in the repository ["IndustrialML/mlbenchmark"](https://github.com/IndustrialML/mlbenchmark) (Python), specially in docs in [*Make_Requests.md*](https://github.com/IndustrialML/R_RESTApi/blob/master/docs/Make_Requests.md), and [*../plumber/post_request_to_RESTApi.R*](https://github.com/IndustrialML/R_RESTApi/blob/master/plumber/post_request_to_RESTApi.R) (R).

### Inference as a Service

To get started with deploying a ML model from R to made an inference service available as RESTful API, you can follow this workflow:

#### R part

##### 1. Make own R Packages

If the code which should be available through the GET/POST requests uses many self-coded functions, it is recommended that one should save them within a created R package. How a R package is created is shown in [*Create_RPackage.md*](https://github.com/IndustrialML/R_RESTApi/blob/master/docs/Create_RPackage.md).

##### 2. Structure of plumber

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

Our example can be found in [*../plumber/deploy_rf_pkg.R*](https://github.com/IndustrialML/R_RESTApi/blob/master/plumber/deploy_rf_pkg.R).

2. There should be one R script which install the needed R packages and run the script *deploy_rf_pkg.R* on the server. We call this script *install_and_runport.R*

```{r}
# load packages
library(plumber)
library(...)

r <- plumb("deploy_rf_pkg.R")
r$run(port=8080, host='0.0.0.0')
```
To use the R script in a Docker container one have to state `host='0.0.0.0'`. Our example can be found in [*../plumber/install_and_runport.R*](https://github.com/IndustrialML/R_RESTApi/blob/master/plumber/install_and_runport.R) .

#### Docker part
##### 3. Make Dockerfile

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

e. Make a new direction for R scripts and copy the two essential R scripts into this directory
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
The whole example code can be seen in [*../plumber/Dockerfile*](https://github.com/IndustrialML/R_RESTApi/blob/master/plumber/Dockerfile).

##### 4. File directories
Put the *.tar.tz files* from the R packages and R scripts *deploy_rf_pkg.R* and *install_and_runport.R* into the same directory as the Dockerfile.

##### 5. Create the Docker image as shown above in "Get started" and [*Plumber_in_Docker.md*](https://github.com/IndustrialML/R_RESTApi/blob/master/docs/Plumber_in_Docker.md).

##### 6. Make requests as shown above in "Get started" and [*Plumber_in_Docker.md*](https://github.com/IndustrialML/R_RESTApi/blob/master/docs/Plumber_in_Docker.md).

## OpenCPU
### Requirements
* Installed [R](https://cran.r-project.org/) and integrated development environment (IDE) for R like [RStudio](https://www.rstudio.com/).
* Installed [Docker](https://github.com/IndustrialML/R_RESTApi/blob/master/docs/Install_Docker.md)

### Getting started 
Assuming you have cloned at least the repository ["R_RESTApi"](https://github.com/IndustrialML/R_RESTApi) and installed the above requirements already.

#### 1. Create the Docker image 
For Windows in PowerShell:
1.	Set the directory from the dockerfile by `cd ~\R_RESTApi\openCPU`
2.	`docker build . ` (This gives the image ID as `Successfully built 9f6825b856aa`. So in this example `<image ID>=9f6825b856aa` .)
3.  `docker run -p 80:80 --name opencpu 9f6825b856aa` So OpenCPU runs on port 80!

> ### :information_source: For Linux
> Same procedure as in Windows except that you have to put a "sudo" before every docker command for using it as an administrator!

#### 2. Make requests
If it stated **"OpenCPU cloud server ready"**, one can test the port and make GET/POST requests. The status **"200 OK"** means that the request has succeeded. You can make the requests using R directly, using [Postman](https://www.getpostman.com/ ), using Python or some other languages.
The url should look like this:

##### Local
* http://localhost:80/ocpu/library/digiterEmpty/R/predict_digit_empty/json
* http://localhost:80/ocpu/library/digiterSmall/R/predict_digit_small/json
* http://localhost:80/ocpu/library/digiterLarge/R/predict_digit_large/json

##### On a virtual machine
* http://lin-mlserver.westeurope.cloudapp.azure.com:80/ocpu/library/digiterEmpty/R/predict_digit_empty/json
* http://lin-mlserver.westeurope.cloudapp.azure.com:80/ocpu/library/digiterSmall/R/predict_digit_small/json
* http://lin-mlserver.westeurope.cloudapp.azure.com:80/ocpu/library/digiterLarge/R/predict_digit_large/json

Examples for requests can be seen in the repository ["IndustrialML/mlbenchmark"](https://github.com/IndustrialML/mlbenchmark) (Python), specially in [*Make_Requests.md*](https://github.com/IndustrialML/R_RESTApi/blob/master/docs/Make_Requests.md), and [*../openCPU/performenceTest.R*](https://github.com/IndustrialML/R_RESTApi/blob/master/openCPU/performanceTest.R) (R). 

> ### :information_source: Status code
> Other than normally the status code for OpenCPU is **"201"** which means the request has been fulfilled and has resulted in one or more new resources being created. Therefore one should allow this status comming back e.g. in python in [*../test/test_mnist.py*](https://github.com/IndustrialML/mlbenchmark/blob/master/test/test_mnist.py) : 

```python
def call(self, data):
        response = requests.post(self.url,
                                 headers=self.headers,
                                 json=self.preprocess_payload(data)
        )

        if response.status_code == 200 | response.status_code == 201:
            return self.preprocess_response(response)

        else:
            return None
```

### Inference as a Service

To get started with deploying a ML model from R to made an inference service available as RESTful API, you can follow this workflow:

#### R part
##### 1. Make own R-Packages
OpenCPU uses R code only in R packages. Therefore, if not common R packages are used, own R packages have to be created. The procedure for this is described in the docs in [*Create_Rpackage.md*](https://github.com/IndustrialML/R_RESTApi/blob/master/docs/Create_RPackage.md).

#### Docker part
##### 2. Make Dockerfile
For Windows:
- Search for an [Ubuntu image](https://hub.docker.com/_/ubuntu/) on Docker Hub
- Create a Dockerfile (by using in PowerShell: `New-Item ~\openCPU\Dockerfile –type file`).
- Type the commands in this file as follows (lines beginning with # are comments):

a.	Always begin with `FROM Ubuntu: <version>`

```{r}
# Use builds from launchpad
FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN \
  apt-get update && \
  apt-get -y dist-upgrade && \
  apt-get install -y software-properties-common && \
  add-apt-repository -y ppa:opencpu/opencpu-2.0 && \
  apt-get update && \
  apt-get install -y opencpu-server

# Prints apache logs to stdout
RUN \
  ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
  ln -sf /proc/self/fd/1 /var/log/apache2/error.log && \
  ln -sf /proc/self/fd/1 /var/log/opencpu/apache_access.log && \
  ln -sf /proc/self/fd/1 /var/log/opencpu/apache_error.log

# Set opencpu password so that we can login
RUN \
  echo "opencpu:opencpu" | chpasswd
```
b.	If you have to install package from CRAN you should install *wget* as follows:
```{r}
RUN apt-get install -y wget 
```

c.	Copy your own R-packages:
```{r}
# Install R package
COPY  digiterEmpty_0.1.0.tar.gz /tmp
COPY  digiterSmall_0.1.1.tar.gz /tmp
COPY  digiterLarge_0.1.1.tar.gz /tmp
``` 

d.	Install all wanted packages
```{r}
RUN wget https://cran.r-project.org/src/contrib/randomForest_4.6-12.tar.gz -P /tmp

RUN  R CMD INSTALL /tmp/randomForest_4.6-12.tar.gz --library=/usr/local/lib/R/site-library
RUN  R CMD INSTALL /tmp/digiterEmpty_0.1.0.tar.gz --library=/usr/local/lib/R/site-library
RUN  R CMD INSTALL /tmp/digiterSmall_0.1.1.tar.gz --library=/usr/local/lib/R/site-library
RUN  R CMD INSTALL /tmp/digiterLarge_0.1.1.tar.gz --library=/usr/local/lib/R/site-library
e.	Optional: Load packages by building the docker image with:
RUN sed -i 's/\"lattice\"/\"lattice\",\"randomForest\", \"digiterEmpty\", \"digiterSmall\", \"digiterLarge\"/' /etc/opencpu/server.conf
Therefore, the lattice package should be preinstalled int the Ubuntu-image from https://hub.docker.com/_/ubuntu/ .
```

f.	Expose the using port:
```{r}
# Apache ports
EXPOSE 80
```
Here is the port_number=80!

> ### :information_source: Port structure
> It is recommended that one uses different ports for different applications!

g.	End with the command:
```{r}
# Start non-daemonized webserver
CMD apachectl -DFOREGROUND
```
The whole example code can be seen in [*../openCPU/Dockerfile*](https://github.com/IndustrialML/R_RESTApi/blob/master/openCPU/Dockerfile)

##### 3. File directories
Put the *.tar.tz files* from your own created R packages into the same directory as the Dockerfile.

##### 4. Create the Docker image as shown above in "Get started" and [*OpenCPU_in_Docker.md*](https://github.com/IndustrialML/R_RESTApi/blob/master/docs/OpenCPU_in_Docker.md).

##### 5. Make requests as shown above in "Get started" and [*OpenCPU_in_Docker.md*](https://github.com/IndustrialML/R_RESTApi/blob/master/docs/OpenCPU_in_Docker.md).

> ### :information_source: Status code
> Other than normally the status code for OpenCPU is **"201"** which means the request has been fulfilled and has resulted in one or more new resources being created. 

## Mircrosoft Machine Learning Server
### Requirements
//todo

### Getting started 
//todo Assuming you have cloned this repository and installed... 

1. //todo
2. //todo

### Inference as a Service

//todo

## Making Requests
//todo
