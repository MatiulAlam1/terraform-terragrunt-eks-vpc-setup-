include {
  path = find_in_parent_folders()
}

locals {
  env        = "prod"
  cidr_block = "10.3.0.0/16"
  ami_id     = "ami-0c55b159cbfafe1f0"
}

terraform {
  source = "../../modules//"
}

inputs = {
  env           = local.env
  cidr_block    = local.cidr_block
  ami_id        = local.ami_id
  instance_type = "t2.micro"
}