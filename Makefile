DEFAULT_MACHINE = $(HOME)/.docker/machine/machines/default

ifneq ($(wildcard /Applications/Docker.app/*),)
start:
	docker-compose up -d
else
start: $(DEFAULT_MACHINE)
	docker-machine start default || true
	eval `docker-machine env default --shell sh` && direnv reload && docker-compose up -d

$(DEFAULT_MACHINE):
	docker-machine create default
endif

rebuild-all:
	docker-compose stop && \
	docker-compose rm -fv && \
	docker-compose build --no-cache && \
	docker-compose up -d

login-%:
	docker-compose exec $* bash

rebuild-%:
	docker-compose stop $* && \
	docker-compose rm -fv $* && \
	docker-compose build --no-cache $* && \
	docker-compose up -d $* && \

down:
	docker-compose down --rmi all --volumes --remove-orphans

delete-dangling: delete-dangling-images delete-dangling-containers delete-dangling-volumes

delete-dangling-images:
	docker images -aq -f dangling=true | xargs -- docker rmi -f

delete-dangling-containers:
	docker ps -a -q -f status=exited | xargs -- docker rm -v

delete-dangling-volumes:
	docker volume ls -qf dangling=true | xargs -- docker volume rm

clean: down delete-dangling
	rm -f cd.creds

stop:
	docker-compose stop

resume:
	docker-compose start

# For when you want to reset all the deps and data but don't need to rebuild
# the underlying images.
start-fresh: destroy start

destroy:
	docker-compose stop
	docker-compose rm --force

logs:
	docker-compose logs --follow

shell:
	docker-compose exec automate bash

build-gem:
	cd ./files/chef-marketplace-gem && gem build chef-marketplace*.gemspec

compile-biscotti-assets:
	cd ./files/biscotti && npm install && npm run build

load: compile-biscotti-assets load-biscotti load-cookbook build-gem load-gem load-reckoner load-omnibus-ctl

load-%:
	docker-compose exec automate "/shared/scripts/load-$*.sh"

arm-publish: arm-validate arm-create-zip

arm-validate:
	azure group template validate -f ./arm-templates/automate/mainTemplate.json -e ./arm-templates/automate/mainTemplateParameters.json -g automatearmtest

arm-test:
	azure group deployment create -f ./arm-templates/automate/mainTemplate.json -e ./arm-templates/automate/mainTemplateParameters.json -g automatearmtest

arm-create-zip:
	cd ./arm-templates/automate && zip -r "../../automate_arm_`date -u +"%Y-%m-%dT%H:%M:%SZ"`.zip" ./*

.PHONY: clean start test
