#!/bin/bash
IMAGE=${IMAGE:-mysql:5}
NAME=mysql-server
NETWORK=mysql-nw
DATABASE=sandbox
ROOT_PASSWORD=$(docker logs ${NAME} 2>/dev/null|sed -n "s/.*GENERATED ROOT PASSWORD: \(.*\)$/\1/p")
if [ -z "${ROOT_PASSWORD}" ]; then
    echo "cannot detect mysql server" >&2
    exit 1
fi
# start client
docker run --network ${NETWORK} -it --rm ${IMAGE} sh -c "exec mysqldump -h${NAME} -uroot -p${ROOT_PASSWORD} ${DATABASE}"
