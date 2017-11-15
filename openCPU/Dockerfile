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

RUN apt-get install -y wget

# Install R package

COPY  digiterEmpty_0.1.0.tar.gz /tmp
COPY  digiterSmall_0.1.3.tar.gz /tmp
COPY  digiterLarge_0.1.1.tar.gz /tmp

RUN wget https://cran.r-project.org/src/contrib/randomForest_4.6-12.tar.gz -P /tmp

RUN  R CMD INSTALL /tmp/randomForest_4.6-12.tar.gz --library=/usr/local/lib/R/site-library
RUN  R CMD INSTALL /tmp/digiterEmpty_0.1.0.tar.gz --library=/usr/local/lib/R/site-library
RUN  R CMD INSTALL /tmp/digiterSmall_0.1.3.tar.gz --library=/usr/local/lib/R/site-library
RUN  R CMD INSTALL /tmp/digiterLarge_0.1.1.tar.gz --library=/usr/local/lib/R/site-library

RUN sed -i 's/\"lattice\"/\"lattice\",\"randomForest\", \"digiterEmpty\", \"digiterSmall\", \"digiterLarge\"/' /etc/opencpu/server.conf

# Apache ports
EXPOSE 80

# Start non-daemonized webserver
CMD apachectl -DFOREGROUND