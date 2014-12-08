#!/usr/bin/env bash

CLIENT=envirocert


# derived variables

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PYTHON="/home/docker/docker_env/bin/python"
CONFIG=$DIR/dev.cfg
CUSTOM_SCHEMA=${CLIENT}_brighttrac:$DIR/schema/


# parse options (http://wiki.bash-hackers.org/howto/getopts_tutorial)

while getopts "hcm" opt; do
	case $opt in
		h)
			echo -e "usage: $0 [-c] [-m] [-h]\n"
			echo "    -c  update the core database (default: ${CLIENT})"
			echo "    -m  perform module updates in addition to core/custom"
			echo "    -h  print this help"
			exit 1
			;;
		c)
			CONFIG=$DIR/../brighttrac/dev.cfg
			CUSTOM_SCHEMA=""
			;;
		m)
			INCLUDE_MODULES=1
			;;
	esac
done


# add module updates if requested

SCHEMAS=""
if [ -v INCLUDE_MODULES ]; then
    for i in blcore blauthentication blconfig blerrorhandling bllang blnotification blexcel blrules blfilter bllocking blscripts blcrypto blintegration blmonitor bltemplates ; do
        thing="$i:$DIR/../modules-git/$i/schema/ "
        SCHEMAS+=$thing
    done

    SCHEMAS+="satchmo:$DIR/../packages/forks/satchmo/trunk/schema/"
fi


# engage!

$PYTHON /home/docker/docker_env/bin/update_schemas.py --pdb $CONFIG brighttrac:$DIR/../brighttrac/schema/ $CUSTOM_SCHEMA $SCHEMAS
