# [OpenCPU](https://www.opencpu.org/) in [Docker](https://www.docker.com/)

## Requirenments
* Installed [R](https://cran.r-project.org/) and integrated development environment (IDE) for R like [RStudio](https://www.rstudio.com/) .
* Optional: Python to make requests.

## 1. Install Docker: 

This can be seen in the docs in [*Install_Docker.md*](https://github.com/IndustrialML/R_RESTApi/blob/master/docs/Install_Docker.md) in detail.

## 2. Make own R-Packages

OpenCPU uses R code only in R packages. Therefore, if not common R packages are used, own R packages have to be created. The procedure for this is described in the docs in [*Create_Rpackage.md*](https://github.com/IndustrialML/R_RESTApi/blob/master/docs/Create_RPackage.md).

## 3. Make Dockerfile

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

## 4. File directories
Put the *.tar.tz files* from your own created R packages into the same directory as the Dockerfile.

## 5. Create the Docker image 
For Windows in PowerShell:
a.	Set the directory from the dockerfile by `cd ~\openCPU`
b.	`docker build . ` (This gives the image ID as `Successfully built 9f6825b856aa`. So in this example `<image ID>=9f6825b856aa` .)
c.	`docker run -p port_number_container:port_number_host_computer --name <new image name> <image ID>` e.g. `docker run -p 80:80 --name opencpu 9f6825b856aa`

> ### :information_source: For Linux
> Same procedure (items 3. - 5.) as in Windows except that you have to put a "sudo" before every docker command for using it as an administrator!

## 6. Make requests
If it stated **"OpenCPU cloud server ready"**, one can test the port and make GET/POST requests. The status **"200 OK"** means that the request has succeeded. You can make the requests using R directly, using [Postman](https://www.getpostman.com/ ), using Python or some other languages.
The url should look like this:

* Local:
http://localhost:port_number/ocpu/library/package_name/R/package_function/json

* On a virtual machine:
http://lin-op-vm.westeurope.cloudapp.azure.com:port_number/ocpu/library/package_name/R/package_function/json

Examples for requests can be seen in the repository ["IndustrialML/mlbenchmark"](https://github.com/IndustrialML/mlbenchmark) (Python), specially in docs in [*Make_Requests.md*](https://github.com/IndustrialML/R_RESTApi/blob/master/docs/Make_Requests.md), and [*../openCPU/performenceTest.R*](https://github.com/IndustrialML/R_RESTApi/blob/master/openCPU/performanceTest.R) (R). 

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





