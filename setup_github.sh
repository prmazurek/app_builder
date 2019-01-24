#!/bin/bash

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
