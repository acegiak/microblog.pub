import pytest

pytestmark = pytest.mark.integration


def test_root_get_route(config_fixture, test_client):
    """Ensure the homepage is accessible."""
    resp = test_client.get("/")
    assert resp.status_code == 200


def test_outbox_get_route(config_fixture, test_client):
    resp = test_client.get("/outbox")
    assert resp.status_code == 404


def test_inbox_get_route(config_fixture, test_client):
    resp = test_client.get("/inbox")
    assert resp.status_code == 404


def test_followers_get_route(config_fixture, test_client):
    resp = test_client.get("/followers")
    assert resp.status_code == 200


def test_following_get_route(config_fixture, test_client):
    resp = test_client.get("/following")
    assert resp.status_code == 404


def test_featured_get_route(config_fixture, test_client):
    resp = test_client.get("/featured")
    assert resp.status_code == 404


def test_feed_atom_get_route(config_fixture, test_client):
    resp = test_client.get("/feed.json")
    assert resp.status_code == 200


def test_feed_atom_get_route(config_fixture, test_client):
    resp = test_client.get("/feed.atom")
    assert resp.status_code == 200


def test_feed_rss_get_route(config_fixture, test_client):
    resp = test_client.get("/feed.rss")
    assert resp.status_code == 200
