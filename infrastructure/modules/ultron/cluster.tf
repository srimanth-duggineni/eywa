data "aws_ssm_parameter" "eywa" {
  name = "/eywa/vpc"
}

locals {
  eywa = jsondecode(data.aws_ssm_parameter.eywa.value)
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "ultron"
  cluster_version = "1.27"

  cluster_endpoint_public_access = true

  vpc_id                   = local.eywa.vpc_id
  subnet_ids               = local.eywa.private_subnets
  control_plane_subnet_ids = local.eywa.private_subnets

  self_managed_node_groups = {
    alpha = {
      name          = "alpha"
      instance_type = "m7g.xlarge"
      ami_id        = "ami-00d2c979c4338a8b4"
      max_size      = 1
      desired_size  = 1
    }
  }

  kms_key_owners = ["arn:aws:iam::${var.account}:root", "arn:aws:iam::${var.account}:role/eywa-admin"]

  # aws-auth configmap
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${var.account}:role/eywa-admin"
      username = "eywa-admin"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${var.account}:root"
      username = "root"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::${var.account}:srimanthduggineni"
      username = "srimanthduggineni"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::${var.account}:srimanthd"
      username = "srimanthd"
      groups   = ["system:masters"]
    },
  ]

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

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
