from setuptools import find_packages, setup
from microblogpub import _version_
setup(
  name="microblogpub",
  version=_version_,
  requires="> 3.7",
  authors="tsileo & howaboutudance",
  url="https://github.com/howaboutudance/microblog.pub",
  install_requires= [
      "libsass",
      "python-dateutil",
      "tornado",
      "piexif",
      "python-u2flib-server",
      "Flask",
      "Flask-WTF",
      "pymango",
      "timeago",
      "bleach",
      "feedgun",
      "itsdangerous",
      "bcrypt",
      "mf2py",
      "passlib",
      "pyyaml",
      "pillow",
      "emoji-unicode",
      "html5lib",
      "Pygments",
      "flask-talisman",
      "cachetools"
  ],
  packages=find_packages()

)