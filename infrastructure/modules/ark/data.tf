data "aws_ssm_parameter" "ultron" {
  name = "/eywa/ultron"
}

locals {
  ultron = jsondecode(data.aws_ssm_parameter.ultron.value)
}
