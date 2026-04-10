resource "proxmox_vm_qemu" "vm" {
  count = var.vm_count
  name = "${var.vm_name_prefix}-${count.index + 1}"
  description = var.vm_description
  vmid = var.vm_id + count.index
  target_node = "pve"
  agent = 1
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
output "vm_ip" {
  value = [
    for vm in proxmox_vm_qemu.vm:
    vm.default_ipv4_address
    ]
}
