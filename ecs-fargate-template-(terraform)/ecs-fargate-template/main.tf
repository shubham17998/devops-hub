module "ecs_fargate" {

  source = "./modules/ecs-fargate"

  #############################################
  # Remote State Configuration
  #############################################

  aws_region         = var.aws_region
  state_bucket       = var.state_bucket
  network_state_key  = var.network_state_key
  security_state_key = var.security_state_key
  nlb_state_key      = var.nlb_state_key

  #############################################
  # ECS Cluster
  #############################################

  cluster_name = var.cluster_name

  #############################################
  # ECS Service
  #############################################

  service_name   = var.service_name
  image_uri      = var.image_uri
  cpu            = var.cpu
  memory         = var.memory
  container_port = var.container_port
  desired_count  = var.desired_count

  #############################################
  # Runtime Platform
  #############################################

  cpu_architecture = var.cpu_architecture

  #############################################
  # Networking
  #############################################

  ingress_security_group_ids = var.ingress_security_group_ids
  allowed_cidrs              = var.allowed_cidrs

  #############################################
  # Environment Variables
  #############################################

  environment_variables = var.environment_variables

  #############################################
  # Secrets
  #############################################

  secret_arns = var.secret_arns

  #############################################
  # IAM
  #############################################

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn

  #############################################
  # Logging
  #############################################

  log_retention_days = var.log_retention_days
  kms_key_id         = var.kms_key_id

  #############################################
  # ECS Features
  #############################################

  enable_execute_command   = var.enable_execute_command
  readonly_root_filesystem = var.readonly_root_filesystem
  health_check             = var.health_check

  #############################################
  # Common Tags
  #############################################

  tags = var.tags
}