#!/bin/bash

# kubeadm init
kubeadm init --kubernetes-version=v1.10.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=172.31.50.215

# init_cluster_user
mkdir -p $HOME/.kube
sudo cp -rf /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# dns & flannel
kubectl create -f ./config/kube-flannel.yml
kubectl create -f ./config/kube-flannel-rabc.yml

# dashboard
kubectl create -f ./config/kubernetes-dashboard.yaml
kubectl create -f ./config/kubernetes-dashboard-admin.rbac.yaml
kubectl create -f ./config/heapster.yaml
kubectl create -f ./config/heapster-rbac.yaml
kubectl create -f ./config/grafana.yaml
kubectl create -f ./config/influxdb.yaml

# helm
#kubectl create -f ./config/helm-rbac-config.yaml
#helm init --service-account tiller --skip-refresh
