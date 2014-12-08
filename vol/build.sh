docker rm vollog

docker run -d -v /vol --name vollog miniscule

docker run --rm -it --volumes-from vollog busybox sh -c '/bin/mkdir -p /vol/log/ && chmod -R o+wx /vol'
