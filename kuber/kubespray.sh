#!/bin/bash
ansible -m ping all -i inventory/mycluster/hosts.yaml \
|| { echo "Нет доступа к узлам"; exit 1; }
# Запуск Kubespray
docker run --rm \
  --mount type=bind,source="$(pwd)"/inventory/mycluster,dst=/inventory \
  --mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
  quay.io/kubespray/kubespray:v2.31.0 \
  ansible-playbook -vvv -i /inventory/hosts.yaml \
    --private-key /root/.ssh/id_rsa \
    --become cluster.yml