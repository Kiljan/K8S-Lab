#!/bin/bash

# Install and configure prerequisites
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
net.ipv4.conf.all.rp_filter         = 0
net.ipv4.conf.default.rp_filter     = 0
EOF

# Apply sysctl params without reboot
sysctl --system

# Instal from docker repo
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install -y containerd.io  

# CNI install
sudo mkdir -p /opt/cni/bin
CNI_VERSION="v1.3.0"
wget https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz -O /tmp/cni.tgz
sudo tar -xzvf /tmp/cni.tgz -C /opt/cni/bin
sudo chmod +x /opt/cni/bin/*

# Enable containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl enable containerd.service
systemctl restart containerd.service

# -----------------------------------------------------------------------------------------
# kube install 
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet-1.28.2 kubeadm-1.28.2 kubectl-1.28.2 --disableexcludes=kubernetes --nogpgcheck

systemctl enable --now kubelet
systemctl restart kubelet

exit 0
