#!/bin/bash

set +x

if command -v "podman"; then
    source scripts/podman-deps-dn.sh
else
    docker-compose dn
fi