FROM docker.io/library/python:3.10 AS base
RUN pip install poetry

FROM base AS builder
WORKDIR /install
COPY pyproject.toml ./
COPY src/microblogpub/.  src/microblogpub/
RUN poetry lock && poetry build

FROM docker.io/library/python:3.10 AS app
COPY --from=builder /install/dist/. /install/dist
RUN pip install /install/dist/microblogpub-*.whl && rm -r /install
WORKDIR /app
ENV MICROBLOGPUB_POUSSETACHES_HOST=localhost:7991 \
    MICROBLOGPUB_MONGODB_HOST=localhost:27017 \
    POUSSETACHES_AUTH_KEY="1234"\
    MICROBLOGPUB_INTERNAL_HOST="http://host.docker.internal:5005"

FROM app as dev
WORKDIR /app
ENV FLASK_DEBUG=1
COPY config/me.yml config/ 
COPY run_dev.sh ./
CMD ["./run_dev.sh"]

FROM app as prod
WORKDIR /app
COPY run.sh ./
RUN pip install --no-cache \
    --disable-pip-version-check \
    gunicorn
CMD ["./run.sh"]

