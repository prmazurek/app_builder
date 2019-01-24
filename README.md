# App Builder

Automation of a project creation proces.

Currently setting up django only.
This script will create a python container, install django, and modify settings to establish postgres connection. After that it will create a repository on github and do initial commit with the project, it will also create a circleci project for this repository.
You will need to set a few environment variables:
```
export GITHUB_USERNAME=<github_username>
export GITHUB_SECRET=<github_auth_token>
export CIRCLECI_SECRET=<circleci_auth_token>
```
Instructions on how to generate auth tokens for github and circleci can be found here:
- https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/
- https://circleci.com/docs/2.0/managing-api-tokens/

`./create_project.sh` Will create a python 3.7 container with django 2.1.5

`./create_project.sh -i` Allows you to customize the building process. If you would like for example django 1.8 on python 2.7 for whatever reason, it will set it up for you.

`./create_project.sh -v` Verbosity mode.

`./create_project.sh -h` Help
