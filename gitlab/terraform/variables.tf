variable "gitlab_token" {
  type      = string
  #sensitive = true
}

variable "gitlab_url" {
  type    = string
  default = "https://gitlab.semops.duckdns.org"
}

variable "gitlab_runner_tags" {
  type    = string
  default = "linux,docker"
}

variable "vm_cores" {
  default = 2
}

variable "vm_memory" {
  default = 4096
}

variable "vm_disk" {
  type = string
  default = "10G"
}

variable "vm_runner_prefix" {
  type = string
  default = "gitlab-runner"
}

variable "vm_description" {
  type = string 
  default = "Gitlab runner virtual machine"
}

variable "vm_id" {
  default = 550
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