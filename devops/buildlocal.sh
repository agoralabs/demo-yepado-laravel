#!/bin/bash

THE_DATE=$(date '+%Y-%m-%d %H:%M:%S')
log_msg "Build started on $THE_DATE"

source_folder=$TF_VAR_ENV_APP_BE_LOCAL_SOURCE_FOLDER

mkdir -p $source_folder/tmp
chmod 777 $source_folder/tmp

arraytpl=($(ls -d $source_folder/devops/*.template))

for template in "${arraytpl[@]}"
do
    pattern=${template%.template}
    generated=${pattern##*/}
    log_msg "generate $generated file..."
    pattern=${template%.template}
    appenvsubstr $template $source_folder/$generated
done

#For Laravel only
env_file=$source_folder/devops/.env.example.template
if [ -f "$env_file" ]; then
    log_msg "generate ./.env file..."
    appenvsubstr $env_file $source_folder/.env
fi