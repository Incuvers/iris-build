#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""
SafeLoad YAML Parser
--------------------
Modified: 2021-03
Syntax inspired by: https://www.elastic.co/guide/en/beats/winlogbeat/current/using-environ-vars.html
Usage:
test.yaml:
    ...
    hostname: ${HOSTNAME:black-pearl}
                    ^         ^
                 env var    default
    ...
If the environment variable cannot be found a default value can be specified as a fallback.
"""
import pprint
import logging
import yaml
import re
import os
import sys
import getopt

def main(argv):
    snap_file = ''
    try:
        opts, args = getopt.getopt(argv,"hi:",["input="])
    except getopt.GetoptError:
        logging.exception("./yaml_parser.py -i <inputfile>")
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            logging.info("./yaml_parser.py -i <inputfile>")
            sys.exit()
        elif opt in ("-i", "--input"):
            snap_file = arg
    
    logging.info("Loading yaml from: %s", snap_file)
    # LOAD path to yaml from arg
    with open(snap_file, 'r') as stream:
        try:
            snap = yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            logging.exception("Error parsing yaml: %s", exc)
        except IndexError as exc:
            logging.exception("Environment variable required but was not specified: %s", exc)
        else:
            logging.info('Saving to build directory')
            with open(snap_file, 'w') as outstream:
                yaml.dump(snap, outstream, default_flow_style=False)
        logging.info("Yaml parse complete:\n%s", pprint.pformat(snap))

def path_constructor(loader:yaml.loader.SafeLoader, node:yaml.nodes.ScalarNode) -> str:
    """
    Extract the matched value, expand env variable, and replace the match
    
    :raises IndexError: if environment variable was not found and no default was specified
    :returns: string replacement
    """
    value = node.value
    logging.info("Value: %s", value)
    match = path_matcher.match(value)
    env_var = match.group()[2:-1].split(':')
    logging.info("Env: %s", env_var)
    try:
        var = os.environ[env_var[0]] + value[match.end():]
    except KeyError:
        # here we expect the default to be defined otherwise we raise IndexError
        var = env_var[1] + value[match.end():]
    return var

if __name__ == "__main__":
    logging.basicConfig(
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
        level=logging.INFO
    )
    path_matcher = re.compile(r'\$\{([^}^{]+)\}')
    yaml.add_implicit_resolver('!path', path_matcher, None, yaml.loader.SafeLoader)
    yaml.add_constructor('!path', path_constructor, yaml.loader.SafeLoader)
    main(sys.argv[1:])