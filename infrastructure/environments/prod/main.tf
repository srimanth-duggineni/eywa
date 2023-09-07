terraform {
  backend "s3" {
    bucket         = "srimanthduggineni"
    key            = "terraform/eywa/terraform.tfstate"
    region         = "ap-southeast-4"
    skip_region_validation = true
  }
}
