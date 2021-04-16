#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""
AWS S3 Downloader Script
========================
Modified: 2021-02
This script downloads files from AWS S3.
"""
import sys
import getopt
import os
import logging
import boto3

def main(argv):
    target_file = ''
    obj = ''
    bucket = ''
    try:
        opts, args = getopt.getopt(argv,"ht:o:b:",["target=","output=","bucket="])
    except getopt.GetoptError:
        logging.exception("test.py -t <target> -o <outputfile> -b <bucket>")
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            logging.info("test.py -t <target> -o <outputfile> -b <bucket>")
            sys.exit()
        elif opt in ("-t", "--target"):
            target_file = arg
        elif opt in ("-o", "--output"):
            obj = arg
        elif opt in ("-b", "--bucket"):
            bucket = arg

    logging.info("Target file: %s", target_file)
    logging.info("Output file: %s", obj)
    logging.info("Bucket: %s", bucket)

    s3 = boto3.client(
        "s3",
        aws_access_key_id=os.environ['ACCESS_ID'],
        aws_secret_access_key=os.environ['ACCESS_KEY']
    )

    s3.download_file(bucket, target_file, obj) # last argument is filename to save as

    logging.info("S3 download complete.")

if __name__ == "__main__":
    # bind logging to config file
    logging.basicConfig(
        level=logging.DEBUG,
        format="%(asctime)s %(levelname)s %(threadName)s %(name)s %(message)s"
    )
    logging.info("S3 downloader script")
    logging.info("--------------------")
    main(sys.argv[1:])
