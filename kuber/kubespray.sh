#!/bin/bash
# Запуск Kubespray
docker run --rm \
  --mount type=bind,source="$(pwd)"/inventory/mycluster,dst=/inventory \
  --mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
  quay.io/kubespray/kubespray:v2.30.0 \
  ansible-playbook -i /inventory/hosts.yaml \
    --private-key /root/.ssh/id_rsa \
    --become cluster.yml
 