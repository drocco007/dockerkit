.. Docker Set Up! Yippee!


Quick Summary
=============


Daily Driver
============


Base Image Prep
===============

System Images
-------------

::

    cd $SOURCE_ROOT/infrastructure/dockerkit

Run the following commands from the directory listed above::

    cd postgres/
    docker build -t postgres .

    cd miniscule/
    docker build -t miniscule .

    cd pybase/
    docker build -t pybase .

    cd vol/
    ./build.sh


Installation Stuff
==================

Standard layout
---------------

::

    SOURCE_ROOT=/home/drocco/source/brightlink

    $HOME/src/
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


System Prep
-----------

::

    sudo apt-get install jq libyaml-0-2


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

Step 1 is to download dockerkit::

    cd ~/src/

    mkdir -p infratructure

    cd infrastructure

    git clone https://github.com/drocco007/dockerkit

Step 2 is to make sure you have a bin::

    mkdir -p ~/bin

Step 3 (Optional) Set the source root::

    echo 'export SOURCE_ROOT=$HOME/source/' >>~/.bashrc
                                  ^^^^^^^^

Step 4 is to link dockerkit bin to your personal bin directory::

    cd ~/bin

    ln -s $SOURCE_ROOT/infrastructure/dockerkit/bin/* .

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
