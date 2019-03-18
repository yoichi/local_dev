#!/bin/bash
# PostgreSQL playground with the official image on Docker Hub
# https://hub.docker.com/_/postgres
IMAGE=postgres:10
NAME=postgres-10
NETWORK=postgres-nw
ROOT_PASSWORD=$(pwgen -ysBv -N 1)
docker network create ${NETWORK}
# start server container
docker run --network ${NETWORK} --name ${NAME} -e POSTGRES_PASSWORD="${ROOT_PASSWORD}" --rm -d ${IMAGE}
while :
do
    echo "waiting server port is opened..."
    docker run --network ${NETWORK} -it --rm ${IMAGE} sh -c "exec pg_isready -h ${NAME}"
    if [ $? -eq 0 ]; then
        break
    fi
    sleep 1
done
# start client
docker run --network ${NETWORK} -e PGPASSWORD="${ROOT_PASSWORD}" -it --rm ${IMAGE} psql -h ${NAME} -U postgres
docker kill ${NAME}
docker network rm ${NETWORK}
