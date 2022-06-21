#!/bin/bash

# TODO: shift docker compose to some other structure
# env POUSSETACHES_AUTH_KEY=${DEV_POUSSETACHES_AUTH_KEY} docker-compose -f docker-compose-dev.yml up -d
export FLASK_ENV=development
export FLASK_DEBUG=1
export FLASK_APP=src/microblogpub.app
export MICROBLOGPUBDEV=1
export MICROBLOGPUB_POUSSETACHES_HOST=localhost:7991
export MICROBLOGPUB_MONGODB_HOST=localhost:27017
export POUSSETACHES_AUTH_KEY="1234"

flask run -p 5005 --host=0.0.0.0 --with-threads 
# docker-compose down