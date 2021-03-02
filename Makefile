SHELL := /bin/bash
PYTHON=python
CONT_EXEC := $(if $(shell command -v "podman"), podman, docker)
K8_YAML = 
SETUP_WIZARD_IMAGE=microblogpub-setup-wizard:latest
<<<<<<< HEAD
K8_IMAGE=microblogpub
=======
MICROBLOGPUB_IMAGE=microblogpub:latest
>>>>>>> howaboutudance/issue9
PWD=$(shell pwd)
CR_IMAGE=us.gcr.io/hematite-300609/microblogpub-dev
K8_BACKEND_YAML=kubernetes/deploy-backend.yaml
K8_INSTANCE_YAML=kubernetes/deploy-microblogpub.yaml
# used to make usable with podman
CONT_EXEC := $(if $(shell command -v "podman"), podman, docker)

# Build the config (will error if an existing config/me.yml is found) via a Docker container
.PHONY: config
config:
	# Build the container for the setup wizard on-the-fly
	cd setup_wizard && docker build . -t $(SETUP_WIZARD_IMAGE)
	# Run and remove instantly
	-${CONT_EXEC} run -e MICROBLOGPUB_WIZARD_PROJECT_NAME --rm -it --volume $(PWD):/app/out $(SETUP_WIZARD_IMAGE)
	# Finally, remove the tagged image
	${CONT_EXEC} rmi $(SETUP_WIZARD_IMAGE)

# Reload the federation test instances (for local dev)
.PHONY: reload-fed
reload-fed:
<<<<<<< HEAD
	${CONT_EXEC} build . -t ${K8_IMAGE}:latest
	# Reload the local dev instance
	kubectl apply -f ${K8_YAML}
.PHONY: reload-dev
reload-dev:
	${CONT_EXEC} build . -t ${K8_IMAGE}:latest
=======
	${CONT_EXEC} build . -t ${MICROBLOGPUB_IMAGE} 
	docker-compose -p instance2 -f docker-compose-tests.yml stop
	docker-compose -p instance1 -f docker-compose-tests.yml stop
	WEB_PORT=5006 CONFIG_DIR=./tests/fixtures/instance1/config docker-compose -p instance1 -f docker-compose-tests.yml up -d --force-recreate --build
	WEB_PORT=5007 CONFIG_DIR=./tests/fixtures/instance2/config docker-compose -p instance2 -f docker-compose-tests.yml up -d --force-recreate --build

# Reload the local dev instance
.PHONY: reload-dev
reload-dev:
	${CONT_EXEC} build . -t ${MICROBLOGPUB_IMAGE}
	docker-compose -f docker-compose-dev.yml up -d --force-recreate
>>>>>>> howaboutudance/issue9

# Build the microblogpub Docker image
.PHONY: microblogpub
microblogpub:
	# Rebuild the Docker image
<<<<<<< HEAD
	${CONT_EXEC}} build . --no-cache -t microblogpub:latest
=======
	${CONT_EXEC} build . --no-cache --target=app -t ${MICROBLOGPUB_IMAGE} 
>>>>>>> howaboutudance/issue9

.PHONY: css
css:
	# Download pure.css if needed
	if [[ ! -f static/pure.css ]]; then curl -Lo static/pure.css https://unpkg.com/purecss@1.0.1/build/pure-min.css; fi
	# Download the emojis from twemoji if needded
	if [[ ! -d static/twemoji ]]; then curl -L https://github.com/twitter/twemoji/archive/v12.1.2.tar.gz | tar xzf - && mv twemoji-12.1.2/assets/svg static/twemoji && rm -rf twemoji-12.1.2; fi

# Run the docker-compose project locally (will perform a update if the project is already running)
.PHONY: run
run: microblogpub css
<<<<<<< HEAD
	# Restart the project
	kubectl apply -f ${K8_YAML}
=======
	# (poussetaches and microblogpub Docker image will updated)
	# Update MongoDB
	${CONT_EXEC} pull mongo:3
	${CONT_EXEC} pull poussetaches/poussetaches
	# Restart the project
	docker-compose stop
	docker-compose up -d --force-recreate --build

# Run as a full deployment in Kubernetes, assming kubectl is set to correct
# cluster already
.PHONY: run-k8
run-k8: publish-image css
	kubectl apply -f ${K8_BACKEND_YAML}
	kubectl apply -f ${K8_INSTANCE_YAML}

# publish-image pushes image to container reigstry(cr), assume CONT_EXEC is
# authenecticated against cr
.PHONY: publish-image
publish-image: microblogpub
	${CONT_EXEC} tag ${MICROBLOGPUB_IMAGE} ${CR_IMAGE}
	${CONT_EXEC} push ${CR_IMAGE}

# run the backend service for on k8 and setup tunneling for dev
#TODO: test with podman container
.PHONY: dev-k8
dev-k8: microblogpub css
	kubectl apply -f ${K8_BACKEND_YAML}
	$(eval MINI_IP := $(shell minikube ip))
	$(eval MONGO_PORT := $(shell kubectl get service mongo-service --output='jsonpath="{.spec.ports[0].nodePort}"' | tr -d \"))
	$(eval POUSS_PORT := $(shell kubectl get service pousstaches-service --output='jsonpath="{.spec.ports[0].nodePort}"' | tr -d \"))
	${CONT_EXEC} run -it -p 5005:5005 -v ${PWD}/config:/app/config \
		-e MICROBLOGPUB_MONGODB_HOST=${MINI_IP}:${MONGO_PORT} \
		-e MICROBLOGPUB_POUSSETACHES_HOST=${MINI_IP}:${POUSS_PORT} \
		${MICROBLOGPUB_IMAGE}

>>>>>>> howaboutudance/issue9
