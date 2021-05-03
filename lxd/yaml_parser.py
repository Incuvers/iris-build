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
import os
import sys
import yaml
import getopt
import pprint
import logging

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
            # manual resolution of version and endpoint  
            snap['version'] = os.environ.get('VERSION')
            snap['apps']['monitor']['environment']['API_BASE_URL'] = os.environ.get('STAGE')
            logging.info('Saving to build directory')
            with open(snap_file, 'w') as outstream:
                yaml.dump(snap, outstream, default_flow_style=False)
        logging.info("Yaml parse complete:\n%s", pprint.pformat(snap))

if __name__ == "__main__":
    logging.basicConfig(
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
        level=logging.INFO
    )
    main(sys.argv[1:])