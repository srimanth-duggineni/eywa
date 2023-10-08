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

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/aws-service-role/AmazonEKSServiceRolePolicy"
    }
  }

  self_managed_node_groups = {
    alpha = {
      dsad = "dsd"
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
      userarn  = "arn:aws:iam::${var.account}:user/srimanthd"
      username = "srimanthd"
      groups   = ["system:masters"]
    },
  ]

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
