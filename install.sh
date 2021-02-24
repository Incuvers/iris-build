#!/bin/bash -l

# TO ADD TO ANSIBLE PLAYBOOK FOR SERVER DEPLOYMENT
ssh-keygen -b 4096 -t rsa -f "$HOME"/.ssh/id_rsa -q -N ""

# install docker
curl -sSL https://get.docker.com | sh
# add user to docker group
sudo usermod -aG docker "$USER"
# reboot to apply user mode
sudo reboot