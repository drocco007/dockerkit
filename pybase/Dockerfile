FROM ubuntu:trusty
MAINTAINER drocco@gmail.com


# system packages
RUN apt-get update
RUN apt-get install -y python-pip python-dev libjpeg-dev libz-dev libpq-dev
RUN pip install --download-cache /tmp -U pip

RUN pip install --download-cache /tmp -U setuptools virtualenv


# allow PIL to find 64-bit libs
RUN ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib
RUN ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib


# without this cElementTree will not build on trusty
RUN echo '#define HAVE_MEMMOVE 1' >> /usr/include/python2.7/pyconfig.h


# add a docker user
RUN adduser --gecos 'Normal Docker (non-root) user' --home /home/docker --disabled-password docker
