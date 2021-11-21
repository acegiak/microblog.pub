#!/usr/bin/python

import base64
import argparse
from enum import Enum
import json
import yaml
from pathlib import Path

class Registry(Enum):
    github="ghcr.io"

class EnumAction(argparse.Action):
  def __init__(self, **kwargs):

    enum_type = kwargs.pop("type", None)

    if enum_type is None:
      raise ValueError("type must be an existing Enum type")
    if not issubclass(enum_type, Enum):
      raise TypeError("Provide symbol is not an Enum")

    self.__enum = enum_type
    kwargs.setdefault("choices", tuple(e.name for e in enum_type))

    super(EnumAction, self).__init__(**kwargs)

class RegistryEnumAction(EnumAction):
  """
  Used by the argument parse to configure nice pretty documentation in --help
  and return a enum for --registry flag in the Namespace
  """
  def __call__(self, parser_obj: argparse.ArgumentParser, 
               namespace: argparse.Namespace, values: Enum,
               option_string=None) -> argparse.Namespace:
    if values:
      value = self.__enum[values]
    else:
      value = Registry.github
    setattr(namespace, self.dest, value)

def githubPAT_to_base64(user: str, pat_str: str) -> bytes:
    byte_str = f"{user}:{pat_str}".encode()
    authentication_str = str(base64.encodebytes(byte_str), encoding="UTF-8")
    registry_dict = {
        "auths": {
            Registry.github.value: {
                "auth": authentication_str
            }
        }
    }

    return base64.encodebytes(json.dumps(registry_dict).encode())

def to_yaml(pat_str: bytes, app_name: str = "app-name"):
    secret_document = {"kind": "Secret", "type": "kubernetes.io/dockerconfigjson",
        "apiVersion": "v1", "metadata": {
            "name": "dockerconfigjson-github-com",
            "labels": { "app": f"{app_name}"}
        }, 
        "data": {".dockerconfigjson": pat_str.decode()}
    }
    return yaml.dump(secret_document)
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--token", type=str)
    parser.add_argument("--user", type=str)
    parser.add_argument("--registry",type=Registry, action=RegistryEnumAction)
    parser.add_argument("--path",type=Path)
    args = parser.parse_args()

    if args.path: 
        args.path.write_text(to_yaml(githubPAT_to_base64(args.user, args.token)))
    else:
        print(to_yaml(githubPAT_to_base64(args.user, args.token)))