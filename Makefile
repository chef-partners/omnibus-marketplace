DEFAULT_MACHINE = $(HOME)/.docker/machine/machines/default
CURRENT_GIT_BRANCH = $(shell git name-rev --name-only HEAD)
DEFINITION_URI ?= https://raw.githubusercontent.com/chef-partners/omnibus-marketplace/$(CURRENT_GIT_BRANCH)/arm-templates/automate/createUiDefinition.json

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
	docker-compose up -d $*

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

arm-run-test-matrix:
	cd arm-test-matrix;\
	bundle install;\
	bundle exec ruby ./automate_matrix.rb ../arm-templates/automate/mainTemplate.json ../arm-templates/automate/mainTemplateParameters.json

arm-validate:
	azure group template validate -f ./arm-templates/automate/mainTemplate.json -e ./arm-templates/automate/mainTemplateParameters.json -g automatearmtest
	npm install && npm install grunt --global && grunt test -folder=./arm-templates/automate

arm-ui-test-href:
	ENCODED_URI=$$(curl -Gso /dev/null -w %{url_effective} --data-urlencode "$(DEFINITION_URI)" "" | cut -c 3-);\
	echo "https://portal.azure.com/#blade/Microsoft_Azure_Compute/CreateMultiVmWizardBlade/internal_bladeCallId/anything/internal_bladeCallerParams/{\"initialData\":{},\"providerConfig\":{\"createUiDefinition\":\"$$ENCODED_URI\"}}";\

arm-test:
	azure group deployment create -f ./arm-templates/automate/mainTemplate.json -e ./arm-templates/automate/mainTemplateParameters.json -g automatearmtest

arm-create-zip:
	cd ./arm-templates/automate && zip -r "../../automate_arm_`date -u +"%Y-%m-%dT%H:%M:%SZ"`.zip" ./*

run-chef-client-test:
	docker-compose -f docker-compose-tests.yml run chef-client-test

.PHONY: clean start test
