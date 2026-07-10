# Root Terragrunt Configuration

locals {
  aws_region = "ap-south-1"
}

# Remote State

remote_state {

  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {

    bucket = get_env("TG_STATE_BUCKET")

    key = "${path_relative_to_include()}/terraform.tfstate"

    region = local.aws_region

    encrypt = true

    use_lockfile = true

  }
}

# Generate AWS Provider

generate "provider" {

  path      = "provider.tf"

  if_exists = "overwrite"

  contents = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF

}