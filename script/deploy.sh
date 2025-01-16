#!/usr/bin/env bash

# usage:
# sudo bash deploy-sgs.sh DATA_PATH="$HOME/docker/vol/sgs" SERVER_HOST=0.0.0.0 DB_PORT=33061 API_PORT=6102 WEB_PORT=5080

SERVER_HOST='0.0.0.0'
DB_PORT=33061
API_PORT=6102
WEB_PORT=5080
DATA_PATH='/data/docker/vol/sgs'

MYSQL_PASSWORD=123456Aa

eval $1
eval $2
eval $3
eval $4
eval $5

echo "SERVER_HOST=${SERVER_HOST}"
echo "DB_PORT=${DB_PORT}"
echo "API_PORT=${API_PORT}"
echo "WEB_PORT=${WEB_PORT}"
echo "DATA_PATH=${DATA_PATH}"

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

container_check(){
    api_exist=`docker inspect --format '{{.State.Running}}' $1`
    if [ "${api_exist}" != "true" ]; then
        echo "$1 start fail!"
    else
        echo "$1 running: $2"
    fi
}

if (! docker --version ); then
    echo "I: Docker not installed, install now!"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
else
    echo "I: Docker already installed!"
fi

# if (! docker-compose --version ); then
#     echo "I: Docker-compose not installed, install now!"
#     sudo curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#     sudo chmod +x /usr/local/bin/docker-compose
# else
#     echo "I: Docker-compose already installed!"
# fi

#Open Docker, only if is not running

if (! docker stats --no-stream );then
    # On Mac OS this would be the terminal command to launch Docker
    if [[ "${machine}" == "Mac" ]];then
        cd
        open /Applications/Docker.app
    else
        systemctl start docker
    fi
    #Wait until Docker daemon is running and has completed initialisation
    while (! docker stats --no-stream ); do
        # Docker takes a few seconds to initialize
        echo "Waiting for Docker to launch..."
        sleep 5
    done
fi


#Start the Container..

echo "I: Docker is ready!"

if (docker ps | grep -q "sgs-api");then
    echo "I: SGS is running!"
    while true
    do
        echo "SGS is already installed, what do you want to do?"
        echo "  1) Re-Install"
        echo "  2) Update"
        echo "  3) Re-Start"
        echo "  4) Do Nothing"

        read -r -p "Do you want to reinstall SGS? Choose your option [ 1 2 3 4 ]:" input
        case $input in
          1|I|Y|Yes) _install=1; break;;
          2|U) _install=2; break;;
          3|S) _install=3; break;;
          4|N|n|No|0|no) _install=0; break;;
          *) echo "Invalid option";;
        esac
    done
else
    _install=1
fi

echo "install = $_install"

sgs_path=$DATA_PATH
#sgs_path="/data/docker/vol/sgs"
#if [[ "${machine}" == "Mac" ]]; then
#    sgs_path="${HOME}/docker/vol/sgs"
#fi
echo "SGS_PATH=$sgs_path"

PRIMARY_REGISTRY="docker.io"  # 主仓库
# BACKUP_REGISTRY="registry.bioinfotoolkits.net:6443"  # 备用仓库
BACKUP_REGISTRY="crpi-d7tubu0e345ls62u.cn-chengdu.personal.cr.aliyuncs.com"  # 备用仓库

using_docker_repo=$PRIMARY_REGISTRY

custom_pull(){
  # 从主仓库拉取
  echo "pull：${PRIMARY_REGISTRY}/$1"
  using_docker_repo=$PRIMARY_REGISTRY
  docker pull "${PRIMARY_REGISTRY}/$1"
  if [ $? -ne 0 ]; then
    echo "fallback pull：${BACKUP_REGISTRY}/$1"
    using_docker_repo=$BACKUP_REGISTRY
    docker pull "${BACKUP_REGISTRY}/$1"
  fi
}

