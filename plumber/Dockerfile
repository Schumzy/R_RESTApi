# Use builds from launchpad
FROM r-base:3.4.2

#RUN apt-get install -y wget

# Install R package
COPY  digiterEmpty_0.1.0.tar.gz /tmp
COPY  digiterSmall_0.1.2.tar.gz /tmp
COPY  digiterLarge_0.1.0.tar.gz /tmp

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
RUN R CMD INSTALL /tmp/digiterSmall_0.1.2.tar.gz --library=/usr/local/lib/R/site-library 
RUN R CMD INSTALL /tmp/digiterLarge_0.1.0.tar.gz --library=/usr/local/lib/R/site-library
     
#remove the tar.gz-files
RUN rm -rf /tmp/digiterEmpty_0.1.0.tar.gz \
    rm -rf /tmp/digiterSmall_0.1.2.tar.gz \
    rm -rf /tmp/digiterLarge_0.1.0.tar.gz \
    rm -rf /tmp/plumber_0.4.2.tar.gz \
    rm -rf /tmp/randomForest_4.6-12.tar.gz \
    rm -rf /tmp/jsonlite_1.5.tar.gz \
    rm -rf /tmp/R6_2.2.2.tar.gz \
    rm -rf /tmp/httpuv_1.3.5.tar.gz \
    rm -rf /tmp/crayon_1.3.4.tar.gz \
    rm -rf /tmp/Rcpp_0.12.13.tar.gz 

RUN mkdir -p /app/myscripts

# Copy R files into app/myscripts-folder
COPY install_and_runport.R /app/myscripts 
COPY deploy_rf_pkg.R /app/myscripts

# Apache ports
EXPOSE 8080

WORKDIR /app/myscripts
CMD ["Rscript", "install_and_runport.R"]