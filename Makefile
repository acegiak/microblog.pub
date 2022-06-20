SHELL := /bin/bash
PYTHON=python
SETUP_WIZARD_IMAGE=microblogpub-setup-wizard:latest
MICROBLOGPUB_IMAGE=microblogpub:latest
MICROBLOGPUB_DEV_IMAGE=microblogpub-dev:latest
PWD=$(shell pwd)
#FIXME change url if using functionality
CR_DEV_IMAGE=ghcr.io/howaboutudance/microblogpub-dev
CR_PROD_IMAGE=ghcr.io/howaboutudance/microblogpub-prod
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

# Build the microblogpub Docker image
.PHONY: microblogpub
microblogpub:
	# Rebuild the Docker image
	${CONT_EXEC} build . --no-cache --target=prod -t ${MICROBLOGPUB_IMAGE} 

# Build the microblogpub-dev Docker image
.PHONY: microblogpub-dev
microblogpub-dev:
	# Rebuild the Docker image
	${CONT_EXEC} build . --target=dev -t ${MICROBLOGPUB_DEV_IMAGE} 

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

# Run as a full deployment in Kubernetes, assming kubectl is set to correct
# cluster already
.PHONY: dev-k8
dev-k8: publish-dev css expose-k8
	kubectl apply -f ${K8_BACKEND_YAML}	
	kubectl apply -f ${K8_INSTANCE_YAML}

expose-k8:
	kubectl expose deployment microblogpub-dev --port=5005 --type=LoadBalancer --name microblogpub-loadbalancer --dry-run=client --output=yaml | kubectl apply -f -

	set -e; \
	kubectl create configmap deployvars \
		--from-literal=internal-host=$(shell minikube service microblogpub-loadbalancer --url=true) \
		-o yaml \
		--dry-run=client | \
		kubectl replace -f -;
	

# publish-image pushes image to container reigstry(cr), assume CONT_EXEC is
# authenecticated against cr
.PHONY: publish-image
publish-image: microblogpub
	${CONT_EXEC} tag ${MICROBLOGPUB_IMAGE} ${CR_PROD_IMAGE}
	${CONT_EXEC} push ${CR_PROD_IMAGE}

.PHONY: publish-dev
publish-dev: microblogpub-dev
	${CONT_EXEC} tag ${MICROBLOGPUB_DEV_IMAGE} ${CR_DEV_IMAGE}
	${CONT_EXEC} push ${CR_DEV_IMAGE}:latest
# run the backend service for on k8 and setup tunneling for dev
.PHONY: dev-local-k8
dev-local-k8: microblogpub-dev css
	kubectl apply -f ${K8_BACKEND_YAML}
	$(eval MINI_IP := $(shell minikube ip))
	$(eval MONGO_PORT := $(shell kubectl get service mongo-service --output='jsonpath={.spec.ports[0].nodePort}'))
	$(eval POUSS_PORT := $(shell kubectl get service poussetaches-service --output='jsonpath={.spec.ports[0].nodePort}'))
	${CONT_EXEC} run -it -p 5005:5005 -v ${PWD}/config:/app/config \
		-e MICROBLOGPUB_MONGODB_HOST=${MINI_IP}:${MONGO_PORT} \
		-e MICROBLOGPUB_POUSSETACHES_HOST=http://${MINI_IP}:${POUSS_PORT} \
		${MICROBLOGPUB_DEV_IMAGE}

