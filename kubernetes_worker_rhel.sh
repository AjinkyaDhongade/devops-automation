#!/bin/bash

# Add Kubernetes YUM Repository
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Disable SELinux (recommended for Kubernetes)
sudo setenforce 0
sudo sed -i --follow-symlinks 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Update the Package Database
sudo dnf clean all
sudo dnf makecache

# Install Kubernetes Components
sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Prevent these packages from being updated automatically
sudo dnf versionlock add kubelet kubeadm kubectl

# Enable and start kubelet
sudo systemctl enable --now kubelet


