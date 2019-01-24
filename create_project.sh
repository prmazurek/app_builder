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
	echo "Welcome sir or madam... I'll be building your django today. How would you like it?"
}

function set_mandatory_variables {
	workdir=$(pwd)
	read -p "What name should I use? " project_name
}

function start_containers {
	docker-compose -f ${project_path}/docker-compose.yml --build up
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
		1) source setup_django.sh && setup_django;;
		2) source setup_django.sh && setup_django_cms;;
		3) source setup_django.sh && setup_django_rest_framework;;
		4) source setup_django.sh && setup_django_cms_and_drf;;
		5) source setup_flask.sh && comming_up_soon;;
		6) source setup_flask.sh && comming_up_soon;;
		7) source setup_nodejs.sh && comming_up_soon;;
		[^1-7]*) echo "Invalid choice."
	esac
}

function main {
	[ ! -z "$verbosity" ] && set -x

	check_environment_variables

	introduction

	set_mandatory_variables

	setup_project

	[ $create_github ] && source setup_github.sh && setup_github_repo

	[ $create_circleci ] && source setup_circleci.sh && setup_circleci_project

	# start_containers
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