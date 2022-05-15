#!/bin/bash
# MySQL playground with the official image on Docker Hub
# https://hub.docker.com/_/mysql
IMAGE=${IMAGE:-mysql:5}
NAME=mysql-server
NETWORK=mysql-nw
DATABASE=sandbox
docker network create ${NETWORK}
# start server container
docker run --network ${NETWORK} --name ${NAME} -e MYSQL_RANDOM_ROOT_PASSWORD=yes --rm -d ${IMAGE}
if [ $? -ne 0 ]; then
    docker network rm ${NETWORK}
    exit 1
fi
while :
do
    echo "waiting mysql server is started..."
    ROOT_PASSWORD=$(docker logs ${NAME} 2>/dev/null|sed -n "s/.*GENERATED ROOT PASSWORD: \(.*\)$/\1/p")
    if [ -n "${ROOT_PASSWORD}" ]; then
	echo ${ROOT_PASSWORD}
	break
    fi
    sleep 1
done
while :
do
    echo "waiting mysql server port is opened..."
    docker run --network ${NETWORK} -it --rm ${IMAGE} sh -c "exec mysqladmin ping -h${NAME} --silent"
    if [ $? -eq 0 ]; then
	break
    fi
    sleep 1
done
# create sandbox database
docker run --network ${NETWORK} -it --rm ${IMAGE} sh -c "exec mysql -h${NAME} -uroot -p${ROOT_PASSWORD} -e \"CREATE DATABASE ${DATABASE}\""
if [ $? -ne 0 ]; then
    echo "error creating database"
fi
# start client
docker run --network ${NETWORK} -it --rm ${IMAGE} sh -c "exec mysql -h${NAME} -uroot -p${ROOT_PASSWORD} ${DATABASE}"
docker kill ${NAME}
docker network rm ${NETWORK}
