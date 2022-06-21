#!/bin/bash
set +x


source ./podman-stop.sh
source ./scripts/deps-up.sh

podman pod create \
    --network=microblogpub-network \
    -n web \
    -p 5005:5005

# start container with microblogpub prod image
podman run -dt --pod web \
    -e MICROBLOGPUB_MONGODB_HOST=mongo.dns.podman:27017 \
    -e MICROBLOGPUB_INTERNAL_HOST=http://microblogpub.dns.podman:5005 \
    -e MICROBLOGPUB_POUSSETACHES_HOST=http://poussetaches.dns.podman:7991 \
    -e POUSSETACHES_AUTH_KEY=1234 \
    -e COMPOSE_PROJECT_NAME=microblogpub \
    -v ./config:/app/config \
    -v ./static:/app/static \
	-v ./src/templates:/app/templates \
	-v ./src/sass:/app/sass \
    localhost/microblogpub:latest