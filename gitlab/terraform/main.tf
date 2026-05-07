resource "proxmox_vm_qemu" "runner" { 

  name = "${var.vm_runner_prefix}"
  description = var.vm_description
  vmid = var.vm_id
  
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
    macaddr = format("BC:24:11:28:5D:%02X", 1)
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

  connection {
    type        = "ssh"
    user        = var.ci_user
    password    = var.ci_pass
    host        = self.default_ipv4_address
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      # Ждём cloud-init
      "sudo cloud-init status --wait",

      # Устанавливаем GitLab Runner
      "sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64",
      "sudo chmod +x /usr/local/bin/gitlab-runner",
      "sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash",
      "sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner",
      "sudo gitlab-runner start",

      # Регистрируем Runner
      "sudo gitlab-runner register --non-interactive --url '${var.gitlab_url}' --token '${var.gitlab_token}' --name '${var.vm_runner_prefix}' --executor 'shell' ",

      # Запускаем сервис
      "sudo systemctl enable --now gitlab-runner"
    ]
  }
}