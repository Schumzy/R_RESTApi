# Install Docker

[Docker](https://www.docker.com/) is available in two editions: Community Edition (CE) and Enterprise Edition (EE). The Docker Community Edition (CE) is ideal for developers and small teams looking to get started with Docker and experimenting with container-based apps. Docker CE has two update channels, **stable** and **edge**:
- **Stable** gives you reliable updates every quarter
- **Edge** gives you new features every month

For our purposes, the stable Docker Community Edition (CE) is used.

### 1. Install Docker
* for [Windows](https://https://store.docker.com/editions/community/docker-ce-desktop-windows)
* for [Mac](https://www.docker.com/docker-mac)

A whale should be popping up in the task bar (and “Docker is running"). By right-click, you have some options. If you have no internet, connection (e.g. WLAN) use a good docking station with LAN cable for internet access.

### 2. Test Docker

* for Windows PowerShell:  `docker run hello-world`

* for Linux in its command-line : `sudo docker run hello-world` for using it as an administrator.

### 3. Create the Docker Image and Run It
For Windows in PowerShell:
a.	Set the directory from the dockerfile by `cd ~\path_to_dockerfile`
b.	`docker build . ` (This gives the image ID as `Successfully built 9f6825b856aa`). So in this example `<image ID>=9f6825b856aa` .
c.	`docker run -p port_number_container:port_number_host_computer --name <new image name> <image ID>` e.g. `docker run -p 80:80 --name testname 9f6825b856aa`

### 4. Run Docker Images from Dockerhub

If there is no path to the Dockerfile, one should use command as follows:

For example, the command for running the Dockerfiles from pythonBenchmark:
```{r}
docker run -p 8003:5000 matleo/pythonbenchmark:baseline
docker run -p 8004:5000 matleo/pythonbenchmark:forest_50
docker run -p 8005:5000 matleo/pythonbenchmark:forest_500
```

> ### :information_source: Command 3. c.
> If the docker image should run in the back, one should add "-d", e.g. `docker run -d -p 80:80 --name testname 9f6825b856aa`


### 5. Get into Docker Container

For running the R code directly in the docker container, one should make the following commands in the PowerShell:
a. `docker exec -it <container ID> bash`
b. `apt-get update`

The commands `apt-get install libcurl4-openssl-dev` and `apt-get install libssl-dev`
could be relevant, if one would make the GET/POST request in R with the R package "httr".

> ### :information_source: On the Linux Virtual Machine
> Same procedure as in Windows except that you have to put a "sudo" before every docker command for using it as an administrator!
