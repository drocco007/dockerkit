FROM ubuntu:trusty
MAINTAINER drocco@gmail.com

ARG UID=1000
ARG GID=1000

# system packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    libffi-dev \
    libjpeg-dev \
    libpq-dev \
    libxml2-dev \
    libxslt-dev \
    libz-dev \
    ntp \
    python-pip \
    python-dev \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*


RUN pip install -U setuptools virtualenv


# allow PIL to find 64-bit libs
RUN ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib
RUN ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib


# without this cElementTree will not build on trusty
RUN echo '#define HAVE_MEMMOVE 1' >> /usr/include/python2.7/pyconfig.h


# add a docker group
RUN addgroup \
    --gid ${GID} \
    docker


# add a docker user
RUN adduser \
    --uid ${UID} \
    --gid ${GID} \
    --gecos 'Normal Docker (non-root) user' \
    --home /home/docker \
    --disabled-password \
    docker


# generate en_US.utf8 locale
RUN locale-gen "en_US.UTF-8"
RUN dpkg-reconfigure locales
