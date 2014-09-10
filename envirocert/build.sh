#!/bin/bash

if [[ -z $1 ]]
then
    echo "usage: $0 <ClientName> [client_key]"
    exit -1
fi

BTCLIENT=$1

if [[ -z $2 ]]
then
    # Set CLIENT to BTCLIENT lower cased
    CLIENT=${BTCLIENT,,}
else
    CLIENT=$2
fi

echo $BTCLIENT $CLIENT

# Host environment
SOURCE_ROOT=/home/dan/source/brightlink
PIP_DOWNLOAD_CACHE=$HOME/.cache/pip

# Remove existing image
docker rmi $CLIENT

# Build the temporary container, passing CLIENT and BTCLIENT to the
# container.

docker run -i --name "$CLIENT" \
  -e CLIENT=$CLIENT -e BTCLIENT=$BTCLIENT \
  -v "$SOURCE_ROOT:/brightlink_dev" -v "$PIP_DOWNLOAD_CACHE:/home/docker/.cache/pip" -u docker clarus_base /bin/bash <<'EOF'

export PIP_DOWNLOAD_CACHE=$HOME/.cache/pip
PIP="/home/docker/docker_env/bin/pip install "
PYTHON="/home/docker/docker_env/bin/python"

# Install core and custom
for package in brighttrac $CLIENT ; do
    cd /brightlink_dev/$package
    $PYTHON setup.py develop
    cd -
done

# Symlink needed until we fix custom client loading
mkdir -p /src/clients/$BTCLIENT/
ln -s /brightlink_dev/$CLIENT /src/clients/$BTCLIENT/trunk

EOF


if [[ $? -eq 0 ]]
then
    # Save the temproary container as a new image
    docker commit "$CLIENT" "$CLIENT"

    # Remove the temporary container
    docker rm "$CLIENT"
fi
