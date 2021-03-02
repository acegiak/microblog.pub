#!/bin/bash

# TODO: shift docker compose to some other structure
# env POUSSETACHES_AUTH_KEY=${DEV_POUSSETACHES_AUTH_KEY} docker-compose -f docker-compose-dev.yml up -d
flask run -p 5005 --with-threads
# docker-compose down
