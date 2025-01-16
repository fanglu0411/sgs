@echo off

@rem ##########################################################################
@rem  usage
@rem  ./deploy-sgs.bat -SERVER_HOST 0.0.0.0 -DB_PORT 33061 -API_PORT 6102 -WEB_PORT 5080 -DATA_PATH C:\Users\Administrator\Documents\sgs-server
@rem  deploy sgs server script start
@rem
@rem ##########################################################################

echo %OS%

:CheckOpts
if "%~1"=="-SERVER_HOST" (set SERVER_HOST=%~2) && shift && shift && goto CheckOpts
if "%~1"=="-DB_PORT" (set DB_PORT=%~2) && shift && shift && goto CheckOpts
if "%~1"=="-API_PORT" (set API_PORT=%~2) && shift && shift && goto CheckOpts
if "%~1"=="-WEB_PORT" (set WEB_PORT=%~2) && shift && shift && goto CheckOpts
if "%~1"=="-DATA_PATH" (set DATA_PATH=%~2) && shift && shift && goto CheckOpts

if "%SERVER_HOST%"=="" set SERVER_HOST=0.0.0.0
if "%DB_PORT%"=="" set DB_PORT=33061
if "%API_PORT%"=="" set API_PORT=6102
if "%WEB_PORT%"=="" set WEB_PORT=5080
if "%DATA_PATH%"=="" set DATA_PATH=%HOMEDRIVE%%HOMEPATH%\Documents\sgs-server
set sgs_path=%DATA_PATH%

set MYSQL_PASSWORD=123456Aa

echo -----------------------------------------------------------------------------------------------
echo SERVER_HOST=%SERVER_HOST%
echo DB_PORT=%DB_PORT%
echo API_PORT=%API_PORT%
echo WEB_PORT=%WEB_PORT%
::echo DATA_PATH=%DATA_PATH%
echo SGS_PATH=%sgs_path%
echo -----------------------------------------------------------------------------------------------

set PRIMARY_REGISTRY=docker.io
set BACKUP_REGISTRY=crpi-d7tubu0e345ls62u.cn-chengdu.personal.cr.aliyuncs.com
set using_docker_repo=%PRIMARY_REGISTRY%

:: Check if the docker command exists
docker --version >nul 2>&1
if %ERRORLEVEL%==0 (
    echo Docker is installed and accessible.
) else (
    echo Docker is not installed or not in the PATH.
    @rem exit /b 1
)

:: Start the Container..

set INSTALL_TYPE=no

@rem docker ps | grep -q "sgs-api" >nul 2>&1
docker ps --filter "name=sgs-api" --filter "status=running" --format "{{.Names}}" | findstr /i "sgs-api" >nul 2>&1
@rem docker ps --filter "name=sgs-api" --filter "status=running" >nul 2>&1

if %errorlevel%==0 (
    goto ChooseReInstallType
) else ( goto ChooseInstallType )

:ChooseInstallType
    set INSTALL_TYPE=install
    goto RunInstallMethod

:ChooseReInstallType
    echo SGS is already installed, what do you want to do?
    echo   0 Do nothing
    echo   1 Re-Install
    echo   2 Update
    echo   3 Re-Start
    echo Do you want to reinstall SGS? Please input your option [0-3]
    set /p i_type=input option:
    ::echo i_type=%i_type%
    if "%i_type%"=="0" set INSTALL_TYPE=no
    if "%i_type%"=="no" set INSTALL_TYPE=no
    if "%i_type%"=="n" set INSTALL_TYPE=no
    if "%i_type%"=="1" set INSTALL_TYPE=install
    if "%i_type%"=="I" set INSTALL_TYPE=install
    if "%i_type%"=="Y" set INSTALL_TYPE=install
    if "%i_type%"=="Yes" set INSTALL_TYPE=install
    if "%i_type%"=="yes" set INSTALL_TYPE=install
    if "%i_type%"=="2" set INSTALL_TYPE=update
    if "%i_type%"=="U" set INSTALL_TYPE=update
    if "%i_type%"=="3" set INSTALL_TYPE=restart
    if "%i_type%"=="S" set INSTALL_TYPE=restart
    if "%i_type%"=="restart" set INSTALL_TYPE=restart
    goto RunInstallMethod


:RunInstallMethod
    echo INSTALL_TYPE=%INSTALL_TYPE%
    @rem 2 update, 1 re-install , 3 restart, 0 nothing
    if "%INSTALL_TYPE%"=="no" goto CheckService
    if "%INSTALL_TYPE%"=="install" goto InstallSGS
    if "%INSTALL_TYPE%"=="update" goto InstallSGS
    if "%INSTALL_TYPE%"=="restart" goto RestartSGS

:RestartSGS
    echo -----------------------------------------------------------------------------------------------
    echo I: restart sgs-mysql
    docker container restart sgs-mysql
    echo I: restart sgs-api
    docker container restart sgs-api
    echo I: restart sgs-web
    docker container restart sgs-web
    echo I: SGS started!
    goto CheckService

