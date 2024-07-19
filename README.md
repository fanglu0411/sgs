<a href="https://sgs.bioinfotoolkits.net/document/home.html" target="_blank"><img  align=top src="https://img.shields.io/badge/Document-SGS-%230f91d8?style=flat"/></a>
<a href="https://sgs.bioinfotoolkits.net/home" target="_blank"><img  align=top src="https://img.shields.io/badge/Home-SGS-%23c7e90b?style=flat"/></a>
<a href="https://github.com/bio-xtt/SgsAnnDataV2/tree/main" target="_blank"><img  align=top src="https://img.shields.io/badge/SgsAnnDataV2-SGS-%23e96e0b?style=flat"/></a>
[![163 邮箱](https://img.shields.io/badge/-163%20Mail-FC1F1F?style=plastic&link=mailto:find_onepiece@163.com)](xtt199239@163.com@163.com)
[![WeChat](https://img.shields.io/badge/WeChat-07C160?logo=wechat&logoColor=white)](https://sgs.bioinfotoolkits.net/document/home.html)
[![Docker](https://img.shields.io/badge/docker-20232A?logo=docker&logoColor=61DAFB)](https://blog.i-xiao.space/)
[![GitHub](https://img.shields.io/badge/-GitHub-181717?style=plastic&logo=github)](https://blog.i-xiao.space/)

# SGS: An Integrative Browser for Collaborative Visualization of Single-cell and Spatial Multimodal Data 👋

🎉 SGS, a user-friendly ⚡, collaborative ⚡ and versatile ⚡ browser for visualizing single-cell and spatial multiomics data, including scRNA, spatial transcriptomics, scATAC, scMethylC, sc-eQTL etc. 
With advanced features for comparative visualization, multi-panel coordiniate view, abundant visualization functions and collaborative exploration, SGS empowers researchers to unlocking the novel insights from scMulti-omics data 🎉.

<img src="https://sgs.bioinfotoolkits.net/document/assets/home-D-OuhsfI.png" width="500px" >


# 🚀 Document
Instructions, documentation, and tutorials can be found at:
[SGS Website](https://sgs.bioinfotoolkits.net)

# 💻 File Format and Conversion
+ SGS supports various data formats including Anndata, Mudata, and genome-mapped files (GFF, VCF, BED, Bigwig, HiC, Biginteract, Longrange, methylC, Gwas,). 
+ The SgsAnnData R package enables seamless data format conversion with analysis tools like Seurat, ArchR, Signac, and Giotto. 
+ SgsAnnData can be access by the following links: [SgsAnnData gtihub](https://github.com/bio-xtt/SgsAnnDataV2)     

# ⚙️ Installation
> **Make Sure Docker is installed on your server**
SGS primarily utilizes Docker and Flutter technologies to achieve graphical one-click installation. SGS supports the following three deployment methods:  

## 🎈🎈🎈 Quick Start (recommended）
The SGS browser consists of two main components: the **SGS server** and **SGS client**. Once you have downloaded and installed the SGS client, you need to deploy the SGS server for data visualization. 
> Please note that SGS server deployment currently only supports Linux and MacOS systems!

Client deployment tutorial: https://sgs.bioinfotoolkits.net/document/installation.html#deploy-a-new-sgs-server

## Custom manual installation (optional)
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

# 🌱 Reporting Issues
If you found an issue, please [report it](https://github.com/fanglu0411/sgs/issues) along with any relevant details to reproduce it. Thanks.

# 😊 Contact
+ Yi Wang (yiwang28@swu.edu.cn)    
+ Fang Lu (lufang0411@sina.com)
+ Yongjiang Luo (lyjiang126@yeah.net)
+ Tingting Xia (xtt199239@163.com)
+ Jiahe Sun (sunjiahe0502@email.swu.edu.cn)

# 🌹 Citiation

# 👉 License
SGS Copyright (c) 2024 Wang lab. All rights reserved.
This software is distributed under the MIT License (MIT).
