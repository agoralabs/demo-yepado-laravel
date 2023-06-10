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
    | envsubst '$TF_VAR_ENV_PUSHER_APP_CLUSTER' \
    | envsubst '$TF_VAR_ENV_SCRIPT_MODE' \
    | envsubst '$TF_VAR_ENV_APP_BACKEND_EKS_CLUSTER_NAME' > $p_destination
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
    chmod 777 devops/appspec.sh

elif [ "$TF_VAR_ENV_SCRIPT_MODE" == "CLOUDEKS" ] 
then
    appenvsubstr devops/Dockerfile.template Dockerfile
    appenvsubstr devops/laravel-kubernetes.yaml.template laravel-kubernetes.yaml
    appenvsubstr devops/laravel-service.yaml.template laravel-service.yaml

    aws ecr get-login-password --region $TF_VAR_ENV_APP_AWS_REGION | docker login --username AWS --password-stdin $TF_VAR_ENV_APP_AWS_ACCOUNT_ID.dkr.ecr.$TF_VAR_ENV_APP_AWS_REGION.amazonaws.com

    docker build -t $TF_VAR_ENV_APP_NAME:$TF_VAR_ENV_APP_BACKEND_NAMESPACE'_'$TF_VAR_ENV_APP_NAME .

    echo "Tag your image with the Amazon ECR registry..."
    docker tag $TF_VAR_ENV_APP_NAME:$TF_VAR_ENV_APP_BACKEND_NAMESPACE'_'$TF_VAR_ENV_APP_NAME $TF_VAR_ENV_APP_AWS_ACCOUNT_ID.dkr.ecr.$TF_VAR_ENV_APP_AWS_REGION.amazonaws.com/$TF_VAR_ENV_APP_NAME:$TF_VAR_ENV_APP_BACKEND_NAMESPACE'_'$TF_VAR_ENV_APP_NAME

    echo "Push the image..."
    docker push $TF_VAR_ENV_APP_AWS_ACCOUNT_ID.dkr.ecr.$TF_VAR_ENV_APP_AWS_REGION.amazonaws.com/$TF_VAR_ENV_APP_NAME:$TF_VAR_ENV_APP_BACKEND_NAMESPACE'_'$TF_VAR_ENV_APP_NAME

    aws eks update-kubeconfig --region $TF_VAR_ENV_APP_AWS_REGION --name $TF_VAR_ENV_APP_BACKEND_EKS_CLUSTER_NAME

    kubectl apply -f laravel-kubernetes.yaml
    kubectl apply -f laravel-service.yaml

else
    appenvsubstr devops/appspec.sh.template devops/appspec.sh
    chmod 777 devops/appspec.sh

fi



