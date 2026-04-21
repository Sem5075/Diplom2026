all:
  hosts:
%{ for vm in masters ~}
    ${vm.name}:
      ansible_host: ${vm.default_ipv4_address}
      ansible_user: ${ci_user}
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
      ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
%{ endfor ~}
%{ for vm in workers ~}
    ${vm.name}:
      ansible_host: ${vm.default_ipv4_address}
      ansible_user: ${ci_user}
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
      ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
%{ endfor ~}
  children:
    kube_control_plane:
      hosts:
%{ for vm in masters ~}
        ${vm.name}:
%{ endfor ~}
    kube_node:
      hosts:
%{ for vm in workers ~}
        ${vm.name}:
%{ endfor ~}
    etcd:
      hosts:
%{ for vm in masters ~}
        ${vm.name}:
%{ endfor ~}
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}