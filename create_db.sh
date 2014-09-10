# FIXME: parameterize
CLIENT=nha
DATA_VOLUME=${CLIENT}_data
DB_CONTAINER=${CLIENT}_db

VOLUME_BASE=$(docker run -d postgres /bin/true)

# Build the data volume and the database server linked to it
docker run --volumes-from $VOLUME_BASE --name $DATA_VOLUME miniscule
docker rm $VOLUME_BASE
docker run -d --name $DB_CONTAINER --volumes-from $DATA_VOLUME postgres

DBHOST=$(docker inspect nha_db | jq -r '.[0].NetworkSettings.IPAddress')

# Wait for the DB to be ready
until psql -h $DBHOST -U postgres -c "SELECT 1" 2> /dev/null
do
    sleep 0.5
done

# Create user
psql -h $DBHOST -U postgres -c "CREATE ROLE nha_user LOGIN PASSWORD 'nha_pass'"
