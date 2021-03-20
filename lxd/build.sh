#!/bin/bash -l
#
# Build iris-incuvers core20 snap for arm64 using lxd containers

# exit on error
set -e

source .env

# handle all non-zero exit status codes with a slack notification
trap 'handler $?' EXIT

handler () {
    if [ "$1" != "0" ]; then
        printf "%b" "${OKB}Notifying slack channel of snap build failure.${NC}\n"
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"Snap build server job failed with exit status: $1\"}" https://hooks.slack.com/services/"$SLACK_IDENTIFIER"
        printf "%b" "${OKG} ✓ ${NC}complete\n"
    fi
}
# examples:
# STAGE=https://api.prod.incuvers.com
# VERSION=0.1.7
# release version from monitor action instantiation
# update snapcraft.yaml version string

echo $VERSION
echo $STAGE

SNAP_ARCH="arm64"
# Required for aws s3 push script
TARGET_FILE="iris-incuvers_${VERSION}_${SNAP_ARCH}.snap"
BUCKET="snapbuilds"
OBJECT="iris-incuvers.snap"
exit 0
# clean snapcraft build container
printf "%b" "${OKB}Cleaning snap build artefacts${NC}\n"
snapcraft clean --use-lxd
rm -f -- *.snap
printf "%b" "${OKG} ✓ ${NC}complete\n"

# build snapcraft in using host container
printf "%b" "${OKB}Starting snap build on host container${NC}\n"
snapcraft --use-lxd --bind-ssh
printf "%b" "${OKG} ✓ ${NC}complete\n"

# push .snap file to s3 bucket
printf "%b" "${OKB}Pushing $TARGET_FILE to S3 bucket $BUCKET as $OBJECT${NC}\n"
./s3_push.py -i "$TARGET_FILE" -o "$OBJECT" -b "$BUCKET"
printf "%b" "${OKG} ✓ ${NC}complete\n"

# Notify slack channel of build success
printf "%b" "${OKB}Notifying slack channel of snap build success.${NC}\n"
curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"Snap build server job complete. Build logs: https://github.com/Incuvers/monitor/actions/workflows/iris.yml. Snap file: https://s3.console.aws.amazon.com/s3/buckets/snapbuilds?region=ca-central-1&tab=objects\"}" https://hooks.slack.com/services/"$SLACK_IDENTIFIER"
printf "%b" "${OKG} ✓ ${NC}complete"
