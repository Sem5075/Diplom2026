resource "kubernetes_manifest" "metallb_app" {
  depends_on = [
    helm_release.argocd,
    kubernetes_secret.argocd_repo_1,
    kubernetes_secret.argocd_repo_2
  ]

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

resource "kubernetes_manifest" "apps_app" {
  depends_on = [kubernetes_manifest.envoy_gateway_app]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "apps"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.argocd_github_repo_url
        targetRevision = "HEAD"
        path           = "infra/apps"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = { prune = true, selfHeal = true }
        syncOptions = ["CreateNamespace=true", "ServerSideApply=true"]
      }
    }
  }
}