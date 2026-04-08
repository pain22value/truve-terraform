resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"

    labels = {
      "app.kubernetes.io/name" = "argocd"
    }
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = kubernetes_namespace_v1.argocd.metadata[0].name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.7.16"
  create_namespace = false

  timeout         = 600
  atomic          = true
  cleanup_on_fail = true

  values = [
    yamlencode({
      global = {
        affinity = {
          nodeAffinity = {
            requiredDuringSchedulingIgnoredDuringExecution = {
              nodeSelectorTerms = [
                {
                  matchExpressions = [
                    {
                      key      = "workload"
                      operator = "In"
                      values   = ["system"]
                    }
                  ]
                }
              ]
            }
          }
        }
      }

      tolerations = [
        {
          key      = "workload"
          operator = "Equal"
          value    = "system"
          effect   = "NoSchedule"
        }
      ]

      server = {
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace_v1.argocd]
}
