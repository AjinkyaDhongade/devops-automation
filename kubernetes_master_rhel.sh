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

# Pull Kubernetes container images
sudo kubeadm config images pull

# Initialize Kubernetes Cluster (optional to customize pod-network-cidr)
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# Set up kubeconfig for the root user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Export KUBECONFIG (optional, usually needed for scripts)
export KUBECONFIG=/etc/kubernetes/admin.conf

# Install Calico CNI plugin
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/calico.yaml

# Allow pods to be scheduled on control plane (optional for single-node clusters)
#kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# --------------------------------------------------------------------
# Enable kubectl autocompletion for bash
# --------------------------------------------------------------------

# This sets up autocomplete for the current shell session (requires bash-completion package)
source <(kubectl completion bash)

# This ensures autocomplete is available in future sessions
echo "source <(kubectl completion bash)" >> ~/.bashrc

