data "terraform_remote_state" "network" {

  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.network_state_key
    region = var.aws_region
  }
}

data "terraform_remote_state" "security" {

  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.security_state_key
    region = var.aws_region
  }
}

data "terraform_remote_state" "nlb" {

  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.nlb_state_key
    region = var.aws_region
  }
}