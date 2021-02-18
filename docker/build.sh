#!/bin/bash -l

# exit on error
set -e

source .env

# handle all non-zero exit status codes with a slack notification
trap 'handler $? $LINENO' EXIT

handler () {
    if [ "$1" != "0" ]; then
        printf "%b" "${OKB}Notifying slack channel of snap build failure.${NC}\n"
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"Snap build server job failed with exit status: $1 on line $2\"}" https://hooks.slack.com/services/"$SLACK_IDENTIFIER"
        printf "%b" "${OKG} ✓ ${NC}complete\n"
    fi
}

# Inject SHA into source
# SHA=$(git rev-parse --short HEAD)
# printf "%b" "${OKB}Injecting sha:${SHA} into source code${NC}"
# perl -pi -e 's/GIT_SHA = .*/GIT_SHA = "${SHA}"/g' ./monitor/__version__.py

# clean snapcraft build container
snapcraft clean;

# build snapcraft in using host container
printf "%b" "${OKB}Starting snap build on host container${NC}"
snapcraft --debug;
printf "%b" "${OKG} ✓ ${NC}complete"

# push .snap file to s3 bucket
printf "%b" "${OKB}Pushing $TARGET_FILE to S3 bucket $BUCKET as $OBJECT${NC}"
./s3_push.py -i "$TARGET_FILE" -o "$OBJECT" -b "$BUCKET"
printf "%b" "${OKG} ✓ ${NC}complete"

# Notify slack channel of build success
printf "%b" "${OKB}Notifying slack channel of snap build success.${NC}"
curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"Snap build server job complete. Download and install the snap file and the build logs here: https://s3.console.aws.amazon.com/s3/buckets/snapbuilds?region=ca-central-1&tab=objects\"}" https://hooks.slack.com/services/"$SLACK_IDENTIFIER"
printf "%b" "${OKG} ✓ ${NC}complete"
