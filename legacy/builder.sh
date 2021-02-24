#!/bin/bash

PRIVATE_KEY=$(< "$HOME"/.ssh/id_rsa)

docker build --no-cache --build-arg SSH_PRIVATE_KEY="$PRIVATE_KEY" docker/.