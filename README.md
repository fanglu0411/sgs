# Introduction

SGS, a user-friendly, collaborative and versatile browser for visualizing single-cell and spatial multiomics data. With advanced features for comparative visualization, multi-panel coordiniate view, abundant visualization functions and collaborative exploration, SGS empowers researchers to unlocking the novel insights from scMulti-omics data.
![](https://sgs.bioinfotoolkits.net/document/assets/home-D-OuhsfI.png)

# Document
Instructions, documentation, and tutorials can be found at:
[SGS Website](https://sgs.bioinfotoolkits.net)

# File Format and Conversion
SGS supports various data formats including Anndata, Mudata, and genome-mapped files (GFF, VCF, BED, Bigwig, HiC, Biginteract, Longrange, methylC, Gwas,). The SgsAnnData R package enables seamless data format conversion with analysis tools like Seurat, ArchR, Signac, and Giotto.

## SgsAnnData
The github of SgsAnnData can be access by the following links:
[SgsAnnData gtihub](https://github.com/bio-xtt/SgsAnnDataV2)     


# Installation
SGS primarily utilizes Docker and Flutter technologies to achieve graphical one-click installation. 

> **Make Sure Docker is installed on your server**

## SGS Deployment
SGS supports the following three deployment modes: 
### (1) Client Deployment (**suggest**)
Client deployment requirements users  to download and install the SGS client first. Once the client installation is complete, users can perform SGS deployment on macOS or Linux systems.
Client deployment tutorial: https://sgs.bioinfotoolkits.net/document/installation.html#deploy-a-new-sgs-server

### (2) Install by One-Key Script

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

### (3) Manual Installation

#### Pull images

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

#### Prepare working directory

```sh
sgs_path=/data/docker/vol/sgs

mkdir -r ${sgs_path} && cd ${sgs_path}
mkdir sgs && mkdir api
sudo chmod 777 sgs && sudo chmod 777 api
```

#### Run docker container

##### 1. Setup port params

```sh
DB_PORT=33061
API_PORT=6102
WEB_PORT=1080
```

##### 2. Start sgs-mysql

```sh
docker run --privileged -d \
    --restart=always \
    -v "${sgs_path}/mysql:/var/lib/mysql" \
    --name sgs-mysql \
    -p ${DB_PORT}:3306 \
    -e  MYSQL_ROOT_PASSWORD=${MYSQL_PASSWORD} \
    lufang0411/sgs-mysql:latest
```

##### 3. Start sgs-api

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

##### 4. Start sgs-web (option al if you use `SGS` client).

```sh
docker run -d \
    --restart=always \
    --name sgs-web \
    -p ${WEB_PORT}:80 \
    --link sgs-api \
    -e API_URL=sgs-api:${API_PORT} \
    leeoluo/sgs-web:latest
```

More information please view Document

#  Contact
+ xiatingting (xtt199239@163.com)
+ sunjahe (xxxx@163.com)

# Citiation






