#!/bin/bash

if [[ -z $1 ]]
then
    echo "usage: $0 <client>"
    exit -1
fi

# Make sure client is lower case
CLIENT=${1,,}

TEMP_SCHEMA=$(ssh cloud tempfile -p ${CLIENT} -s _schema.sql)
TEMP_DATA=$(ssh cloud tempfile -p ${CLIENT} -s _data.sql)

# Tables for which we want the schema only
DATA_EXCLUDES=(notification job_queue_history email email_event audit_record eem_keyed_response django_session user_notification visit visit_identity)

# Get the schema
ssh cloud /usr/lib/postgresql/9.3/bin/pg_dump -U ${CLIENT}_user -C -s -f $TEMP_SCHEMA ${CLIENT}_data

# Get the data, excluding the tables in DATA_EXCLUDES
ssh cloud /usr/lib/postgresql/9.3/bin/pg_dump -U ${CLIENT}_user --data-only "${DATA_EXCLUDES[@]/#/-T }" -f $TEMP_DATA ${CLIENT}_data

# Fetch the databases
scp -C "cloud:$TEMP_SCHEMA" ${CLIENT}_schema.sql
scp -C "cloud:$TEMP_DATA" ${CLIENT}_data.sql

# Clean up
ssh cloud rm $TEMP_SCHEMA $TEMP_DATA
