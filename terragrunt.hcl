locals {
  region = "ap-south-1"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "my-terraform-states-ap-south-1"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
