#!/bin/bash
# connect to master node
kubeadm join 192.168.31.90:6443 --token h8vscv.iie2683m4yfgsx2v --discovery-token-ca-cert-hash sha256:654191fd62e59e649a401f91e2b6f869c10c8da85408e3fa279362f4c283b078
