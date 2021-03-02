FROM python:3.9 AS base

FROM base AS builder
COPY requirements.txt /install/requirements.txt
WORKDIR /install
RUN pip install --prefix=/install --no-warn-script-location \
    -r requirements.txt

FROM base AS app
COPY --from=builder /install /usr/local
WORKDIR /app
COPY static/. static
COPY utils/. utils
COPY templates/. templates
COPY blueprints/. blueprints
COPY sass/. sass
COPY core/. core
COPY app.py startup.py config.py run_dev.sh ./
ENV FLASK_APP=app.py \
    MICROBLOGPUB_POUSSETACHES_HOST=localhost:7991 \
    MICROBLOGPUB_MONGODB_HOST=localhost:27017 \
    DEV_POUSSETACHES_AUTH_KEY="1234567890"\
    MICROBLOGPUB_INTERNAL_HOST="http://host.docker.internal:5005"\
    FLASK_DEBUG=1 \
    MICROBLOGPUB_DEV=1
CMD ["./run_dev.sh"]

FROM app AS test
COPY requirements-dev.txt /app/requirements-dev.txt
WORKDIR /app
RUN pip install -r requirements-dev.txt
