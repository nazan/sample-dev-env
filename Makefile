DOCKER_REGISTRY ?= dkrhub.alliedinsure.com.mv

THIS_FILE := $(lastword $(MAKEFILE_LIST))

MY_UID = $$(id -u)
MY_GID = $$(id -g)

# Shell access to app container.

.PHONY: sample-bash
sample-bash:
	docker-compose exec --user $(MY_UID):$(MY_GID) sample bash

# Container preparation routines.

.PHONY: sample-prepare
sample-prepare: sample-touch
	docker-compose exec --user root:root sample /usr/src/aidock/build/prepare-super.sh
	docker-compose exec sample /usr/src/aidock/build/prepare.sh


.PHONY: prepare-all
prepare-all: sample-prepare
	@echo "Post setup done for all application components."



.PHONY: checkout-masters
checkout-masters:
	git -C ./sample checkout master



# Bring up/down services.

.PHONY: up
up: touch-all
	docker-compose up -d sample-nginx

.PHONY: down
down:
	docker-compose down


.PHONY: sample-touch
sample-touch:
	cp -n ./sample/.env.example ./sample/.env
	touch ./sample/storage/logs/laravel.log

	cp -n ./sample-dc/.env.example ./sample-dc/.env
	
	mkdir -p ./sample-dc/.npm
	mkdir -p ./sample-dc/.npm-appuser
	mkdir -p ./sample-dc/log
	touch ./sample-dc/log/xdebug.log
	touch ./sample-dc/log/php-error.log
	touch ./sample-dc/log/nginx-error.log
	touch ./sample-dc/log/nginx-access.log

.PHONY: touch-all
touch-all: sample-touch
	cp -n ./.env.example ./.env

	@echo "Required directories and files in host machine has been created."