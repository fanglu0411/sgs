#!/usr/bin/env bash

SERVER_HOST='0.0.0.0'
DB_PORT=33061
API_PORT=6102
WEB_PORT=1080
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

        read -r -p "Do you want to reinstall SGS? Choose your option [ 1 2 3 ]:" input
        case $input in
          1|I|Y|Yes) _install=1; break;;
          2|U) _install=2; break;;
          3|S) _install=3; break;;
          N|n|No) _install=0; break;;
          *) echo "Invalid option";;
        esac
    done
else
    _install=1
fi

echo "install = $_install"

sgs_path=${DATA_PATH}
#sgs_path="/data/docker/vol/sgs"
#if [[ "${machine}" == "Mac" ]]; then
#    sgs_path="${HOME}/docker/vol/sgs"
#fi
echo "SGS_PATH=$sgs_path"

if [[ $_install == 1 || $_install == 2 ]]; then # 2:update, 1:re-install , 3:restart
    echo 'Install SGS now!'
    echo "I: Stopping container sgs-mysql"
    docker container stop sgs-mysql && docker container rm -v sgs-mysql
    echo "I: Stopping container sgs-api"
    docker container stop sgs-api && docker container rm -v sgs-api
    echo "I: Stopping container sgs-web"
    docker container stop sgs-web && docker container rm -v sgs-web

    echo "I: Pulling image sgs-web"
    docker pull registry.bioinfotoolkits.net/leeoluo/sgs-web:latest

    echo "I: Pulling image sgs-mysql"
    docker pull registry.bioinfotoolkits.net/lufang0411/sgs-mysql:latest

    echo "I: Pulling image sgs-api"
    docker pull registry.bioinfotoolkits.net/lufang0411/sgs-api:latest

    mysqlPath="${sgs_path}/mysql"
    apiPath="${sgs_path}/api"

    [ ! -d "${apiPath}" ] && mkdir -p "${apiPath}/"
    chmod 777 "${apiPath}"

    [ $_install == 1 ] && rm -rf "${mysqlPath}/"
    [ ! -d "${mysqlPath}" ] && mkdir -p "${mysqlPath}/"
    chmod 777 "${mysqlPath}/"

    echo "I: Starting SGS!"
    # docker network create -d bridge sgs-network

    docker run --privileged -d \
       --restart=always \
       -v "${sgs_path}/mysql:/var/lib/mysql" \
       --name sgs-mysql \
       -p ${DB_PORT}:3306 \
       -e  MYSQL_ROOT_PASSWORD=${MYSQL_PASSWORD} \
       registry.bioinfotoolkits.net/lufang0411/sgs-mysql:latest

    docker run -dit \
      --restart=always \
      --name sgs-api \
      -v "${sgs_path}/api:/home/sgs/data" \
      -p ${API_PORT}:6102 \
      -p 6122:22 \
      --link sgs-mysql \
      registry.bioinfotoolkits.net/lufang0411/sgs-api:latest /docker-entrypoint.sh

    docker run -d \
      --restart=always \
      --name sgs-web \
      -p ${WEB_PORT}:80 \
      --link sgs-api \
      -e API_URL=sgs-api:${API_PORT} \
      registry.bioinfotoolkits.net/leeoluo/sgs-web:latest

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

api_check_times=0
token_url="http://localhost:${API_PORT}/api/token/admin"
while [ $api_check_times -le 5 ]; do
  api_check_times=$(( api_check_times++ ))
  if ( curl $token_url );then
    break;
  fi
  echo 'check token fail! try later by: curl' $token_url
  sleep 5
done
