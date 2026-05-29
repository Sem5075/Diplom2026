variable "kubeconfig_path" {
  default = "../kuber/kubeconfig/admin.conf"
}

variable "kube_context" {
  default = "kubernetes-admin@cluster.local"
}

variable "argocd_gitops_repo_url" {
  default = "https://gitlab.semops.ru/Sem5075/infratestrepo.git"
}
