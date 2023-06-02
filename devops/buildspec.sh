#!/bin/bash

THE_DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "Build started on $THE_DATE"

appenvsubstr(){
    p_template=$1
    p_destination=$2
    envsubst '$TF_VAR_ENV_APP_NAME' < $p_template \
    | envsubst '$TF_VAR_ENV_APP_ENV_NAME' \
    | envsubst '$TF_VAR_ENV_APP_BACKEND_NAMESPACE' \
    | envsubst '$TF_VAR_ENV_LOCAL_BACKEND_SOURCE_FOLDER' \
    | envsubst '$TF_VAR_ENV_LOCAL_BACKEND_PORT' \
    | envsubst '$TF_VAR_ENV_APP_BACKEND_URL' \
    | envsubst '$TF_VAR_ENV_APP_DATABASE_HOST' \
    | envsubst '$TF_VAR_ENV_APP_DATABASE_NAME' \
    | envsubst '$TF_VAR_ENV_APP_DATABASE_USERNAME' \
    | envsubst '$TF_VAR_ENV_APP_DATABASE_PASSWORD' \
    | envsubst '$TF_VAR_ENV_APP_DATABASE_PORT' \
    | envsubst '$TF_VAR_ENV_APP_NAMESPACE' \
    | envsubst '$TF_VAR_ENV_APP_AWS_ACCOUNT_ID' \
    | envsubst '$TF_VAR_ENV_PHP_REPO_NAME' \
    | envsubst '$TF_VAR_ENV_PHP_REPO_TAG_APACHE' \
    | envsubst '$TF_VAR_ENV_APP_AWS_REGION' \
    | envsubst '$TF_VAR_ENV_PUSHER_APP_KEY' \
    | envsubst '$TF_VAR_ENV_PUSHER_HOST' \
    | envsubst '$TF_VAR_ENV_PUSHER_PORT' \
    | envsubst '$TF_VAR_ENV_PUSHER_SCHEME' \
    | envsubst '$TF_VAR_ENV_PUSHER_APP_CLUSTER' > $p_destination
}

mkdir -p tmp
chmod 777 tmp

appenvsubstr devops/000-default.conf.template tmp/000-default.conf
appenvsubstr devops/dir.conf.template tmp/dir.conf
appenvsubstr devops/apache2.conf.template tmp/apache2.conf
appenvsubstr devops/php.ini.template tmp/php.ini
appenvsubstr devops/appspec.yml.template appspec.yml
appenvsubstr .env.example .env

if [ "$TF_VAR_ENV_SCRIPT_MODE" == "CLOUDOCKER" ] 
then

    appenvsubstr devops/appspec.sh.docker.template devops/appspec.sh
    appenvsubstr devops/Dockerfile.template Dockerfile
    appenvsubstr devops/docker-compose.yml.template docker-compose.yml

else

    appenvsubstr devops/appspec.sh.template devops/appspec.sh

fi


chmod 777 devops/appspec.sh
