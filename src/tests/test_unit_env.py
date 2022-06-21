import os

def test_debug_vars():
    assert int(os.environ.get("MICROBLOGPUBDEV")) == 1