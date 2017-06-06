#!/bin/bash

if [[ -z $1 ]]
then
    echo "usage: $0 <client>"
    exit -1
fi

# Make sure client is lower case
CLIENT=${1,,}

# Tables for which we want the schema only
DATA_EXCLUDES=(notification job_queue_history email email_event audit_record eem_keyed_response django_session user_notification visit visit_identity)

# Remove data files if already existed
echo "It may take a while, go make a coffee..."
rm -f ${CLIENT}_schema.sql
rm -f ${CLIENT}_data.pgdump

# Get the schema
/usr/lib/postgresql/9.5/bin/pg_dump -h stagedata.thebrightlink.com -U ${CLIENT}_user -C -s ${CLIENT}_data > ${CLIENT}_schema.sql

# Get the data, excluding the tables in DATA_EXCLUDES
/usr/lib/postgresql/9.5/bin/pg_dump -h stagedata.thebrightlink.com -U ${CLIENT}_user -F c --data-only "${DATA_EXCLUDES[@]/#/-T }" ${CLIENT}_data > ${CLIENT}_data.pgdump
