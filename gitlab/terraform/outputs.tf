output "runner" {
  value = {
    id  = proxmox_vm_qemu.runner.vmid
    ip  = proxmox_vm_qemu.runner.default_ipv4_address
  }
}