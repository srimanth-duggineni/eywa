resource "helm_release" "ark" {
  name   = "ark"
  atomic = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  namespace        = "ark"
  create_namespace = true

  values = [
    "${file("values.argo-cd.yaml")}"
  ]
}
