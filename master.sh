#!/bin/bash

function load_docker_tar(){
    # docker cgroup driver
    cp -rf ./config/docker.service /usr/lib/systemd/system/
    systemctl daemon-reload
    systemctl restart docker.service

    content=`cd images && ls`
    for c in ${content}
    do 
    docker load -i ./images/${c}
    done
}

function pull_docker_images(){
    
    # docker source
    cp -rf ./config/daemon.json /etc/docker/ 
    # docker cgroup driver
    cp -rf ./config/docker.service /usr/lib/systemd/system/
    systemctl daemon-reload
    systemctl restart docker.service
    
    # master
    docker pull cnych/kube-apiserver-amd64:v1.10.0
    docker pull cnych/kube-scheduler-amd64:v1.10.0
    docker pull cnych/kube-controller-manager-amd64:v1.10.0
    docker pull cnych/kube-proxy-amd64:v1.10.0
    docker pull cnych/k8s-dns-kube-dns-amd64:1.14.8
    docker pull cnych/k8s-dns-dnsmasq-nanny-amd64:1.14.8
    docker pull cnych/k8s-dns-sidecar-amd64:1.14.8
    docker pull cnych/etcd-amd64:3.1.12
    docker pull cnych/flannel:v0.10.0-amd64
    docker pull cnych/pause-amd64:3.1

    docker tag cnych/kube-apiserver-amd64:v1.10.0 k8s.gcr.io/kube-apiserver-amd64:v1.10.0
    docker tag cnych/kube-scheduler-amd64:v1.10.0 k8s.gcr.io/kube-scheduler-amd64:v1.10.0
    docker tag cnych/kube-controller-manager-amd64:v1.10.0 k8s.gcr.io/kube-controller-manager-amd64:v1.10.0
    docker tag cnych/kube-proxy-amd64:v1.10.0 k8s.gcr.io/kube-proxy-amd64:v1.10.0
    docker tag cnych/k8s-dns-kube-dns-amd64:1.14.8 k8s.gcr.io/k8s-dns-kube-dns-amd64:1.14.8
    docker tag cnych/k8s-dns-dnsmasq-nanny-amd64:1.14.8 k8s.gcr.io/k8s-dns-dnsmasq-nanny-amd64:1.14.8
    docker tag cnych/k8s-dns-sidecar-amd64:1.14.8 k8s.gcr.io/k8s-dns-sidecar-amd64:1.14.8
    docker tag cnych/etcd-amd64:3.1.12 k8s.gcr.io/etcd-amd64:3.1.12
    docker tag cnych/flannel:v0.10.0-amd64 quay.io/coreos/flannel:v0.10.0-amd64
    docker tag cnych/pause-amd64:3.1 k8s.gcr.io/pause-amd64:3.1
    
    # node
    docker pull cnych/kubernetes-dashboard-amd64:v1.8.3
    docker pull cnych/heapster-influxdb-amd64:v1.3.3
    docker pull cnych/heapster-grafana-amd64:v4.4.3
    docker pull cnych/heapster-amd64:v1.4.2
    docker tag cnych/kubernetes-dashboard-amd64:v1.8.3 k8s.gcr.io/kubernetes-dashboard-amd64:v1.8.3
    docker tag cnych/heapster-influxdb-amd64:v1.3.3 k8s.gcr.io/heapster-influxdb-amd64:v1.3.3
    docker tag cnych/heapster-grafana-amd64:v4.4.3 k8s.gcr.io/heapster-grafana-amd64:v4.4.3
    docker tag cnych/heapster-amd64:v1.4.2 k8s.gcr.io/heapster-amd64:v1.4.2

}

function install_kubernets(){
    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
        http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
    yum makecache fast 
    yum install -y kubelet-1.10.0-0
    yum install -y kubectl-1.10.0-0
    yum install -y kubeadm-1.10.0-0
    # kubelet config
    cp -rf ./config/10-kubeadm.conf /etc/systemd/system/kubelet.service.d/
    systemctl daemon-reload
    systemctl restart kubelet
    
}

function init(){
    # firewalld
    systemctl stop firewalld
    systemctl disable firewalld
    # selinux
    cp -rf ./config/config /etc/selinux/
    setenforce 0
    # k8s.conf
    cp -rf ./config/k8s.conf /etc/sysctl.d/
    modprobe br_netfilter
    sysctl -p /etc/sysctl.d/k8s.conf
    # turn off swap
    swapoff -a
    # hostname
    sudo hostnamectl  set-hostname "master"
}

init
# pull_docker_images
load_docker_tar
install_kubernets

systemctl enable kubelet.service
systemctl enable docker.service



