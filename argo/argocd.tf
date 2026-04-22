resource "kubernetes_namespace" "argocd" {
  metadata { name = "argocd" }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  timeout          = 900
  atomic           = true
  create_namespace = false

  values = concat(
    [file("${path.module}/argocd-values.yaml")],
    var.argocd_admin_password_bcrypt == "" ? [] : [
      yamlencode({
        configs = {
          secret = {
            argocdServerAdminPassword = var.argocd_admin_password_bcrypt
          }
        }
      })
    ]
  )
}