#!/bin/bash

function setup_circleci_project {
	curl -X POST https://circleci.com/api/v1.1/project/github/${GITHUB_USERNAME}/${project_name}/follow?circle-token=${CIRCLECI_SECRET}
}
