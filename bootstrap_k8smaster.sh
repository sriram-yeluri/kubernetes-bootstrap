#!/bin/bash

# Download the Google Cloud public signing key
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version
echo "[ * ] Update apt package index, install kubelet, kubeadm and kubectl, and pin their version"
sudo apt-get update > /dev/null 2>&1
sudo apt-get install -y kubelet kubeadm kubectl > /dev/null 2>&1
sudo apt-mark hold kubelet kubeadm kubectl > /dev/null 2>&1

# Set root password
echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
echo "export TERM=xterm" >> /etc/bash.bashrc