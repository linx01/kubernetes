#!/bin/bash

# shutdown
kubeadm reset

# delete the cni0 and flannel.1
nmcli device delete cni0
nmcli device delete flannel.1

