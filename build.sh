#!/bin/bash -l

source .env

# Inject SHA into source
# SHA=$(git rev-parse --short HEAD)
# printf "%b" "${OKB}Injecting sha:${SHA} into source code${NC}"
# perl -pi -e 's/GIT_SHA = .*/GIT_SHA = "${SHA}"/g' ./monitor/__version__.py

# clean snapcraft build container
snapcraft clean;

# build snapcraft in lxc container
snapcraft --debug;

# push .snap file to s3 bucket
./s3_push.py -i $TARGET_FILE -o $OBJECT -b $BUCKET