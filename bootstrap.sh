#!/bin/bash

# Bootstrap VM for kubernetes nodes

# Adding necessary steps to use containerd as CRI runtime
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system > /dev/null 2>&1

# Update the apt package index and install packages needed to use the Kubernetes apt repository
sudo apt-get update
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# Add Docker’s official GPG key:
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# set up the stable repository for docker / containerd
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 2>&1

# Install containerd
sudo apt-get update >/dev/null 2>&1
sudo apt-get install -y containerd > /dev/null 2>&1


# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd:
sudo systemctl restart containerd > /dev/null 2>&1

# Using the systemd cgroup driver
# Generate containerd config file
sudo containerd config default | tee /etc/containerd/config.toml
sudo sed -i 's/ SystemdCgroup = false/  SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd > /dev/null 2>&1


# Kubelet will fail to start if swap is enabled on the node.
# so diasbale swap
sudo swapoff -a

# and disable swap on startup in /etc/fstab
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Enable ssh password authentication
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
sudo systemctl reload sshd

# Update /etc/hosts file
# If you increase the node count, then add the new entries to this list
sudo cat >>/etc/hosts<<EOF
192.168.56.10   k8smaster.example.com     k8s-master
192.168.56.11   node-1.example.com    node-1
192.168.56.12   node-2.example.com    node-2
EOF