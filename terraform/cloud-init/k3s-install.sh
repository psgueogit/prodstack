#!/bin/bash
set -e

# Update system
apt-get update -y
apt-get upgrade -y

# Install k3s
curl -sfL https://get.k3s.io | sh -

# Wait for k3s to be ready
sleep 30

# Make kubeconfig readable
chmod 644 /etc/rancher/k3s/k3s.yaml