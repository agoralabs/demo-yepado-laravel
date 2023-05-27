#!/bin/bash

THE_DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "Build started on $THE_DATE"

appenvsubstr(){
    p_template=$1
    p_destination=$2
    envsubst '$ENV_APP_NAME' < $p_template \
    | envsubst '$TF_VAR_ENV_APP_NAME' \
    | envsubst '$ENV_APP_ENV_NAME' \
    | envsubst '$TF_VAR_ENV_APP_ENV_NAME' \
    | envsubst '$TF_VAR_ENV_APP_BACKEND_NAMESPACE' \
    | envsubst '$TF_VAR_LOCAL_BACKEND_SOURCE_FOLDER' \
    | envsubst '$TF_VAR_LOCAL_BACKEND_PORT' \
    | envsubst '$ENV_APP_BACKEND_URL' \
    | envsubst '$ENV_APP_DATABASE_HOST' \
    | envsubst '$ENV_APP_DATABASE_NAME' \
    | envsubst '$ENV_APP_DATABASE_USERNAME' \
    | envsubst '$ENV_APP_DATABASE_PASSWORD' \
    | envsubst '$APP_NAMESPACE' \
    | envsubst '$AWS_ACCOUNT_ID' \
    | envsubst '$TF_VAR_ENV_APP_AWS_ACCOUNT_ID' \
    | envsubst '$TF_VAR_PHP_REPO_NAME' \
    | envsubst '$TF_VAR_PHP_REPO_TAG_APACHE' \
    | envsubst '$AWS_REGION' \
    | envsubst '$PUSHER_APP_KEY' \
    | envsubst '$PUSHER_HOST' \
    | envsubst '$PUSHER_PORT' \
    | envsubst '$PUSHER_SCHEME' \
    | envsubst '$PUSHER_APP_CLUSTER' > $p_destination
}

if [ "$SCRIPT_MODE" == "CLOUDOCKER" ] 
then

    appenvsubstr devops/appspec.sh.docker.template devops/appspec.sh
    appenvsubstr devops/appspec.yml.template appspec.yml
    appenvsubstr devops/Dockerfile.template Dockerfile
    appenvsubstr devops/docker-compose.yml.template docker-compose.yml

else

    appenvsubstr devops/000-default.conf.template devops/000-default.conf
    appenvsubstr devops/dir.conf.template devops/dir.conf
    appenvsubstr devops/apache2.conf.template devops/apache2.conf
    appenvsubstr devops/php.ini.template devops/php.ini
    appenvsubstr devops/appspec.yml.template appspec.yml
    appenvsubstr devops/appspec.sh.template devops/appspec.sh
    appenvsubstr .env.example .env

fi


chmod 777 devops/appspec.sh
