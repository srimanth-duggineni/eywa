module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "eywa"
  cidr = "13.0.0.0/16"

  azs             = ["ap-southeast-4a", "ap-southeast-4b"]
  private_subnets = ["13.0.1.0/24"]
  public_subnets  = ["13.0.2.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}
