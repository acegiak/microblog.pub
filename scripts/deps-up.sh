#!/bin/bash
set +x

# create network if needed
podman network create microblogpub-network

# create mongo server
podman pod create \
    --network=microblogpub-network \
    -n mongo

podman run -dt --pod mongo \
    -v ./data/mongodb:/data/db:z \
    docker.io/mongo:3

# create poussetaches server
podman pod create \
    --network=microblogpub-network \
    -n poussetaches

podman run -dt --pod poussetaches \
    -v ./data/poussetaches:/app/poussetaches_data:z \
    -e POUSSETACHES_AUTH_KEY=1234 \
    docker.io/poussetaches/poussetaches:latest

# create microblogpub app server
podman pod create \
    --network=microblogpub-network \
    -p 5005:5005 \
    -n web

podman run -dt --pod web \
    -e MICROBLOGPUB_MONGODB_HOST=mongo.dns.podman:27017 \
    -e MICROBLOGPUB_INTERNAL_HOST=http://microblogpub.dns.podman:5005 \
    -e MICROBLOGPUB_POUSSETACHES_HOST=http://poussetaches.dns.podman:7991 \
    -e POUSSETACHES_AUTH_KEY=1234 \
    -e COMPOSE_PROJECT_NAME=microblogpub \
    -v ./config:/app/config:z \
    -v ./static:/app/static:z \
    localhost/microblogpub:latest