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
	echo "Lets start with the name of this project."
}

function set_mandatory_variables {
	workdir=$(pwd)
	read -p "What name should I use? " project_name
}

function prompt_for_customizable_variables {
	read -p "Which python version would you like me to use? " prompt
		if [[ $prompt =~ ^[2-3]\.[0-7]$ ]]
		then
		    python_version=$prompt
		else
		    echo "Invalid Python version specified. It should contain only numbers and dots. e.g. 3.7"
		    exit 1
		fi
	read -p "With which Django version would you like your project to use? " prompt
		if [[ $prompt =~ ^[1-2]\.[0-9](\.[0-9])?$ ]]
		then
		    django_version=$prompt
		else
		    echo "Invalid Django version specified. It should contain only numbers and dots. e.g. 2.1.5"
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
	django_version=2.1.5
	create_github=true
	create_circleci=true
}

function set_required_variables {
	set_mandatory_variables
	if [ ! -z "$interactive" ]
	then
		prompt_for_customizable_variables
	else
		set_customizable_variables
	fi
}

function create_django_file_structure {
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

	cp scaffold/docker-compose.yml ${project_path}/docker-compose.yml

	requirements=`cat scaffold/requirements.txt`
	requirements=${requirements/<django_version>/"Django==$django_version"}
	echo "$requirements" > "${project_path}/requirements.txt"
}

function create_django_project {
	docker-compose -f ${project_path}/docker-compose.yml run web django-admin.py startproject ${project_name} .

	cp -r update_settings ./${project_path}/${project_name}/

	docker-compose -f ${project_path}/docker-compose.yml run web bash ${project_name}/update_settings/update_settings.sh

	rm -r ./${project_path}/${project_name}/update_settings
}

function call_github_api {
	echo "curl -i -H "Authorization: token ${GITHUB_SECRET}" -d '{"name": "${project_name}", "auto_init": false, "private": true}' https://api.github.com/user/repos"
}

function commit_and_push {
	# cd ${project_path}
	# git init
	# git add .
	# git commit -m"Automatic initial commit"
	# git remote add origin git@github.com:${GITHUB_USERNAME}/${project_name}.git
	# cd workdir
	echo "pushing..."
}

function setup_github_repo {
	call_github_api
	commit_and_push
}

function setup_circleci_project {
	echo "curl -X POST https://circleci.com/api/v1.1/project/github/${GITHUB_USERNAME}/${project_name}/follow?circle-token=${CIRCLECI_SECRET}"
}

function start_containers {
	docker-compose -f ${project_path}/docker-compose.yml up
}

function main {
	[ ! -z "$verbosity" ] && set -x

	check_environment_variables
	introduction
	set_required_variables

	create_django_file_structure
	create_django_project

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
