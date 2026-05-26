variable "kubeconfig_path" {
  default = "../kuber/kubeconfig/admin.conf"
}

variable "kube_context" {
  default = "kubernetes-admin@cluster.local"
}

variable "argocd_github_repo_url" {
  default = "https://github.com/Sem5075/Diplom2026.git"
}

variable "argocd_gitlab_repo_url" {
  default = "https://gitlab.semops.ru/Sem5075/testapp.git"
}