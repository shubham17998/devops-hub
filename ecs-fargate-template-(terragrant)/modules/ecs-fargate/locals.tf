# Environment Variables

locals {

  environment_variables = jsonencode([
    for key, value in var.environment_variables : {
      name  = key
      value = value
    }
  ])

  secrets = jsonencode([
    for env_name, secret_arn in var.secret_arns : {
      name      = env_name
      valueFrom = secret_arn
    }
  ])

}