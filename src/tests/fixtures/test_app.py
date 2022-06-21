from operator import truediv
import pytest
from microblogpub.app import app

@pytest.fixture()
def test_app():
    app.config.update({
        "TESTING": True
    })

    yield app

@pytest.fixture()
def test_client(test_app):
    return app.test_client()