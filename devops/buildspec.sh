#!/bin/bash

THE_DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "Build started on $THE_DATE"

appenvsubstr(){
    p_template=$1
    p_destination=$2
    envsubst '$ENV_APP_NAME' < $p_template \
    | envsubst '$ENV_APP_ENV_NAME' \
    | envsubst '$ENV_APP_BACKEND_URL' \
    | envsubst '$ENV_APP_DATABASE_HOST' \
    | envsubst '$ENV_APP_DATABASE_NAME' \
    | envsubst '$ENV_APP_DATABASE_USERNAME' \
    | envsubst '$ENV_APP_DATABASE_PASSWORD' \
    | envsubst '$PUSHER_APP_KEY' \
    | envsubst '$PUSHER_HOST' \
    | envsubst '$PUSHER_PORT' \
    | envsubst '$PUSHER_SCHEME' \
    | envsubst '$PUSHER_APP_CLUSTER' > $p_destination
}

appenvsubstr devops/000-default.conf.template devops/000-default.conf
appenvsubstr devops/dir.conf.template devops/dir.conf
appenvsubstr devops/apache2.conf.template devops/apache2.conf
appenvsubstr devops/php.ini.template devops/php.ini
appenvsubstr devops/appspec.yml.template appspec.yml
appenvsubstr devops/appspec.sh.template devops/appspec.sh
appenvsubstr .env.example .env

chmod 777 devops/appspec.sh
