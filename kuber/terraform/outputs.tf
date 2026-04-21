output "kuber_nodes" {
  value = {
    masters = {
      for name, vm in proxmox_vm_qemu.master :
      vm.name => {
        id  = vm.vmid
        ip  = vm.default_ipv4_address
      }
    }

    workers = {
      for name, vm in proxmox_vm_qemu.worker :
      vm.name => {
        id  = vm.vmid
        ip  = vm.default_ipv4_address
      }
    }
  }
}