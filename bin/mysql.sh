#!/bin/bash
IMAGE=mysql:5
NAME=mysql-5
# start server container
docker run --name ${NAME} -e MYSQL_RANDOM_ROOT_PASSWORD=yes --rm -d ${IMAGE}
while :
do
    echo "waiting mysql server is started..."
    ROOT_PASSWORD=$(docker logs ${NAME} 2>/dev/null|sed -n "s/GENERATED ROOT PASSWORD: \(.*\)$/\1/p")
    if [ -n "${ROOT_PASSWORD}" ]; then
	echo ${ROOT_PASSWORD}
	break
    fi
    sleep 1
done
while :
do
    echo "waiting mysql server port is opened..."
    docker run -it --link ${NAME}:server --rm ${IMAGE} sh -c 'exec mysqladmin ping -hserver --silent'
    if [ $? -eq 0 ]; then
	break
    fi
    sleep 1
done
# start client
docker run -it --link ${NAME}:server -e MYSQL_ROOT_PASSWORD=${ROOT_PASSWORD} --rm ${IMAGE} sh -c 'exec mysql -hserver -uroot -p"$MYSQL_ROOT_PASSWORD"'
docker kill ${NAME}
