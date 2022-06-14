if [ "$(podman network exists microblogpub-network)" == "1" ]; then
    podman network create microblogpub-network
fi

podman pod create \
    --network=microblogpub-network \
    -p 5005:5005 \
    -n web

podman run -dt --pod web \
    -e MICROBLOGPUB_MONGODB_HOST=mongo:27017 \
    -e MICROBLOGPUB_INTERNAL_HOST=http://microblogpub:5005 \
    -e MICROBLOGPUB_POUSSETACHES_HOST=http://poussetaches:7991 \
    -e POUSSETACHES_AUTH_KEY=1234 \
    -e COMPOSE_PROJECT_NAME=microblogpub \
    -v ./config:/app/config:z \
    -v ./static:/app/static:z \
    localhost/microblogpub:latest

podman pod create \
    --network=microblogpub-network \
    -n mongo

podman run -dt --pod mongo \
    -v ./data/mongodb:/data/db:z \
    docker.io/mongo:3

podman pod create \
    --network=microblogpub-network \
    -n poussetaches

podman run -dt --pod poussetaches \
    -v ./data/poussetaches:/app/poussetaches_data:z \
    -e POUSSETACHES_AUTH_KEY=1234 \
    docker.io/poussetaches/poussetaches:latest
