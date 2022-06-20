#!/bin/bash
set +x

# create network if needed
podman network create microblogpub-network

# create mongo server
podman pod create \
    --network=microblogpub-network \
    -n mongo \
    -p 27017:27017

podman run -dt --pod mongo \
    -v ./data/mongodb:/data/db:z \
    docker.io/mongo:3

# create poussetaches server
podman pod create \
    --network=microblogpub-network \
    -n poussetaches \
    -p 7991:7991

podman run -dt --pod poussetaches \
    -v ./data/poussetaches:/app/poussetaches_data:z \
    -e POUSSETACHES_AUTH_KEY=1234 \
    docker.io/poussetaches/poussetaches:latest