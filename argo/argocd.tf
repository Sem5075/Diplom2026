resource "kubernetes_namespace" "argocd" {
  metadata { name = "argocd" }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  chart            = "${path.module}/argo-cd-9.5.5.tgz" 
  version          = var.argocd_chart_version
  timeout          = 600
  atomic           = true 
  create_namespace = false

  set = [                #сраный костыль так как блочат репы aws и ghcr, если не блочат то весь set в коммент 
    {
      name  = "redis.image.repository"
      value = "registry.semops.duckdns.org/sem5075/infratestrepo/redis"
    },
    {
    name  = "redis.image.tag"
    value = "8.2.3-alpine"
    },
    {
      name  = "dex.image.repository"
      value = "registry.semops.duckdns.org/sem5075/infratestrepo/dex"
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

resource "kubernetes_secret" "argocd_repo_1" {
  depends_on = [helm_release.argocd]

  metadata {
    name      = "repo-github"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = var.argocd_github_repo_url
    project  = "default"
  }

  type = "Opaque"
}

resource "kubernetes_secret" "argocd_repo_2" {
  depends_on = [helm_release.argocd]

  metadata {
    name      = "repo-gitlab"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = var.argocd_gitlab_repo_url
    project  = "default"
  }

  type = "Opaque"
}