FROM python:3.9 AS base

FROM base AS builder
COPY requirements/. /install/requirements/
WORKDIR /install
RUN pip install --prefix=/install --no-warn-script-location \
    -r requirements/prod.txt

FROM python:3.9-slim AS app
COPY --from=builder /install /usr/local
WORKDIR /app
COPY static/. static
COPY utils/. utils
COPY templates/. templates
COPY blueprints/. blueprints
COPY sass/. sass
COPY core/. core
COPY app.py startup.py config.py ./
ENV FLASK_APP=app.py \
    MICROBLOGPUB_POUSSETACHES_HOST=localhost:7991 \
    MICROBLOGPUB_MONGODB_HOST=localhost:27017 \
    POUSSETACHES_AUTH_KEY="1234567890"\
    MICROBLOGPUB_INTERNAL_HOST="http://host.docker.internal:5005"\
    FLASK_DEBUG=1 \
    MICROBLOGPUB_DEV=1

FROM app AS test
COPY requirements/. /app/requirements/.
WORKDIR /app
RUN apt-get update && apt-get install -y git
RUN pip install -r requirements/dev.txt

FROM app as dev
WORKDIR /app
COPY run_dev.sh ./
CMD ["./run_dev.sh"]

FROM app as prod
WORKDIR /app
COPY run.sh ./
CMD ["./run.sh"]

