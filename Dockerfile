FROM andrewosh/binder-base

MAINTAINER Omar Zapata <Omar.Zapata@cern.ch>

USER root

# Install ROOT prerequisites
RUN apt-get update
### Core
RUN apt-get -y install git cmake gcc g++ gfortran doxygen
### X libraries
RUN apt-get -y install libx11-dev libxext-dev libxft-dev libxpm-dev
### Python
RUN apt-get -y install python-dev python-numpy-dev python-pip python-scipy python-matplotlib
### Python installed with pip
RUN pip install metakernel scipy matplotlib
### Math libraries
RUN apt-get -y install libgsl0-dev
### Other libraries
RUN apt-get -y install libxml2-dev
### ROOT-R prerequisites
RUN apt-get -y install r-base-dev

RUN R Rscript -e "install.packages('drat', repos='http://cran.rstudio.com')"
RUN R Rscript -e "drat:::add('RcppCore')"
RUN R Rscript -e "install.packages(c('Rcpp'),repos='http://rcppcore.github.io/drat/')"


# Install (R TMVA) packages
# NOTES:
# C50:  Decision trees and rule-based models
# RSNNS: R Stuttgart Neural Network Simulator
# xgboost: Extreme Gradient Boosting
# e1071: For Support Vector Machine
RUN R Rscript -e "install.packages(c('RInside','C50','RSNNS','xgboost','e1071'),repos='http://cran.cnr.Berkeley.edu')"

# Install (Python TMVA) packages
RUN pip install scikit-learn

# Download and install ROOT master
WORKDIR /opt
RUN wget http://files.oproject.org/root_v6.07.07.Linux-unknown-gcc4.9.relwithdebinfo.tar.gz
RUN tar -xzvf root_v6.07.07.Linux-unknown-gcc4.9.relwithdebinfo.tar.gz

USER main

WORKDIR /home/main

# Set ROOT environment
ENV ROOTSYS         "/opt/root"
ENV PATH            "$ROOTSYS/bin:$ROOTSYS/bin/bin:$PATH"
ENV LD_LIBRARY_PATH "$ROOTSYS/lib:$LD_LIBRARY_PATH"
ENV PYTHONPATH      "$ROOTSYS/lib:$PYTHONPATH"

# Set ROOT environment for ROOT-R
ENV ROOT_INCLUDE_PATH "/usr/share/R/include:/usr/local/lib/R/site-library/Rcpp/include/:/usr/local/lib/R/site-library/RInside/include/"
ENV LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/usr/lib/R/lib:/usr/local/lib/R/site-library/Rcpp/libs/:/usr/local/lib/R/site-library/RInside/lib/"


# Customise the JupyROOT environment
RUN mkdir -p $HOME/.ipython/kernels $HOME/.ipython/profile_default/static
RUN cp -r $ROOTSYS/etc/notebook/kernels/root $HOME/.ipython/kernels
RUN cp -r $ROOTSYS/etc/notebook/custom       $HOME/.ipython/profile_default/static
