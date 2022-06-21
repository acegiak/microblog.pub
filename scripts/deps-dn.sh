#!/bin/bash
set +x

if podman network exists microblogpub-network; then
    podman pod kill mongo
    podman pod kill poussetaches
    podman pod rm mongo 
    podman pod rm poussetaches 
    podman network rm microblogpub-network
else
    echo "microblogpub-network does not exists... exiting..."
fi