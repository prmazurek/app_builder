#!/bin/bash

function check_environment_variables {
	if [ -z "$GITHUB_SECRET" ] || [ -z "$GITHUB_USERNAME" ] || [ -z "$CIRCLECI_SECRET" ]
	then
		echo """
			One of the following environment variables is unset, all of them are required for a successful execution of this script.
			- GITHUB_USERNAME
			- GITHUB_SECRET
			- GITHUB_USERNAME
		"""
		exit 1
	fi
}

function introduction {
	echo "Welcome sir or madam...\nI'll be building your django today. How would you like it?"
}

function set_mandatory_variables {
	workdir=$(pwd)
	read -p "What name should I use? " project_name
}

function prompt_for_common_variables {
	read -p "Which python version would you like me to use? " prompt
	if [[ $prompt =~ ^[2-3]\.[0-7]$ ]]
	then
	    python_version=$prompt
	else
	    echo "Invalid Python version specified. It should contain only numbers and dots. e.g. 3.7"
	    exit 1
	fi
	read -p "Do you want me to set up a Github repo as well? <Y/N> " prompt
	if [[ $prompt =~ [yY](es)? ]]
	then
		create_github=true
	else
		create_github=false
	fi
	read -p "And how about Circle Ci, should I create a project? <Y/N> " prompt
	if [[ $prompt =~ [yY](es)? ]]
	then
		create_circleci=true
	else
		create_circleci=false
	fi
}

function set_customizable_variables {
	python_version=3.7
	create_github=true
	create_circleci=true
}

function set_required_django_variables {
	if [ ! -z "$interactive" ]
	then
		read -p "With which Django version would you like your project to use? " prompt
		if [[ $prompt =~ ^[1-2]\.[0-9](\.[0-9])?$ ]]
		then
		    django_version=$prompt
		else
		    echo "Invalid Django version specified. It should contain only numbers and dots. e.g. 2.1.5"
		    exit 1
		fi
		prompt_for_common_variables
	else
		django_version=2.1.5
		set_customizable_variables
	fi
}

function set_required_django_cms_variables {
	if [ ! -z "$interactive" ]
	then
		prompt_for_common_variables
	else
		set_customizable_variables
	fi
}

function create_django_file_structure {
	main_dir="${project_name}-django"
	mkdir projects/${main_dir}
	project_path=projects/${main_dir}

	sed 's/<python_version>/'"$python_version"'/g' scaffold/Dockerfile | sed 's/<project_name>/'"$project_name"'/g' > ${project_path}/Dockerfile

	sed 's/<project_name>/'"$project_name"'/g' scaffold/config.env > ${project_path}/config.env

	cp scaffold/docker-compose.yml ${project_path}/docker-compose.yml

	mkdir ${project_path}/.circleci
	sed 's/<python_version>/'"$python_version"'/g' scaffold/.circleci/config.yml | sed 's/<project_name>/'"$project_name"'/g' > ${project_path}/.circleci/config.yml
}

function create_django_project {
	docker-compose -f ${project_path}/docker-compose.yml run web django-admin.py startproject ${project_name} .

	cp -r update_settings ./${project_path}/${project_name}/

	docker-compose -f ${project_path}/docker-compose.yml run web bash ${project_name}/update_settings/update_settings.sh

	rm -r ./${project_path}/${project_name}/update_settings
}

function create_django_cms_project {
	cp scaffold/requirements.django_cms.txt ${project_path}/requirements.txt

	docker-compose -f ${project_path}/docker-compose.yml run web djangocms -s -p . -r requirements.txt -m -u --no-db-driver ${project_name}

	sed -i '' 's/djangocms-installer//g' ${project_path}/requirements.txt

	cp -r update_settings ./${project_path}/${project_name}/

	docker-compose -f ${project_path}/docker-compose.yml run web bash ${project_name}/update_settings/update_settings.sh

	rm -r ${project_path}/${project_name}/update_settings
}


function call_github_api {
	curl -i -H "Authorization: token ${GITHUB_SECRET}" -d "{\"name\": \"${project_name}\", \"auto_init\": false, \"private\": true}" https://api.github.com/user/repos
}

function commit_and_push {
	cd ${project_path}
	git init
	git add .
	git commit -m"Automatic initial commit"
	git remote add origin git@github.com:${GITHUB_USERNAME}/${project_name}.git
	git push https://${GITHUB_USERNAME}:${GITHUB_SECRET}@github.com/${GITHUB_USERNAME}/${project_name}.git
	cd ${workdir}
}

function setup_github_repo {
	call_github_api
	commit_and_push
}

function setup_circleci_project {
	curl -X POST https://circleci.com/api/v1.1/project/github/${GITHUB_USERNAME}/${project_name}/follow?circle-token=${CIRCLECI_SECRET}
}

function start_containers {
	docker-compose -f ${project_path}/docker-compose.yml up
}

function setup_django {
	set_required_django_variables
	create_django_file_structure

	sed 's/<django_version>/Django=='"$django_version"'/g' scaffold/requirements.django.txt > ${project_path}/requirements.txt

	create_django_project
}

function setup_django_cms {
	set_required_django_cms_variables

	create_django_file_structure

	create_django_cms_project
}

function comming_up_soon {
	echo "This option is not available yet, sorry."
}

function setup_project {
read -p """What technology would you like me to use?
1 - Django
2 - Django-CMS
3 - Django-REST-framework
4 - Django-CMS and Django-REST-framework
5 - Flask
6 - Flask-RESTful
7 - node.js
""" technology_stack

	case $technology_stack in
		1) setup_django;;
		2) setup_django_cms;;
		3) comming_up_soon;;
		4) comming_up_soon;;
		5) comming_up_soon;;
		6) comming_up_soon;;
		7) comming_up_soon;;
		[^1-7]*) echo "Invalid choice."
	esac
}

function main {
	[ ! -z "$verbosity" ] && set -x

	check_environment_variables

	introduction

	set_mandatory_variables

	setup_project

	[ $create_github ] && setup_github_repo

	[ $create_circleci ] && setup_circleci_project

	start_containers
}

function usage {
	echo """
		This script will create an empty project file structure for a python framework of your choosing.
		If you choose to do so it will also create a project repository on your github, and create a project on circleci.
		Required environment variables:

		- GITHUB_USERNAME - This required for a successful call to either github api or circleci api.
				    This script will atempt to use it for project creation on both of them.

		- GITHUB_SECRET - Access token for GITHUB_USERNAMEs account. Required by githubs api for authentication.
				  You can find instructions on how to create one here:
				  https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/

		- CIRCLECI_SECRET - Access token for circleci. Required by circlecis api for authentication.
				    You can find instructions on how to create one here:
				    https://circleci.com/docs/2.0/managing-api-tokens/
	"""
}

while [ "$1" != "" ]; do
	case $1 in
		-v | --verbosity )    verbosity=1;;
		-i | --interactive )  interactive=1;;
		-h | --help )         usage
		                      exit;;
		* )                   usage
		                      exit 1
	esac
	shift
done

[ $# -eq 0 ] && main
