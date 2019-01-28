build-dev:
	docker-compose build

start-dev:
	docker-compose up

start-dev-i:
	docker-compose up -d && docker attach <project_name>_web

start-dev-d:
	docker-compose up -d

tests:
	docker-compose run web python manage.py test

shell:
	docker-compose run web python manage.py shell

migrations:
	docker-compose run web python manage.py makemigrations

migrate:
	docker-compose run web python manage.py migrate

superuser:
	docker-compose run web python manage.py createsuperuser

logs-web:
	docker-compose logs -ft --tail=1000 web

logs-postgres:
	docker-compose logs -ft --tail=1000 postgres

logs-nginx:
	docker-compose nginx -ft --tail=1000 nginx

logs-migrations:
	docker-compose migrations -ft --tail=1000 migrations

ssh-web:
	docker exec -it <project_name>_web bash

ssh-postgres:
	docker exec -it <project_name>_postgres bash

ssh-nginx:
	docker exec -it <project_name>_nginx bash

ssh-migrations:
	docker exec -it <project_name>_migrations bash
