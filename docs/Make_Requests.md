
# Make Requests

There are many opportunities to make requests. In the following three of it are listed to make GET/POST requests for the R code from [R_RESTApi](https://github.com/IndustrialML/R_RESTApi) in [IndustrialML](https://github.com/IndustrialML) on github. 

The most status from a request are:
* **"200 OK"**: The request has succeeded.
* **"201 Created"**: The request has been fulfilled and has resulted in one or more new resources being created. 
* **"400 Bad Request"**: The server cannot or will not process the request due to something that is perceived to be a client error (e.g. malformed request syntax, invalid request message framing, or deceptive request routing).

# 1. R

## Requirenments
* [R](https://cran.r-project.org/) (version >= 3.0.0) 

## Procedure for Running
In R there exists the packages ["httr"](https://cran.r-project.org/web/packages/httr/httr.pdf) and ["RCurl"](https://cran.r-project.org/web/packages/RCurl/RCurl.pdf) which both make GET and POST requests out of R.

Some examples are shown 

* for [plumber](https://www.rplumber.io/) in */plumber/post_request_to_RESTApi.R*
* for [OpenCPU](https://www.opencpu.org/) in */openCPU/performanceTest.R*

Please try them!

# 2. Postman

## Requirenments
* [Postman](https://www.getpostman.com/)

## Procedure for Running

1. Choose between GET and POST.
2. Enter the request url.
3. If you chose a POST request: Click to "Body" and enter your data.
4. If your request need an authorization, specialize an authorization!
5. Click "Send".

Example for POST request with

* **plumber**: In "Body" choose "raw" and enter a 784 (28x28) length vector with gray-scale values between 0-255 such as
 
```{r}
[0, 0, 0, 251, 251, 211, 31, 80, 181, 251, ..., 253, 251, 251, 251, 94, 96, 31, 95, 251, 211, 94, 59]
```
![postman for request with plumber](images/postman_plumber.PNG)

* **OpenCPU**: In "Body" choose "raw", choose "JSON(application/json)" and enter a 784 (28x28) length list with the label "image" and gray-scale values between 0-255 such as
```{r}
{
 "image" :  [0, 0, 0, 251, 251, 211, 31, 80, ..., 251, 251, 251, 94, 96, 31, 95, 251, 211, 94, 59]
}
```
![postman for request with OpenCPU](images/postman_opencpu.PNG)

# 3. Python

## Requirenments
* Python 2, 2.6, 2.7, 3 or 3.3
* Optional: [Anaconda](https://docs.anaconda.com/)

## Code for Running

In Python the code [mlbenchmark](https://github.com/IndustrialML/mlbenchmark) in [IndustrialML](https://github.com/IndustrialML) on github is used. This code makes for every REST API request three scenarios: "Accuracy", "Sequential Load" and "Concurrent Load". The output is a tabular of results. Anaconda promp is used:

1. Set working directory to mlbenchmark folder with `cd ~\mlbenchmark`
2. `pip install -r requirements.txt`
3. `python setup.py develop`
4. `py.test`


> ### @icon-exclamation-circle Change requests
> To change the running REST API requests one have to make changes in* ENVIRONMENTS = [...]* in file  *test/test_mnist.py* ! Besides, one have to choose the right environment for the different tools: "MNistEnvironment" for plumber, "OpencpuMNistEnv" for OpenCPU and "MSRServerMNistEnv" for MS ML Server (in the old days R Server).





