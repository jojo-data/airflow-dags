#! /bin/bash

# Any subsequent commands which fail will cause the shell script to exit immediately
set -e

image_tag="mendata-airflow-celery:2.1.2-python3.8"

# build airflow image if not exists
if [ "$(docker image inspect $image_tag 2> /dev/null)" = [] ]; then
    # build image
    docker build . -t $image_tag
fi

# run docker-compose (spin up airflow webservers, schedulers, workers and flowers)
docker-compose up -d

# import local variables and connections
sh import-variable-and-conn.sh