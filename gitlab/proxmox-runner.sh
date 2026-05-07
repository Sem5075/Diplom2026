#!/bin/bash
# Использование: ./proxmox-runner.sh start|stop [хост]
# По стандарту смотрит  работает с vmid 550 и сервер по dns proxmox
# Если переменные другие то надо указать все явно
# Пример ./proxmox-runners.sh start 999 root@192.168.1.1

ACTION="${1:?Укажи действие: start или stop}"
VMID="${2:-"550"}"
SSH_HOST="${3:-root@proxmox}"

echo "Действие: $ACTION"
echo "VM IDs: $VMID"
echo "Хост: $SSH_HOST"

ssh "$SSH_HOST" " qm $ACTION $VMID"