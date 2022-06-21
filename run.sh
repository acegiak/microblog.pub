#!/bin/bash
# TODO: create migrations init
python -c "import logging; logging.basicConfig(level=logging.DEBUG); from core import migrations; migrations.perform()"
python -c "from core import indexes; indexes.create_indexes()"
python -m microblogpub.startup
(sleep 5 && curl -X POST -u :$POUSETACHES_AUTH_KEY $MICROBLOGPUB_POUSSETACHES_HOST/resume)&
gunicorn --workers 3 -b 0.0.0.0:5005 --log-level debug microblogpub.app:app
