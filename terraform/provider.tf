provider "aws" {
  version    = "~>2.0"
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_region" "current" {}

# provider "kubernetes" {
#   config_path = "./kubeconfig"
# }
