#!/bin/bash -l

# install docker
curl -sSL https://get.docker.com | sh
# add user to docker group
sudo usermod -aG docker "$USER"
# reboot to apply user mode
sudo reboot