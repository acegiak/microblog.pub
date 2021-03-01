SHELL := /bin/bash
PYTHON=python
CONT_EXEC := $(if $(shell command -v "podman"), podman, docker)
K8_YAML = 
SETUP_WIZARD_IMAGE=microblogpub-setup-wizard:latest
K8_IMAGE=microblogpub
PWD=$(shell pwd)

# Build the config (will error if an existing config/me.yml is found) via a Docker container
.PHONY: config
config:
	# Build the container for the setup wizard on-the-fly
	cd setup_wizard && docker build . -t $(SETUP_WIZARD_IMAGE)
	# Run and remove instantly
	-docker run -e MICROBLOGPUB_WIZARD_PROJECT_NAME --rm -it --volume $(PWD):/app/out $(SETUP_WIZARD_IMAGE)
	# Finally, remove the tagged image
	docker rmi $(SETUP_WIZARD_IMAGE)

# Reload the federation test instances (for local dev)
.PHONY: reload-fed
reload-fed:
	${CONT_EXEC} build . -t ${K8_IMAGE}:latest
	# Reload the local dev instance
	kubectl apply -f ${K8_YAML}
.PHONY: reload-dev
reload-dev:
	${CONT_EXEC} build . -t ${K8_IMAGE}:latest

# Build the microblogpub Docker image
.PHONY: microblogpub
microblogpub:
	# Update microblog.pub
	git pull
	# Rebuild the Docker image
	${CONT_EXEC}} build . --no-cache -t microblogpub:latest

.PHONY: css
css:
	# Download pure.css if needed
	if [[ ! -f static/pure.css ]]; then curl -Lo static/pure.css https://unpkg.com/purecss@1.0.1/build/pure-min.css; fi
	# Download the emojis from twemoji if needded
	if [[ ! -d static/twemoji ]]; then curl -L https://github.com/twitter/twemoji/archive/v12.1.2.tar.gz | tar xzf - && mv twemoji-12.1.2/assets/svg static/twemoji && rm -rf twemoji-12.1.2; fi

# Run the docker-compose project locally (will perform a update if the project is already running)
.PHONY: run
run: microblogpub css
	# Restart the project
	kubectl apply -f ${K8_YAML}