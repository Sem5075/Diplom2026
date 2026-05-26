resource "kubernetes_secret" "argocd_repo_1" {

  metadata {
    name      = "repo-github"
    namespace = "argocd"
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

  metadata {
    name      = "repo-gitlab"
    namespace = "argocd"
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

resource "kubernetes_manifest" "metallb_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "metallb"
      namespace = "argocd"
    }

    spec = {
      project = "default"
      source = {
        repoURL        = var.argocd_github_repo_url
        targetRevision = "HEAD"
        path           = "infra/metallb"           
        helm = { valueFiles = ["values.yaml"] }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "metallb"
      }
      syncPolicy = {
        automated = { prune = true, selfHeal = true }
        syncOptions = ["CreateNamespace=true", "ServerSideApply=true"]
        retry = {
          limit = 5
          backoff = { duration = "5s", factor = 2, maxDuration = "3m" }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "envoy_gateway_app" {
  depends_on = [kubernetes_manifest.metallb_app]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "envoy-gateway"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.argocd_github_repo_url
        targetRevision = "HEAD"
        path           = "infra/envoy-gateway"
        helm = {
          valueFiles = ["values.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "envoy-gateway-system"
      }
      syncPolicy = {
        automated = { prune = true, selfHeal = true }
        syncOptions = ["CreateNamespace=true", "ServerSideApply=true"]
        retry = {
          limit = 5
          backoff = { duration = "5s", factor = 2, maxDuration = "3m" }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "testapp" {
  depends_on = [kubernetes_manifest.metallb_app]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "testapp"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.argocd_gitlab_repo_url
        targetRevision = "HEAD"
        path           = "."
        helm = {
          valueFiles = ["values.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "testapp"
      }
      syncPolicy = {
        automated = { prune = true, selfHeal = true }
        syncOptions = ["CreateNamespace=true", "ServerSideApply=true"]
        retry = {
          limit = 5
          backoff = { duration = "5s", factor = 2, maxDuration = "3m" }
        }
      }
    }
  }
}