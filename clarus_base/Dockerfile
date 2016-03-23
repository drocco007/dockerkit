FROM pybase
MAINTAINER drocco@thebrightlink.com

RUN mkdir /brightlink_dev /src
RUN chown docker.docker /brightlink_dev /src

USER docker
ENV HOME /home/docker

RUN mkdir /home/docker/.cache

# tweak user startup
RUN echo ". /home/docker/docker_env/bin/activate" >> /home/docker/.bashrc
RUN echo "cd /brightlink_dev" >> /home/docker/.bashrc


# create the virtualenv
RUN virtualenv /home/docker/docker_env


CMD ["/bin/bash"]
