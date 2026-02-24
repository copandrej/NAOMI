#!/bin/bash
# Install sript for kubernetes on on-premise VM. NOT TESTED!

set -e
trap 'echo "System deployment script failed"; exit 1' ERR

VM_IP=localhost

# Enable addons
microk8s status --wait-ready
microk8s enable dns
microk8s enable storage
microk8s status --wait-ready

# Alias microk8s kubectl to kubectl, if kubectl not installed
# sudo snap alias microk8s.kubectl kubectl
microk8s config > $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config
echo "Waiting for system pods.."
kubectl wait --for=condition=ready pod -n kube-system --all --timeout=500s
echo "Done"
