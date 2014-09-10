FROM pybase
MAINTAINER drocco@thebrightlink.com

RUN mkdir /src
RUN chown docker.docker /src

USER docker
ENV HOME /home/docker

RUN mkdir /home/docker/.cache
RUN echo "export PIP_DOWNLOAD_CACHE=$HOME/.cache/pip" >> /home/docker/.bashrc

# tweak user startup
RUN echo ". /home/docker/docker_env/bin/activate" >> /home/docker/.bashrc
RUN echo "cd /brightlink_dev" >> /home/docker/.bashrc


# create the virtualenv
RUN virtualenv /home/docker/docker_env

# Ports for BT, Satchmo, JQ
EXPOSE 6085 6086 6091

CMD ["/bin/bash"]
