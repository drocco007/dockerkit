
        Shell Container  |  BT Container  |  Store Container
                                   ^
                                   |
+----------------------------------------------------------------------+
|                       EnviroCert Dev Image                           |
+-----------------+-----------+------+-------------+-------------------+
|      pybase     |  vollog   |      |  pip cache  |  /brightlink_dev  |
+-----------------+-----------+      +-------------+-------------------+
|  ubuntu:trusty  | miniscule |                    host
+-----------------+-----------+


Required Host System Tools
--------------------------

* docker
* postgresql-client-9.3
* jq

Giving non-root access:

    https://docs.docker.com/installation/ubuntulinux/#giving-non-root-access

Building the Base Images
------------------------

cd postgres/
sudo docker build -t postgres .

cd miniscule/
sudo docker build -t miniscule .

cd pybase/
sudo docker build -t pybase .

cd vol/
sudo ./build.sh

cd nginx
docker build -t clarus_nginx .

cd clarus_base/
<edit build.sh for paths>
sudo ./build.sh


Building a Client
-----------------

cd client_db/
sudo ./build.sh cidq

cd client_image/
<edit build.sh for paths>
sudo ./build.sh CIDQ cidq

tools/fetch_db.sh cidq

psql -h $(sudo docker inspect cidq_db | jq -r '.[0].NetworkSettings.IPAddress') postgres postgres < cidq_schema.sql
pg_restore -h $(sudo docker inspect cidq_db | jq -r '.[0].NetworkSettings.IPAddress') -U postgres -d cidq_data cidq_data.pgdump


Working with Docker
-------------------

Tail server logs::

    while true ; do docker attach --sig-proxy=false cidq_server | grep -E --color 'blcore.events|$' ; sleep 2 ; done


DNS
---

DOCKER0=$(/sbin/ifconfig docker0 | grep "inet addr" | awk '{ print $2}' | cut -d: -f2)

docker run \
    --detach \
    --name dns \
    --publish $DOCKER0:53:53/udp \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    jderusse/dns-gen


Nginx
-----

docker run \
    -d \
    -p 80:80 \
    -p 443:443 \
    -e DOMAIN_NAME=brighttrac.example.com,store.example.com \
    -v /home/drocco/source/brightlink/clarus:/clarus:ro \
    -v /home/drocco/source/brightlink/modules-git/blcore:/blcore:ro \
    -v /home/drocco/source/brightlink/modules-git/blwebtop:/webtop:ro \
    -v /home/drocco/source/brightlink/docker/nginx/certs:/etc/nginx/certs:ro \
    -v /home/drocco/source/brightlink/docker/nginx/vhost.d:/etc/nginx/vhost.d:ro \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    --name nginx \
    jwilder/nginx-proxy

# Change the nginx user's UID to our UID so static content will load
docker exec nginx usermod -u $(id -u) nginx && docker restart -t 0 nginx


Running a Clarus Client
-----------------------

DOCKER0=$(/sbin/ifconfig docker0 | grep "inet addr" | awk '{ print $2}' | cut -d: -f2)
IMAGE=nha
CLARUS_PORT=9085
LOWER_CLIENT=nha


docker run \
    -dit \
    --dns $DOCKER0 \
    -e TERM=screen-256color \
    -p ${CLARUS_PORT}:${CLARUS_PORT} \
    -v /home/drocco/source/brightlink:/brightlink_dev \
    -u docker \
    -e VIRTUAL_HOST=brighttrac.example.com \
    -e VIRTUAL_PORT=${CLARUS_PORT} \
    --volumes-from vollog \
    --name ${LOWER_CLIENT}_server \
    $IMAGE \
    /home/docker/docker_env/bin/python -u /brightlink_dev/brighttrac/start-brighttrac2.1.py /brightlink_dev/${LOWER_CLIENT}/dev.cfg