:InstallSGS
    :: INSTALL_TYPE = install or update
    echo -----------------------------------------------------------------------------------------------
    if %INSTALL_TYPE%==install (
        echo Install SGS now!
    ) else (
        echo Update sgs now!
    )
    echo I: Stopping container sgs-web
    docker container stop sgs-web
    docker container rm sgs-web
    echo I: Stopping container sgs-api
    docker container stop sgs-api
    docker container rm sgs-api
    echo I: Stopping container sgs-mysql
    docker container stop sgs-mysql
    docker container rm sgs-mysql
    echo -----------------------------------------------------------------------------------------------
    echo I: Pulling image sgs-web
    call :CustomPull leeoluo/sgs-web:latest
    echo I: Pulling image sgs-mysql
    call :CustomPull lufang0411/sgs-mysql:latest
    echo I: Pulling image sgs-api
    call :CustomPull lufang0411/sgs-api:latest
    set mysqlPath=%sgs_path%\mysql
    set apiPath=%sgs_path%\api
    if %INSTALL_TYPE%==install (
        rd /s /q %mysqlPath%\*.*
    )
    if not exist %mysqlPath% ( mkdir %mysqlPath% )
    if not exist %apiPath% ( mkdir %apiPath% )
    echo I: Starting SGS!
    docker network create sgs-network
    echo -----------------------------------------------------------------------------------------------
    echo docker run --privileged -d --restart=always --network=sgs-network -v %mysqlPath%:/var/lib/mysql --name sgs-mysql -p %DB_PORT%:3306 -e MYSQL_ROOT_PASSWORD=%MYSQL_PASSWORD% %using_docker_repo%/lufang0411/sgs-mysql:latest
    docker run --privileged -d --restart=always --network=sgs-network -v %mysqlPath%:/var/lib/mysql --name sgs-mysql -p %DB_PORT%:3306 -e MYSQL_ROOT_PASSWORD=%MYSQL_PASSWORD% %using_docker_repo%/lufang0411/sgs-mysql:latest
    timeout /t 30 >nul
    echo docker run -dit --restart=always --name sgs-api --network=sgs-network -v %apiPath%:/home/sgs/data -p %API_PORT%:6102 -p 6122:22 %using_docker_repo%/lufang0411/sgs-api:latest /docker-entrypoint.sh
    docker run -dit --restart=always --name sgs-api --network=sgs-network -v %apiPath%:/home/sgs/data -p %API_PORT%:6102 -p 6122:22 %using_docker_repo%/lufang0411/sgs-api:latest /docker-entrypoint.sh
    timeout /t 10 >nul
    echo docker run -d  --restart=always --name sgs-web --network=sgs-network -p %WEB_PORT%:80 -e API_URL=sgs-api:%API_PORT% %using_docker_repo%/leeoluo/sgs-web:latest
    docker run -d  --restart=always --name sgs-web --network=sgs-network -p %WEB_PORT%:80 -e API_URL=sgs-api:%API_PORT% %using_docker_repo%/leeoluo/sgs-web:latest
    echo I: SGS started!
    goto CheckService

:CustomPull
    set image_name=%1
    set using_docker_repo=%PRIMARY_REGISTRY%
    echo pull %PRIMARY_REGISTRY%/%image_name%
    docker pull %PRIMARY_REGISTRY%/%image_name%
    if %ERRORLEVEL%==0 (
        echo pull success: %PRIMARY_REGISTRY%/%image_name%
    ) else (
        set using_docker_repo=%BACKUP_REGISTRY%
        docker pull %BACKUP_REGISTRY%/%image_name%
    )
    goto:eof

:CheckService
    @rem sleep 5 seconds
    timeout /t 5 >nul
    echo -----------------------------------------------------------------------------------------------
    call :CheckContainer "sgs-api",http://%SERVER_HOST%:%API_PORT%
    call :CheckContainer "sgs-web",http://%SERVER_HOST%:%WEB_PORT%
    set token_check_times=0
    goto CheckToken

:CheckToken
    echo -----------------------------------------------------------------------------------------------
    echo will check admin token!
    set token_url="http://localhost:%API_PORT%/api/token/admin"
    @rem curl get token resp
    for /f %%i in ('curl -so nul -w %%{http_code} %token_url%') do (
        set check_token_status=%%i
    )
    set /a token_check_times+=1
    echo check token times: %token_check_times%, status: %check_token_status%
    @rem check response
    if "%check_token_status%"=="200" (
        curl %token_url%
        goto EndDeploy
    ) else (
        if %token_check_times% LSS 10 (
            echo checking token ...
            timeout /t 5 >nul
            goto CheckToken
        ) else (
            echo check token out of times %token_check_times%
            goto EndDeploy
        )
    )

@rem the container name or ID you want to check
:CheckContainer
    set CONTAINER_NAME=%~1
    set container_url=%~2
    echo checking %CONTAINER_NAME%
    @rem Check if the container is running
    @rem docker ps --filter "name=%CONTAINER_NAME%" --filter "status=running" >nul 2>&1
    docker ps --filter "name=%CONTAINER_NAME%" --filter "status=running" --format "{{.Names}}" | findstr /i "%CONTAINER_NAME%" >nul 2>&1
    if %ERRORLEVEL%==0 (
        echo The container %CONTAINER_NAME% is running: %container_url%
    ) else (
        echo The container %CONTAINER_NAME% is not running or does not exists.
    )
    goto:eof


:EndDeploy
    echo use: "docker ps" to see your service status
    echo deploy script finish!
    exit /b
