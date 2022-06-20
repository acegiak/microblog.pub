SHELL := /bin/bash
PYTHON=python
SETUP_WIZARD_IMAGE=microblogpub-setup-wizard:latest
MICROBLOGPUB_IMAGE=microblogpub:latest
MICROBLOGPUB_DEV_IMAGE=microblogpub-dev:latest
PWD=$(shell pwd)
#FIXME change url if using functionality
CR_DEV_IMAGE=ghcr.io/howaboutudance/microblogpub-dev
CR_PROD_IMAGE=ghcr.io/howaboutudance/microblogpub-prod
# used to make usable with podman
CONT_EXEC := $(if $(shell command -v "podman"), podman, docker)

reload-dev:
	${CONT_EXEC} build . -t ${MICROBLOGPUB_IMAGE}
	docker-compose -f docker-compose-dev.yml up -d --force-recreate

# Build the microblogpub Docker image
.PHONY: microblogpub
microblogpub:
	# Rebuild the Docker image
	${CONT_EXEC} build . --no-cache --target=prod -t ${MICROBLOGPUB_IMAGE} 

# Build the microblogpub-dev Docker image
.PHONY: microblogpub-dev
microblogpub-dev:
	poetry run ./run_dev.sh

.PHONY: css
css:
	# Download pure.css if needed
	if [[ ! -f static/pure.css ]]; then curl -Lo static/pure.css https://unpkg.com/purecss@1.0.1/build/pure-min.css; fi
	# Download the emojis from twemoji if needded
	if [[ ! -d static/twemoji ]]; then curl -L https://github.com/twitter/twemoji/archive/v12.1.6.tar.gz | tar xzf - && mv twemoji-12.1.6/assets/svg static/twemoji && rm -rf twemoji-12.1.6; fi

# Run the docker-compose project locally (will perform a update if the project is already running)
.PHONY: run
run: microblogpub css
	# (poussetaches and microblogpub Docker image will updated)
	# Update MongoDB
	${CONT_EXEC} pull mongo:3
	${CONT_EXEC} pull poussetaches/poussetaches
	# Restart the project
	docker-compose stop
	docker-compose up -d --force-recreate --build

.PHONY: dev
dev: microblogpub-dev css
	./scripts/deps-up.sh

# publish-image pushes image to container reigstry(cr), assume CONT_EXEC is
# authenecticated against cr
.PHONY: publish-image
publish-image: microblogpub
	${CONT_EXEC} tag ${MICROBLOGPUB_IMAGE} ${CR_PROD_IMAGE}
	${CONT_EXEC} push ${CR_PROD_IMAGE}