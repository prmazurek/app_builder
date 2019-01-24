#!/bin/bash

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

	sed 's/<python_version>/'"$python_version"'/g' scaffolds/django/Dockerfile | sed 's/<project_name>/'"$project_name"'/g' > ${project_path}/Dockerfile

	sed 's/<project_name>/'"$project_name"'/g' scaffolds/django/config.env > ${project_path}/config.env

	cp scaffolds/django/docker-compose.yml ${project_path}/docker-compose.yml

	mkdir ${project_path}/.circleci
	sed 's/<python_version>/'"$python_version"'/g' scaffolds/django/.circleci/config.yml | sed 's/<project_name>/'"$project_name"'/g' > ${project_path}/.circleci/config.yml
}

function create_django_project {
	docker-compose -f ${project_path}/docker-compose.yml run --no-deps web django-admin.py startproject ${project_name} .

	cp -r scaffolds/django/update_files ./${project_path}/${project_name}/

	docker-compose -f ${project_path}/docker-compose.yml run --no-deps web bash ${project_name}/update_files/update_files.sh ${1:-update_django_settings}

	rm -r ./${project_path}/${project_name}/update_files
}

function create_django_cms_project {
	cp scaffolds/django/requirements.django_cms.txt ${project_path}/requirements.txt

	docker-compose -f ${project_path}/docker-compose.yml run --no-deps web djangocms -s -p . -r requirements.txt -m -u --no-db-driver ${project_name}

	sed -i '' 's/djangocms-installer//g' ${project_path}/requirements.txt

	cp -r scaffolds/django/update_files ./${project_path}/${project_name}/

	docker-compose -f ${project_path}/docker-compose.yml run --no-deps web bash ${project_name}/update_files/update_files.sh ${1:-update_django_settings}

	rm -r ${project_path}/${project_name}/update_files
}

function setup_django {
	set_required_django_variables
	create_django_file_structure

	sed 's/<django_version>/Django=='"$django_version"'/g' scaffolds/django/requirements.django.txt > ${project_path}/requirements.txt

	create_django_project
}

function setup_django_cms {
	set_required_django_cms_variables

	create_django_file_structure

	create_django_cms_project
}

function setup_django_rest_framework {
	set_required_django_variables
	create_django_file_structure

	sed 's/<django_version>/Django=='"$django_version"'/g' scaffolds/django/requirements.django.txt > ${project_path}/requirements.txt
	cat scaffolds/django/requirements.drf.txt >> ${project_path}/requirements.txt

	create_django_project update_drf_settings
}

function setup_django_cms_and_drf {
	set_required_django_cms_variables

	create_django_file_structure

	create_django_cms_project update_drf_for_cms_settings

	cat scaffolds/django/requirements.drf.txt >> ${project_path}/requirements.txt

}
