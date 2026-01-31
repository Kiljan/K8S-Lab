#!/bin/bash
#
# sudo kubeadm init 
#
# set up after init
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#add auto completion
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null

#Weave Net install problem reported in new nf-tables (no longer works in ol10)
#kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

# Install calico from
# https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises#install-calico-with-kubernetes-api-datastore-50-nodes-or-less

