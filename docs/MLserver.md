# How to deploy a model on ML Server

UNDER CONSTRUCTION    

As written [here](https://docs.microsoft.com/de-de/machine-learning-server/index), Microsoft Machine Learning Server is a framework for operationalizing Machine Learning Models. It includes a collection of R packages, Python packages, interpreters, and infrastructure for developing and deploying distributed R and Python-based machine learning and data science solutions on a range of platforms across on-premises and cloud configurations.
Microsoft Machine Learning Server used to be called Microsoft R Server (up to Release 9.1.0), and was renamed to ML Server (Release 9.2.1) when support for Python based analytics was added. 


TODO: R Server vs. ML Server terminology definition

## Terminology
If you are a regular R user, you probably always work with the open source distribution of R available at CRAN and have never heard about any other distributions of R. Nevertheless, there are a few other ones available developed by Microsoft.  


There is a nice overview about the different R distributions given [here](https://www.linkedin.com/pulse/microsoft-r-open-source-which-suits-you-best-tathagata-mukhopadhyay/). Short summary:

* **CRAN R**: open source R (runs on memory, so computation time depends on computer hardware)
* **Microsoft R Open**: uses multithreaded Intel Math Kernel Library (MKL) for matrix manipulations
* **Microsoft R Client**: includes proprietary packages with  functions to      
    * enable parallel computing, up to two threads (functions with suffix *rx*, e.g. `rxGlm()` instead of `glm()`) 
    * allow to push the compute context to a remote machine or 
    * publish models to a remote machine to provide inference as a service.
* **Microsoft R Server**: parallel computing (more than two threads) and can process data in multiple data nodes


![overviewRversions](images/overviewRdistributions.png)

The first three distributions are available for free, the last one (R Server) is licensed. 
Note that MS R Server is now included into MS ML Server.


## Setup

If you want to deploy your model on a remote machine using R Server, you need to first do the following setup steps:

### Local machine: Install R Client
In order to publish models trained on your local machine on a remote machine with ML Server installed, you need to install MS R Client on your local machine. You can download it for free [here](https://docs.microsoft.com/en-us/machine-learning-server/r-client/install-on-windows) -> how to install.

You can use MS R Client using your favorite IDE for R. If you want to use it in RStudio, you need to change the R version used in the global options:
Tools -> Global Options -> General -> R Version

![options](images/globoptsetRclient.PNG)



### Remote machine: Install and configure ML Server
#### Install ML server on remote machine
Details on how to install ML Server for various platforms are given [here](https://docs.microsoft.com/en-us/machine-learning-server/install/machine-learning-server-linux-install). Since we used an Azure VM with ML Server already installed, we could skip this step. 

After installing R Server, you still have to do the following setup to actually be able to use it:

#### **Configure ML Server**  
Although R Server is already installed, you still need to configure it to act as a deployment server and host analytic web services before use. There are two possible configurations: One-Box and Enterprise. Details about these two possibilties can be found [here](https://docs.microsoft.com/en-us/machine-learning-server/operationalize/configure-start-for-administrators). We used a One-Box Configuration. 
Details on this configuration can be found  [here](https://docs.microsoft.com/en-us/machine-learning-server/operationalize/configure-machine-learning-server-one-box) for ML Server.  
We did the configuration as follows:

When connected to VM via ssh, run the administration utility using the following shell commands: 

`cd /usr/lib64/microsoft-r/rserver/o16n/9.1.0/Microsoft.RServer.Utils.AdminUtil`  
`sudo dotnet Microsoft.RServer.Utils.AdminUtil.dll`

Then follow the instructions given [here](https://docs.microsoft.com/en-us/machine-learning-server/install/operationalize-r-server-one-box-config) (Section "How to perform a one-box configuration", Number 2.)



#### R-Package installation on ML server
Also, you need to find the library where the packages you need have to be installed. 
Connect to VM and start an R session as administrator:
`sudo R`    
In the R session, use the command `.libPaths()` to find the path to the R library used at runtime during REST API requests: 

![library](images/4_MLserver_library.PNG)

The second is the library which is accessed during API requests. So every package needeed during an API request has to be installed there first (one time only). In our case, we needed the package randomForest, since the prediction was made using predict.randomForest(). You can install the necessary R package into a specified library as follows:

`install.packages("randomForest", lib = "/opt/microsoft/mlserver/9.2.1/runtime/R/library")`

## Web Service Types
MS offers two types of web services on ML Server. A detailed description can be found [here](https://docs.microsoft.com/de-de/machine-learning-server/operationalize/concept-what-are-web-services)

#### Standard Web Service

These web services offer fast execution and scoring of arbitrary Python or R code and models. 
The R code of how to set up our standard web services is given in the file 
 `ms_rclient_mlserver.R`

#### Realtime Web Service



Here you can only use functions of MS's propriety R packages to fit models. [Here](https://blogs.msdn.microsoft.com/mlserver/2017/10/15/1-million-predictionssec-with-machine-learning-server-web-service/) it says that "Realtime web services offer lower latency to produce results faster and score more models in parallel. The improved performance boost comes from the fact that these web services do not depend on an interpreter at consumption time even though the services use the objects created by the model. Therefore, fewer additional resources and less time is spent spinning up a session for each call. Additionally, the model is only loaded once in the compute node and can be scored multiple times."

see file `ms_rclient_mlserver_realtime.R`

These services are available for Linux only since ML Server 9.2.1. For Windows they have been available longer, since R Server 9.1.0.


## Swagger Files and Postman call

Infos to R-Server Directory on VM    
/usr/lib64/microsoft-r/rserver/o16n/9.1.0/rserve
/Rserv.conf: Configuration of R Server, executed when starting R Server (set working directory, encoding, source RScripts/source.R)
/RScripts/source.R: Configuration of R before starting server (vi source.R)
/workdir/Rserv9.1.0 contains the temporary libraries (one per connection)
This is not the same as “normal” R library:
usr/lib64/microsoft-r/3.3/lib64/R/library

Infos about remote execution (remote r session)	    



Infos about R package management in R Server (not very helpful up to now)    
https://docs.microsoft.com/en-us/machine-learning-server/operationalize/configure-manage-r-packages#mrsdeploy

How to do a POST request from Postman:    
Setup Postman as described in 
https://blogs.msdn.microsoft.com/mlserver/2017/02/22/rest-calls-using-postman-for-r-server-o16n-2/
Data frame representation in Json is given at the bottom of:
https://blogs.msdn.microsoft.com/mlserver/2017/02/22/rest-calls-using-postman-for-r-server-o16n-2/


