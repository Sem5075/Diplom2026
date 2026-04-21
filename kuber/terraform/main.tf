resource "proxmox_vm_qemu" "master" {
  count = var.vm_master_count

  name = "${var.vm_master_prefix}-${count.index + 1}"
  description = var.vm_description
  vmid = var.vm_id + count.index
  
  agent = 1
  target_node = "pve"
  clone = "ubuntu-server-test"

  cpu {
    cores = var.vm_cores
    sockets = 1
    type = "host"
  }

  memory = var.vm_memory

  network {
    id = 0
    bridge = "vmbr0"
    model = "virtio"
    macaddr = format("BC:24:11:28:5E:%02X", count.index + 1)
  }
  
  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size = var.vm_disk
          storage = "local-lvm"
        }
      }
    }
  }

  skip_ipv6 = true
  bootdisk = "scsi0"
  boot = "order=scsi0;net0"
  os_type = "cloud-init"
  nameserver = "8.8.8.8"
  ciuser = var.ci_user 
  cipassword = var.ci_pass
  ipconfig0 =  "ip=dhcp"
  sshkeys = file(var.ssh_public_key)
}

resource "proxmox_vm_qemu" "worker" {
  count = var.vm_worker_count

  name = "${var.vm_worker_prefix}-${count.index + 1}"
  description = var.vm_description
  vmid = var.vm_id + count.index + var.vm_master_count
  
  agent = 1
  target_node = "pve"
  clone = "ubuntu-server-test"

  cpu {
    cores = var.vm_cores
    sockets = 1
    type = "host"
  }

  memory = var.vm_memory

  network {
    id = 0
    bridge = "vmbr0"
    model = "virtio"
    macaddr = format("BC:24:11:28:5E:%02X", count.index + var.vm_master_count+ 1)
  }
  
  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size = var.vm_disk
          storage = "local-lvm"
        }
      }
    }
  }

  skip_ipv6 = true
  bootdisk = "scsi0"
  boot = "order=scsi0;net0"
  os_type = "cloud-init"
  nameserver = "8.8.8.8"
  ciuser = var.ci_user 
  cipassword = var.ci_pass
  ipconfig0 =  "ip=dhcp"
  sshkeys = file(var.ssh_public_key)
}

resource "local_file" "kubespray_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    masters = proxmox_vm_qemu.master
    workers = proxmox_vm_qemu.worker
    ci_user = var.ci_user 
  })

  filename = "${path.module}/../inventory/mycluster/hosts.yaml"
}

resource "local_file" "vm_ids" {
  content  = join("\n", concat(
    [for vm in proxmox_vm_qemu.master : "${vm.name}=${vm.vmid}"],
    [for vm in proxmox_vm_qemu.worker : "${vm.name}=${vm.vmid}"]
  )) 
  filename = "${path.module}/../inventory/vm_ids.env"
}