variable "vm_master_count" {
  default = 1
}

variable "vm_worker_count" {
  default = 2
}

variable "vm_cores" {
  default = 2
}

variable "vm_memory" {
  default = 4096
}

variable "vm_disk" {
  type = string
  default = "20G"
}

variable "vm_master_prefix" {
  type = string
  default = "kuber-master"
}
variable "vm_worker_prefix" {
  type = string
  default = "kuber-worker"
}

variable "vm_description" {
  type = string 
  default = "Kubernetes cluster virtual machine"
}

variable "vm_id" {
  default = 500
}

variable "ci_user" {
  type = string
  sensitive = true
}

variable "ci_pass" {
  type = string
  sensitive = true
}

variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type = string
  sensitive = true
}

variable "ssh_public_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
  sensitive = true
}