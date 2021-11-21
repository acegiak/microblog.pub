import os
from pathlib import Path
import pytest
import requests
from html2text import html2text
import yaml

pytestmark = pytest.mark.intergration


def resp2plaintext(resp):
    """Convert the body of a requests reponse to plain text in order to make basic assertions."""
    return html2text(resp.text)


def test_ping_homepage(config_fixture):
    """Ensure the homepage is accessible."""
    resp = requests.get("http://localhost:5005")
    resp.raise_for_status()
    assert resp.status_code == 200
    body = resp2plaintext(resp)
    assert config["name"] in body
    assert f"@{config['username']}@{config['domain']}" in body
