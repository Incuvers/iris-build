#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""
AWS S3 Uploader Script
======================
Modified: 2021-02

This script uploads files to AWS S3.
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
        opts, args = getopt.getopt(argv,"hi:o:b:",["input=","output=","bucket="])
    except getopt.GetoptError:
        logging.exception("test.py -i <inputfile> -o <outputfile> -b <bucket>")
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            logging.info("test.py -i <inputfile> -o <outputfile> -b <bucket>")
            sys.exit()
        elif opt in ("-i", "--input"):
            target_file = arg
        elif opt in ("-o", "--output"):
            obj = arg
        elif opt in ("-b", "--bucket"):
            bucket = arg

    logging.info("Input file: %s", target_file)
    logging.info("Output file: %s", obj)
    logging.info("Bucket: %s", bucket)

    s3 = boto3.client("s3",
        aws_access_key_id=os.environ['ACCESS_ID'],
        aws_secret_access_key=os.environ['ACCESS_KEY']
    )

    with open(target_file, "rb") as f:
        s3.upload_fileobj(f, bucket, obj)

    logging.info("S3 upload complete.")

if __name__ == "__main__":
    # bind logging to config file
    logging.basicConfig(
        level=logging.DEBUG,
        format="%(asctime)s %(levelname)s %(threadName)s %(name)s %(message)s"
    )
    logging.info("S3 uploader script")
    logging.info("------------------")
    main(sys.argv[1:])