# Introduction

SGS, a user-friendly, collaborative and versatile browser for visualizing single-cell and spatial multiomics data. With advanced features for comparative visualization, multi-panel coordiniate view, abundant visualization functions and collaborative exploration, SGS empowers researchers to empowers researchers to unlocking the novel insights from scMulti-omics data.
![](https://sgs.bioinfotoolkits.net/document/assets/home-D-OuhsfI.png)

[Website](https://sgs.bioinfotoolkits.net)

# Features

## Graphical Installation and Collaborative Data Vsiualization

![](https://211.bioinfotoolkits.net:10290/sgs/website/feature_1.png)

SGS offers a user-friendly graphical installation compatible with Linux, Windows, and macOS system. It enables collaborative data visualization and seamless information sharing.

## SG Visualization Modules

![](https://211.bioinfotoolkits.net:10290/sgs/website/feature_2.png)

The SG visualization module provides a unified interface for exploring single-cell and spatial epigenomic multimodal data. Its main features include a novel genomic browser framework for visualizing genome-mapped signals, a flexible layout integrating single cell and genome browser panels, and multi-panel coordinate view capabilities.

## SC Visualization Modules

![](https://211.bioinfotoolkits.net:10290/sgs/website/feature_3.png)

SC visualization mode provides a dynamic interface for exploring high-dimensional datasets, including scRNA, snRNA, and ST data. Its core features include single-cell embedding plot, metadata visualization, comparative visualization of multiple spatial samples or genes, and support for various visualization styles like violin plots, heatmaps, and dot plots.

## Compatible with diverse data formats and mainstrain analytical tools

![](https://211.bioinfotoolkits.net:10290/sgs/website/feature_4.png)

SGS supports various data formats including Anndata, Mudata, and genome-mapped files (GFF, VCF, BED, HiC, Biginteract, Longrange, methylC, Gwas). The SgsAnnData R package enables seamless data format conversion with analysis tools like Seurat, ArchR, Signac, and Giotto.

# Installation

> Make Sure Docker is installed on your server

## Install by one-key script

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

## Manual Install

### Pull images

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

### Prepare working directory

```sh
sgs_path=/data/docker/vol/sgs

mkdir -r ${sgs_path} && cd ${sgs_path}
mkdir sgs && mkdir api
sudo chmod 777 sgs && sudo chmod 777 api
```

### Run docker container

#### 1. Setup port params

```sh
DB_PORT=33061
API_PORT=6102
WEB_PORT=1080
```

#### 2. Start sgs-mysql

```sh
docker run --privileged -d \
    --restart=always \
    -v "${sgs_path}/mysql:/var/lib/mysql" \
    --name sgs-mysql \
    -p ${DB_PORT}:3306 \
    -e  MYSQL_ROOT_PASSWORD=${MYSQL_PASSWORD} \
    lufang0411/sgs-mysql:latest
```

#### 3. Start sgs-api

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

#### 4. Start sgs-web (option al if you use `SGS` client).

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


# Download

