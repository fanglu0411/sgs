## Custom SGS configuration items (optional)
**If you are a developer and want to customize the installation configuration, please read the installation steps below, otherwise it is recommended to use the graphical deployment installation method.**
### Method1: Script Installation
```sh
# Download shell script
wget https://raw.githubusercontent.com/fanglu0411/sgs/main/script/deploy.sh deploy-sgs.sh
# or use curl
curl -fsSL https://raw.githubusercontent.com/fanglu0411/sgs/main/script/deploy.sh -o deploy-sgs.sh

# Change permission
chmod 777 deploy-sgs.sh
# Run install command
./deploy-sgs.sh DB_PORT=33061 API_PORT=6102 WEB_PORT=1080
```

## Method 2: Manual Installation

### Step1: Pull images

- `sgs-mysql` sgs database image
- `sgs-api` sgs api image
- `sgs-web` optional for web app

```sh
sudo docker pull lufang0411/sgs-mysql:latest &&
sudo docker pull lufang0411/sgs-api:latest &&
sudo docker pull leeoluo/sgs-web:latest
```

> If the official docker hub is not available for you, pleas run command below.

```sh
sudo docker pull registry.bioinfotoolkits.net/lufang0411/sgs-mysql:latest &&
sudo docker pull registry.bioinfotoolkits.net/lufang0411/sgs-api:latest &&
sudo docker pull registry.bioinfotoolkits.net/leeoluo/sgs-web:latest
```

### Step2: Prepare working directory

```sh
sgs_path=/data/docker/vol/sgs

mkdir -r ${sgs_path} && cd ${sgs_path}
mkdir sgs && mkdir api
sudo chmod 777 sgs && sudo chmod 777 api
```

### Step3: Run docker container

#### 3.1 Setup port params

```sh
DB_PORT=33061
API_PORT=6102
WEB_PORT=1080
```

#### 3.2 Start sgs-mysql

```sh
docker run --privileged -d \
    --restart=always \
    -v "${sgs_path}/mysql:/var/lib/mysql" \
    --name sgs-mysql \
    -p ${DB_PORT}:3306 \
    -e  MYSQL_ROOT_PASSWORD=${MYSQL_PASSWORD} \
    lufang0411/sgs-mysql:latest
```

#### 3.3 Start sgs-api

```sh
docker run -dit \
    --restart=always \
    --name sgs-api \
    -v "${sgs_path}/api:/home/sgs/data" \
    -p ${API_PORT}:6102 \
    -p 6122:22 \
    --link sgs-mysql \
    lufang0411/sgs-api:latest
```

#### 3.4 Start sgs-web (option al if you use `SGS` client).

```sh
docker run -d \
    --restart=always \
    --name sgs-web \
    -p ${WEB_PORT}:80 \
    --link sgs-api \
    -e API_URL=sgs-api:${API_PORT} \
    leeoluo/sgs-web:latest
```