if [[ $_install == 1 || $_install == 2 ]]; then # 2:update, 1:re-install , 3:restart
    echo 'Install SGS now!'
    echo "I: Stopping container sgs-web"
    docker container stop sgs-web && docker container rm -v sgs-web
    echo "I: Stopping container sgs-api"
    docker container stop sgs-api && docker container rm -v sgs-api
    echo "I: Stopping container sgs-mysql"
    docker container stop sgs-mysql && docker container rm -v sgs-mysql

    docker image rm lufang0411/sgs-mysql:latest
    docker image rm "${BACKUP_REGISTRY}/lufang0411/sgs-mysql:latest"

    echo "I: Pulling image sgs-web"
    custom_pull leeoluo/sgs-web:latest

    echo "I: Pulling image sgs-mysql"
    custom_pull lufang0411/sgs-mysql:latest

    echo "I: Pulling image sgs-api"
    custom_pull lufang0411/sgs-api:latest

    mysqlPath="${sgs_path}/mysql"
    apiPath="${sgs_path}/api"

    if [[ ! -d "${apiPath}" ]]; then
      mkdir -p "${apiPath}/"
      chmod 777 "${apiPath}"
    fi

    if [[ $_install -eq 1 ]]; then
      rm -rf "${mysqlPath}/"
    fi

    if [[ ! -d "${mysqlPath}" ]]; then
      mkdir -p "${mysqlPath}/"
      chmod 777 "${mysqlPath}/"
    fi

    echo "I: Starting SGS!"
    docker network create sgs-network

    echo docker run --privileged -d --restart=always -v "${sgs_path}/mysql:/var/lib/mysql" --name sgs-mysql --network=sgs-network -p ${DB_PORT}:3306 -e MYSQL_ROOT_PASSWORD=${MYSQL_PASSWORD} ${using_docker_repo}/lufang0411/sgs-mysql:latest
    docker run --privileged -d \
       --restart=always \
       --name sgs-mysql \
       --network=sgs-network \
       -v "${sgs_path}/mysql:/var/lib/mysql" \
       -p ${DB_PORT}:3306 \
       -e MYSQL_ROOT_HOST=% \
       -e MYSQL_ROOT_PASSWORD=${MYSQL_PASSWORD} \
       ${using_docker_repo}/lufang0411/sgs-mysql:latest

    sleep 120

    docker run -dit \
      --restart=always \
      --name sgs-api \
      --network=sgs-network \
      -v "${sgs_path}/api:/home/sgs/data" \
      -p ${API_PORT}:6102 \
      -p 6122:22 \
      ${using_docker_repo}/lufang0411/sgs-api:latest /docker-entrypoint.sh

    sleep 10

    docker run -d \
      --restart=always \
      --name sgs-web \
      --network=sgs-network \
      -p ${WEB_PORT}:80 \
      -e API_URL=sgs-api:${API_PORT} \
      ${using_docker_repo}/leeoluo/sgs-web:latest

    echo "I: SGS started!"
elif [[ $_install == 3 ]]; then
    echo 'I: restart sgs-mysql'
    sudo docker container restart sgs-mysql
    echo 'I: restart sgs-api'
    sudo docker container restart sgs-api
    echo 'I: restart sgs-web'
    sudo docker container restart sgs-web
    echo "I: SGS started!"
else
    echo "I: SGS already running!"
fi

sleep 3
container_check sgs-api "http://${SERVER_HOST}:${API_PORT}"
container_check sgs-web "http://${SERVER_HOST}:${WEB_PORT}"

api_check_times=1
token_url="http://localhost:${API_PORT}/api/token/admin"
while [ $api_check_times -le 10 ]; do
  echo "try get auth in $api_check_times times: ${token_url}"
  RESPONSE=$(curl --write-out "%{http_code}" --silent --output /dev/null "$token_url")
  if [ "$RESPONSE" -eq 200 ]; then
    curl $token_url
    break;
  else
    if [ $api_check_times -eq 5 ]; then
      echo try restart sgs-mysql and sgs-api
      docker container restart sgs-mysql
      sleep 2
      docker container restart sgs-api
    fi
    api_check_times=$(( api_check_times + 1 ))
    echo 'check token fail! will try in 5 seconds'
    sleep 5
  fi
done
