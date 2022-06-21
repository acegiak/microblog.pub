#!/bin/bash

set +x

if podman network exists microblogpub-network; then
    podman pod kill web
    podman pod rm web
fi

source ./scripts/deps-dn.sh