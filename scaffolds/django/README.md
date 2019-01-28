# <project_name>

## Inital setup
```
make start-dev
```
If you would like to customize your local build, do so by using docker-compose.override.yml file.
## Useful commands

`make build-dev` rebuilds containers

`make start-dev` starts all containers

`make start-dev -d` starts everything in detached mode

`make start-dev-i` starts everything in detached mode and attaches your terminal stdin/stdout/stderr to web container

`make tests` runs djangos unit tests

`make shell` opens djangos shell

`make migrations` creates new migrations

`make migrate` runs migrations

`make superuser` creates django superuser

`make logs-<container_name>` displays logs for given container

`make ssh-<container_name>` enters given container   
