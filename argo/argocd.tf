resource "kubernetes_namespace" "argocd" {
  metadata { name = "argocd" }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = kubernetes_namespace.argocd.metadata[0].name 
  chart            = "${path.module}/argo-cd-9.5.5.tgz" #Либо repository = "https://argoproj.github.io/argo-helm" и chart = "argo-cd"
  version          = var.argocd_chart_version
  timeout          = 600
  atomic           = true 
  create_namespace = false

  set = [                #сраный костыль так как блочат репы aws и ghcr, если не блочат то весь set в коммент 
    {
      name  = "redis.image.repository"
      value = "library/redis"
    },
    {
    name  = "redis.image.tag"
    value = "8.2.3-alpine"
    },
    {
      name  = "dex.image.repository"
      value = "dexidp/dex"
    },
    {
    name  = "dex.image.tag"
    value = "v2.45.1"
    }
  ]
  
  

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

