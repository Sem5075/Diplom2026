#!/bin/bash
# Использование: ./proxmox-vms.sh start|stop [файл] [хост]
# По стандарту смотрит файл inventory/mycluster/vm_ids.env и сервер по dns proxmox
# Если переменные другие то надо указать все явно
# Пример ./proxmox-vms.sh start vms_ids.env root@192.168.1.1

ACTION="${1:?Укажи действие: start или stop}"
VM_FILE="${2:-inventory/mycluster/vm_ids.env}"
SSH_HOST="${3:-root@proxmox}"

# Cписок VMID из файла (формат: name=vmid)
VMIDS=$(grep -v '^\s*#' "$VM_FILE" | grep -v '^\s*$' | cut -d'=' -f2 | tr '\n' ' ')

echo "Действие: $ACTION"
echo "VM IDs: $VMIDS"
echo "Хост: $SSH_HOST"

ssh "$SSH_HOST" "for vmid in $VMIDS; do qm $ACTION \$vmid; done"