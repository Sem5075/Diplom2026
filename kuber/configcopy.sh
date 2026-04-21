#!/bin/bash
 
MASTER_NAME=$(grep -A2 'kube_control_plane:' $(pwd)/inventory/mycluster/hosts.yaml | grep -A1 'hosts:' | tail -1 | tr -d ' :')
MASTER_HOST=$(grep -A1 "${MASTER_NAME}:" $(pwd)/inventory/mycluster/hosts.yaml | grep 'ansible_host' | awk '{print $2}')
SSH_USER=$(grep -A2 "${MASTER_NAME}:" $(pwd)/inventory/mycluster/hosts.yaml | grep 'ansible_user' | awk '{print $2}')

# Копирование kubeconfig с мастера
ssh ${SSH_USER}@${MASTER_HOST} "sudo cat /etc/kubernetes/admin.conf" 1> kubeconfig/admin.conf
sed -i "s/127.0.0.1/$MASTER_HOST/" kubeconfig/admin.conf
echo "Done! kubeconfig сохранён"