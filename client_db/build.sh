#!/bin/bash

if [[ -z $1 ]]
then
    echo "usage: $0 <client_key>"
    exit -1
fi

CLIENT=${1,,}
DATA_VOLUME=${CLIENT}_data
DB_CONTAINER=${CLIENT}_db

echo Building client data containers
echo Data volume container: ${DATA_VOLUME}
echo DBMS server container: ${DB_CONTAINER}


VOLUME_BASE=$(docker run -d postgres /bin/true)

# Build the data volume and the database server linked to it
docker run --volumes-from $VOLUME_BASE --name $DATA_VOLUME miniscule
docker rm $VOLUME_BASE
docker run -d --name $DB_CONTAINER --volumes-from $DATA_VOLUME postgres

DBHOST=$(docker inspect ${CLIENT}_db | jq -r '.[0].NetworkSettings.IPAddress')

# Wait for the DB to be ready
until psql -h $DBHOST -U postgres -c "SELECT 1" 2> /dev/null
do
    sleep 0.5
done

# Create user
psql -h $DBHOST -U postgres -c "CREATE ROLE ${CLIENT}_user LOGIN PASSWORD '${CLIENT}_pass'"
