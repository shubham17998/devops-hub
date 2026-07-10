locals {

  #############################################
  # Remote State Outputs
  #############################################

  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  nlb_sg_id = data.terraform_remote_state.security.outputs.nlb_sg_id

  #############################################
  # ECS Environment Variables
  #############################################

  environment_variables = jsonencode([
    for key, value in var.environment_variables : {
      name  = key
      value = value
    }
  ])

  #############################################
  # ECS Secrets
  #############################################

  secrets = jsonencode([
    for env_name, secret_arn in var.secret_arns : {
      name      = env_name
      valueFrom = secret_arn
    }
  ])

}