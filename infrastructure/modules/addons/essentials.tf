module "eks_blueprints_addons_essentials" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0" #ensure to update this to the latest/desired version

  cluster_name      = local.ultron.cluster_name
  cluster_endpoint  = local.ultron.cluster_endpoint
  cluster_version   = local.ultron.cluster_version
  oidc_provider_arn = local.ultron.oidc_provider_arn

  eks_addons = {
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_ingress_nginx = true
  enable_external_dns  = true
  enable_cert_manager  = true

  cert_manager_route53_hosted_zone_arns = ["arn:aws:route53:::hostedzone/${data.aws_route53_zone.main.zone_id}"]
  external_dns_route53_zone_arns        = ["arn:aws:route53:::hostedzone/${data.aws_route53_zone.main.zone_id}"]
}

resource "kubectl_manifest" "cluster_issuer" {
  depends_on = [module.eks_blueprints_addons_essentials]
  for_each   = toset(data.kubectl_path_documents.docs.documents)
  yaml_body  = each.value
}
