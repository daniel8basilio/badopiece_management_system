# EXECUTION
init:
	rm -dfr node_modules/* vendor/*
	composer update
	composer install
	yarn install
	yarn run build
clear-cache:
	rm -rf var/cache

# DATABASE AND MIGRATION
createdb:
	php bin/console doctrine:database:create
diffdb:
	php bin/console doctrine:migrations:diff
migrate:
	php bin/console doctrine:migrations:migrate
