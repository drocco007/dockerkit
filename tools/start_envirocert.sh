#!/bin/bash

shopt -s extglob


IMAGE=envirocert
STORE_PORT=6086


if [ -z "$1" ]
then
    COMMAND=bt
else
    COMMAND=$1
fi


case "$COMMAND" in
    @(bt|brighttrac|server) )

        docker run -d -p 6085:6085 -v /home/dan/source/brightlink:/brightlink_dev -u docker --link envirocert_db:pg --link envirocert_store:store.example.com --volumes-from vollog --name envirocert_server $IMAGE /home/docker/docker_env/bin/python /brightlink_dev/brighttrac/start-brighttrac2.1.py /brightlink_dev/envirocert/dev.cfg
        ;;

    @(shell|tgshell|tg) )

        docker run -it --rm -v /home/dan/source/brightlink:/brightlink_dev -u docker --link envirocert_db:pg --link envirocert_store:store.example.com --volumes-from vollog --name envirocert_shell -w /brightlink_dev/brighttrac $IMAGE /home/docker/docker_env/bin/tg-admin -c ../envirocert/dev.cfg shell
        ;;

    @(store|satchmo) )

        docker run -dt -p 6086:6086 -v /home/dan/source/brightlink:/brightlink_dev -u docker --link envirocert_db:pg --volumes-from vollog --name envirocert_store -w /brightlink_dev/brighttrac $IMAGE /home/docker/docker_env/bin/python /brightlink_dev/brighttrac/brighttrac2/store/manage.py runserver --settings=brighttrac_EnviroCert.store.local_settings 0.0.0.0:$STORE_PORT
        ;;

    @(jq) )

        docker run -d \
            -u docker \
            --link envirocert_db:pg \
            --link envirocert_server:brighttrac.example.com \
            --link envirocert_store:store.example.com \
            -v /home/dan/source/brightlink:/brightlink_dev \
            --volumes-from vollog \
            --name envirocert_job_queue \
            $IMAGE \
            /home/docker/docker_env/bin/python \
                /brightlink_dev/modules-git/blcore/blcore/job_queue/bin/start_job_queue_processor.py /brightlink_dev/envirocert/dev.cfg
        ;;

    * )

        echo "usage: $0 (brighttrac|store|shell|jq)"
        ;;
esac
