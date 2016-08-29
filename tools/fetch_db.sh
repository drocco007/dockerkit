#!/bin/bash

if [[ -z $1 ]]
then
    echo "usage: $0 <client>"
    exit -1
fi

# Make sure client is lower case
CLIENT=${1,,}

TEMP_SCHEMA=$(ssh dockerdev tempfile -p ${CLIENT} -s _schema.sql)
TEMP_DATA=$(ssh dockerdev tempfile -p ${CLIENT} -s _data.pgdump)

# Tables for which we want the schema only
DATA_EXCLUDES=(notification job_queue_history email email_event audit_record eem_keyed_response django_session user_notification visit visit_identity)

# Get the schema
ssh dockerdev /usr/lib/postgresql/9.5/bin/pg_dump -h stagedata.thebrightlink.com -U ${CLIENT}_user -C -s -f $TEMP_SCHEMA ${CLIENT}_data

# Get the data, excluding the tables in DATA_EXCLUDES
ssh dockerdev /usr/lib/postgresql/9.5/bin/pg_dump -h stagedata.thebrightlink.com -U ${CLIENT}_user -F c --data-only "${DATA_EXCLUDES[@]/#/-T }" -f $TEMP_DATA ${CLIENT}_data

# Fetch the databases
scp -C "dockerdev:$TEMP_SCHEMA" ${CLIENT}_schema.sql
scp -C "dockerdev:$TEMP_DATA" ${CLIENT}_data.pgdump

# Clean up
ssh dockerdev rm $TEMP_SCHEMA $TEMP_DATA
