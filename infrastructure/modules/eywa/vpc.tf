module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "eywa"
  cidr = "13.0.0.0/16"

  azs             = ["ap-southeast-2a", "ap-southeast-2b"]
  private_subnets = ["13.0.2.0/24", "13.0.3.0/24"]
  public_subnets  = ["13.0.1.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "eywa" {
  name = "/eywa/vpc"
  type = "String"
  value = jsonencode({
    vpc_id          = module.vpc.vpc_id
    private_subnets = module.vpc.private_subnets
  })
}
