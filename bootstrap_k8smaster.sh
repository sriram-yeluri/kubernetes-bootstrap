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

#[preflight] Pulling images required for setting up a Kubernetes cluster
kubeadm config images pull

# Initialize the cluster
kubeadm init --apiserver-advertise-address="192.168.56.10" --apiserver-cert-extra-sans="192.168.56.10"  --node-name k8s-master --pod-network-cidr=192.168.0.0/16 >> /kubeinit.log 2>/dev/null

# To start using your cluster, you need to run the following as a regular user
# To make kubectl work for your non-root user, run these commands, which are also part of the kubeadm init output
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install calico pod network
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
# kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml >/dev/null 2>&1

# Generate kubeadm join token 
kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null

