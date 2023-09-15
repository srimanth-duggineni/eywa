data "aws_route53_zone" "main" {
  name = "duggineni.io."
}

data "aws_ssm_parameter" "ultron" {
  name = "/eywa/ultron"
}

data "aws_eks_cluster_auth" "cluster-auth" {
  name = local.ultron.cluster_name
}

locals {
  ultron = jsondecode(data.aws_ssm_parameter.ultron.value)
}

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

provider "kubernetes" {
  host                   = local.ultron.cluster_endpoint
  cluster_ca_certificate = base64decode(local.ultron.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", local.ultron.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = local.ultron.cluster_endpoint
    cluster_ca_certificate = base64decode(local.ultron.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", local.ultron.cluster_name]
    }
  }
}
