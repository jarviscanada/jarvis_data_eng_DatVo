#!/bin/bash

# define vars
cmd=$1
db_username=$2
db_password=$3
usage="./psql_docker.sh start|stop|create [db_username] [db_password]"

# check if docker is running
check_docker_status() {
    sudo systemctl status --no-pager docker || systemctl start docker
}

# check number of args
if [ $# -lt 1 ]; then
    echo "no arguments supplied"
    echo $usage
    exit 1
fi

case $cmd in
# create psql instance
create)
    check_docker_status
    # check if containter created
    if [ "$(docker container ls -a -f name=jrvs-psql | wc -l)" -eq 2 ]; then
        echo "instance already created"
        echo ${usage}
        exit 1
    fi

    # check username and password entered
    if [ -z $db_username ] || [ -z $db_password ]; then
        echo "db_username or db_password not supplied"
        echo ${usage}
        exit 1
    fi

    # create persistant and psql container
    docker volume create pgdata
    docker run --name jrvs-psql -e POSTGRES_PASSWORD=${db_password} -e POSTGRES_USER=${db_username} -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres
    exit $?
    ;;

# start the container
start)
    check_docker_status
    docker container start jrvs-psql
    docker ps -f "name=jrvs-psql"
    exit $?
    ;;

# stop running container
stop)
    check_docker_status
    docker container stop jrvs-psql
    docker ps -a
    exit $?
    ;;

# catch invalid commands
*)
    echo "invalid command"
    echo $usage
    exit 1
    ;;
esac
