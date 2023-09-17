data "aws_route53_zone" "main" {
  name = "duggineni.io."
}

data "aws_ssm_parameter" "ultron" {
  name = "/eywa/ultron"
}

locals {
  ultron = jsondecode(data.aws_ssm_parameter.ultron.value)
}
