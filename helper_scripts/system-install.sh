#!/bin/bash
# Install script for microk8s + runs system deployment script

# Install microk8s
sudo apt update && sudo apt upgrade -y && sudo apt install snapd -y
sudo snap install microk8s --classic --channel=1.35/stable
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube

# Running system-deploy.sh with new group for microk8s to work
sg microk8s -c "bash ./helper_scripts/system-deploy.sh"
newgrp microk8s
