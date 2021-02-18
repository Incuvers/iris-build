#!/bin/bash -l

sudo apt update
# add Docker repository to APT sources:
sudo apt install apt-transport-https ca-certificates curl software-properties-common
# add the GPG key for the official Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# add the Docker repository to APT sources
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
# add update apt cache
sudo apt update
# verify install from the Docker repo instead of the default Ubuntu repo
apt-cache policy docker-ce
# install docker
sudo apt install docker-ce
# add user to docker group
sudo usermod -aG docker "$USER"
# reboot to apply user mode
sudo reboot