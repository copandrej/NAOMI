#!/bin/bash

# append this string to /boot/firmware/cmdline.txt for microk8s to work
if ! grep -q "cgroup_enable=memory cgroup_memory=1" /boot/firmware/cmdline.txt; then
  sudo sed -i '$ s/$/ cgroup_enable=memory cgroup_memory=1/' /boot/firmware/cmdline.txt
fi

# install microk8s
sudo apt update && sudo apt upgrade -y && sudo apt install snapd -y &&
sudo snap install microk8s --classic --channel=1.35/stable &&
sleep 10
sudo usermod -a -G microk8s $USER &&
sudo chown -f -R $USER ~/.kube &&

# need to test if adding to path is needed maybe just reboot or restart/source shell
export PATH=$PATH:/snap/bin
if ! grep -q "PATH=$PATH:/snap/bin" ~/.bashrc; then
  echo "PATH=$PATH:/snap/bin" >> ~/.bashrc
fi

# add/repair dns
sudo apt-get install systemd-resolved -y &&
sudo systemctl restart systemd-resolved &&
sleep 20 # allow things to settle

echo "Install script finished"
echo "Add a hostname of this node: " $(hostname) " and IPv4: " $(hostname -I)" to /etc/hosts on head node!"
echo "Then run:< microk8s.add-node > on head node, and connect this node to cluster"
newgrp microk8s
