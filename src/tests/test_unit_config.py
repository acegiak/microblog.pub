from microblogpub import config
from pathlib import Path


def test_template_dir():
    project_root = Path(".").absolute()
    assert config.TEMPLATE_DIR.is_relative_to(project_root)