#!/bin/bash

python_version=3.7

echo """Welcome sir or madam...
I'll be building your django today. How would you like it?"""
echo "Lets start with the name of this project."

echo "What name should I use?"
read project_name

main_dir="${project_name}-django"
mkdir projects/${main_dir}
project_path=projects/${main_dir}

dockerfile=`cat scaffold/Dockerfile`
dockerfile=${dockerfile/<python_version>/$python_version}
dockerfile=${dockerfile/<project_name>/$project_name}
echo "$dockerfile" > "${project_path}/Dockerfile"

config=`cat scaffold/config.env`
config=${config/<project_name>/$project_name}
echo "$config" > "${project_path}/config.env"

cp scaffold/docker-compose.yml ./${project_path}/docker-compose.yml
cp scaffold/requirements.txt ./${project_path}/requirements.txt

docker-compose -f ${project_path}/docker-compose.yml run web django-admin.py startproject ${project_name} .

cp -r update_settings ./${project_path}/${project_name}/

docker-compose -f ${project_path}/docker-compose.yml run web bash ${project_name}/update_settings/update_settings.sh

rm -r ./${project_path}/${project_name}/update_settings

docker-compose -f ${project_path}/docker-compose.yml up
