include {
  path = find_in_parent_folders()
}

locals {
  env        = "test"
  cidr_block = "10.2.0.0/16"
  ami_id     = "ami-0d54604676873b4ec" 
  my_ip      = "103.197.206.34/32"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnJtvewJpLA+Xiz+mX8Vf54nnLUT8QwIuQMso3icx/c Bjit@10310-Matiul-Alam"
}

terraform {
  source = "../../modules//"
}

inputs = {
  env           = local.env
  cidr_block    = local.cidr_block
  ami_id        = local.ami_id
  instance_type = "t2.micro"
  my_ip         = local.my_ip
  public_key    = local.public_key
}