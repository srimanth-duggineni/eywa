provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

resource "aws_ssm_parameter" "ultron" {
  name = "/eywa/ultron"
  type = "String"
  value = jsonencode({
    cluster_name                       = module.eks.cluster_name
    cluster_endpoint                   = module.eks.cluster_endpoint
    cluster_version                    = module.eks.cluster_version
    oidc_provider_arn                  = module.eks.oidc_provider_arn
    cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  })
}
