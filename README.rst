.. Docker Set Up! Yippee!


Quick Summary
=============


Daily Driver
============

Client Image Prep
=================
Update dev.cfg file:
-localhost -> dbhost:5432
-server.socket_port = 6085
-(Pugin can skip this step) custom_code_path = '/brightlink_dev/clarus/<client>

Add client to client_data.yml file:

::
    vim ~/.client_data.yml

Example client data to add:

::
	NERC:
 	docker_image: nerc
 	container: nerc_server
 	db_container: nerc_db
 	db: nerc_data
 	db_user: nerc_user
 	clarus_port: 6085
 	store_settings: nerc.store.local_settings
 	runtests: ~/source/brightlink/runtests.sh

Build client database:

::
	cd docker/client_db
	./build.sh <CAPITALIZED CLIENT>

Fetch database from staging:

::
	cd docker/tools
	./fetch_db.sh <lowercase client>

If it asks for a password, it will ask you twice, and it is the client database
password. If you don't know it, you probably don't work here. :p

Setup database:

::
	psql -h $(sudo docker inspect <lowercase client_db>| jq -r '.[0].NetworkSettings.IPAddress') postgres postgres < <lowercase client_schema.sql>
	pg_restore -h $(sudo docker inspect <lowercase client_db> | jq -r '.[0].NetworkSettings.IPAddress') -U postgres -d <lowercase client_data> <lowercase client_data.pgdump>

Set the client:

::
	,set_client <CAPITALIZED CLIENT>

To see if database is set up do:

::
	,pgcli

Build the client image and start container:
Clarus Clients (except NHA):

::
	cd docker/client_image
	./build.sh <CAPITALIZED CLIENT>
	,dock bt

NHA Special Snowflake:

::
    cd docker/client_image
    env PACKAGES=nha-student-portal ./build.sh NHA
	,dock bt

BrightTrac Clients:

::
	cd docker/brighttrac_image
	./build.sh <CAPITALIZED CLIENT>
	,dock bt

To see all the running images:

::
	docker ps -a

Build the job queue:

::
	,dock_jq


Base Image Prep
===============

System Images
-------------

::

    cd $SOURCE_ROOT/infrastructure/docker

Run the following commands from the directory listed above::

    cd postgres/
    docker build -t postgres --no-cache .

    cd miniscule/
    docker build -t miniscule --no-cache .

    cd pybase/
    docker build -t pybase --no-cache .
    ./build.sh

    cd vol/
    ./build.sh

    cd clarus_base/
    ./build.sh

	cd bt_base/
    ./build.sh


Installation Stuff
==================

Standard layout
---------------

This is important to get all repositories
::

    SOURCE_ROOT=/home/<yourUsername>/source/

    $SOURCE_ROOT/
    ├── brighttrac
    │   ├── adex
    │   ├── cdca
    │   …
    ├── clarus
    │   ├── cidq
    │   ├── clarus
    │   ├── compass
    │   ├── psi_cosmo
    │   ├── envirocert
    │   ├── nasm
    │   ├── nha
    │   ├── nha_student_portal
    │   ├── uppcc
    │   └── wacos
    ├── infrastructure
    │   ├── blauthentication
    │   ├── blbackup
    │   ├── blconfig
    │   ├── blcore
    │   ├── blcrypto
    │   …

::

    cd $SOURCE_ROOT/infrastructure

    for repo in blcore blauthentication blconfig blerrorhandling bllang blnotification blfilter blexcel blscripts blcrypto blintegration blmonitor bltemplates blwebtop utctime satchmo_braintree switchboard template_resolver
    do

        git clone -o upstream git@bitbucket.org:brightlinkinfrastructure/$repo.git

    done

::

    cd $SOURCE_ROOT/clarus

    git clone -o upstream git@bitbucket.org:brightlinkclarus/clarus.git


System Prep
-----------

::

    sudo apt-get install jq libyaml-0-2 postgresql-client-9.5 libpq-dev
	mkvirtualen pgcli
	pip install pgcli
	ln -s `which pgcli` /home/<user>/bin/


Docker Installation
-------------------

https://docs.docker.com/engine/installation/linux/ubuntulinux/
complete steps 1-11 under "Update your apt sources"
Reason for these preliminary steps is to use docker repository to get docker to keep most up to date


On step 7, if you need to determine your Ubuntu version::

    lsb_release -a

Step 11::

    $ apt-cache policy docker-engine
    docker-engine:
     Installed: (none)
     Candidate: 1.11.1-0~trusty
     Version table:
        1.11.1-0~trusty 0
           500 https://apt.dockerproject.org/repo/ ubuntu-trusty/main amd64 Packages
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^

Note: Skip "Ubuntu Precise 12.04 (LTS)" section and jump to "Install"

Verify docker group exists::

    grep docker </etc/group

Step 3 is to add yourself to docker group.::

    $ sudo usermod -aG docker `whoami`

Logout or reboot to trigger that change

Get a whale::

    $ docker run docker/whalesay cowsay Howdy!

Install busybox image next ("-it" says interactive and connect to terminal)::

    $ docker run -it busybox


Account Configuration
---------------------

Step 1 is to download dockerkit (and rename the directory 'docker')::

    cd ~/src/

    mkdir -p infratructure

    cd infrastructure

    git clone https://github.com/drocco007/dockerkit docker

Step 2 is to make sure you have a bin::

    mkdir -p ~/bin

Step 3 (Optional) Set the source root::

    echo 'export SOURCE_ROOT=$HOME/source/' >>~/.bashrc
                                  ^^^^^^^^

Step 4 is to link dockerkit bin to your personal bin directory::

    cd ~/bin

    ln -s $SOURCE_ROOT/infrastructure/docker/bin/* .

Make sure PATH includes ``$HOME/bin``

::

    export PATH=$HOME/bin:$PATH:$BLGIT_ROOT/bin

step 5 is to set the active client

Put in ~/.bash_aliases::

    #
    # set the active client, which adjusts the behavior of certain commands
    # (e.g. ,snapdb)
    #

    ,set_client() {
       if [ -z $1 ];
       then
           echo -n > ~/.client
       else
           echo $1 > ~/.client
       fi
    }

Then::

    ,set_client CLIENT_NAME_YOU_WANT

Check that it worked by runnning::

    cat ~/.client


Download pgcli
--------------
