#!/usr/bin/env pwsh

$SERVER_HOST = '0.0.0.0'
$DB_PORT = 33061
$API_PORT = 6102
$WEB_PORT = 1080
$DATA_PATH = 'C:\\sgs'

$MYSQL_PASSWORD = '123456Aa'

foreach ($arg in $args) {
    if ($arg -match "^(?<key>[^=]+)=(?<value>.+)$") {
        Set-Variable -Name $matches['key'] -Value $matches['value']
    }
}


Write-Host "SERVER_HOST=$SERVER_HOST"
Write-Host "DB_PORT=$DB_PORT"
Write-Host "API_PORT=$API_PORT"
Write-Host "WEB_PORT=$WEB_PORT"
Write-Host "DATA_PATH=$DATA_PATH"


function container_check {
    param (
        [string]$containerName,
        [string]$url
    )
    $api_exist = (docker inspect --format '{{.State.Running}}' $containerName)
    if ($api_exist -ne 'true') {
        Write-Host "$containerName start fail!"
    } else {
        Write-Host "$containerName running: $url"
    }
}

if (-not (docker --version)) {
    Write-Host "I: Docker not installed, please install from https://www.docker.com/products/docker-desktop!"
    exit 0
} else {
    Write-Host "I: Docker already installed!"
}


Write-Host "I: Docker is ready!"

if (docker ps | Select-String -Pattern "sgs-web") {
    Write-Host "I: SGS is running!"
    do {
        $input = Read-Host "SGS is already installed, choose your option [1: Re-Install, 2: Update, 3: Re-Start, N: Exit, n: Exit]"
        switch ($input) {
            '1' { $_install = 1 }
            '2' { $_install = 2 }
            '3' { $_install = 3 }
            'N' { $_install = 0 }
            'n' { $_install = 0 }
            default { Write-Host "Invalid option"; continue }
        }
    } until ($input -match '[123Nn]')
} else {
    $_install = 1
}

Write-Host "install = $_install"

$sgs_path = $DATA_PATH

Write-Host "SGS_PATH=$sgs_path"

if ($_install -eq 1 -or $_install -eq 2) {
    Write-Host 'Install SGS now!'
    Write-Host "I: Stopping container sgs-mysql"
    docker container stop sgs-mysql
    docker container rm -v sgs-mysql
    Write-Host "I: Stopping container sgs-api"
    docker container stop sgs-api
    docker container rm -v sgs-api
    Write-Host "I: Stopping container sgs-web"
    docker container stop sgs-web
    docker container rm -v sgs-web

    Write-Host "I: Pulling image sgs-web"
    docker pull registry.bioinfotoolkits.net/leeoluo/sgs-web:latest

    Write-Host "I: Pulling image sgs-mysql"
    docker pull registry.bioinfotoolkits.net/lufang0411/sgs-mysql:latest

    Write-Host "I: Pulling image sgs-api"
    docker pull registry.bioinfotoolkits.net/lufang0411/sgs-api:latest

    $mysqlPath = "${sgs_path}/mysql"
    $apiPath = "${sgs_path}/api"

    if (-not (Test-Path -Path $apiPath)) { New-Item -ItemType Directory -Path $apiPath }
    icacls $apiPath /grant Everyone:"(OI)(CI)F"

    if ($_install -eq 1) { Remove-Item -Recurse -Force $mysqlPath }
    if (-not (Test-Path -Path $mysqlPath)) { New-Item -ItemType Directory -Path $mysqlPath }
    icacls $mysqlPath /grant Everyone:"(OI)(CI)F"

    Write-Host "I: Starting SGS!"
    docker run -d `
        --restart=always `
        -v "${sgs_path}/mysql:/var/lib/mysql" `
        --name sgs-mysql `
        -p ${DB_PORT}:3306 `
        -e MYSQL_ROOT_PASSWORD=${MYSQL_PASSWORD} `
        registry.bioinfotoolkits.net/lufang0411/sgs-mysql:latest


    docker run -dit `
        --restart=always `
        --name sgs-api `
        -v "${sgs_path}/api:/home/sgs/data" `
        -p ${API_PORT}:6102 `
        -p 6122:22 `
        --link sgs-mysql `
        registry.bioinfotoolkits.net/lufang0411/sgs-api:latest /docker-entrypoint.sh

    docker run -d `
        --restart=always `
        --name sgs-web `
        -p ${WEB_PORT}:80 `
        --link sgs-api `
        -e API_URL="sgs-api:${API_PORT}" `
        registry.bioinfotoolkits.net/leeoluo/sgs-web:latest

    Write-Host "I: SGS started!"
} elseif ($_install -eq 3) {
    Write-Host 'I: Restarting SGS containers'
    docker container restart sgs-mysql
    docker container restart sgs-api
    docker container restart sgs-web
    Write-Host "I: SGS restarted!"
} else {
    Write-Host "I: SGS already running!"
}

Start-Sleep -Seconds 3
container_check "sgs-api" "http://${SERVER_HOST}:${API_PORT}"
container_check "sgs-web" "http://${SERVER_HOST}:${WEB_PORT}"

$api_check_times = 0
$token_url = "http://localhost:$API_PORT/api/token/admin"
while ($api_check_times -le 5) {
    $api_check_times++
    if (Invoke-WebRequest $token_url) {
        break
    }
    Write-Host "check token fail! try later by: curl $token_url"
    Start-Sleep -Seconds 5
}
