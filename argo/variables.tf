variable "kubeconfig_path" {
  default = "../kuber/kubeconfig/admin.conf"
}

variable "kube_context" {
  default = "kubernetes-admin@cluster.local"
}

variable "argocd_chart_version" {
  default = "9.5.2"
}

variable "argocd_admin_password_bcrypt" {
  default = ""  # пустой = случайный пароль, смотреть в secret
  sensitive   = true
}