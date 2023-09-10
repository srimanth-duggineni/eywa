terraform {
  backend "s3" {
    bucket                 = "srimanthd"
    key                    = "terraform/eywa/terraform.tfstate"
    region                 = "ap-southeast-2"
    skip_region_validation = true
  }
}
