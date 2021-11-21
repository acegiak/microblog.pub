import pytest
from pathlib import Path
import yaml

@pytest.fixture
def config_fixture():
    """Return the current config as a dict."""
    return """
    username: 'ci'
    name: 'CI tests'
    icon_url: 'https://sos-ch-dk-2.exo.io/microblogpub/microblobpub.png'
    domain: 'localhost:5005'
    summary: 'test instance summary'
    pass: '$2b$12$nEgJMgaYbXSPOvgnqM4jSeYnleKhXqsFgv/o3hg12x79uEdsR4cUy'  # hello
    https: false
    """