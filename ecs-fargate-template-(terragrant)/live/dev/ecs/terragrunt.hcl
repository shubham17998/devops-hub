# Root Configuration

include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Terraform Module

terraform {
  source = "../../../modules/ecs-fargate"
}

# Module Inputs

inputs = {

  # AWS
  
  aws_region = "ap-south-1"

  # Network
 
  vpc_id = "vpc-xxxxxxxx"

private_subnet_ids = [
  "subnet-aaaaaaaa",
  "subnet-bbbbbbbb"
]

alb_security_group_id = "sg-xxxxxxxx"

target_group_arn = "arn:aws:elasticloadbalancing:ap-south-1:123456789012:targetgroup/sample-tg/xxxxxxxx"

  # ECS
  
  cluster_name = "shared-fargate-cluster-dev"

  service_name = "sample-service"

  image_uri = "<ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/sample-service:v1.0.0"

  cpu    = 256
  memory = 512

  desired_count = 1

  container_port = 8080

  cpu_architecture = "X86_64"

  # Security
  
  allowed_cidrs = [
    "10.0.0.0/16"
  ]

  egress_protocol = "tcp"

  egress_from_port = 443

  egress_to_port = 443

  # Environment Variables
  
  environment_variables = {
    APP_ENV = "dev"
  }

  # Secrets
  
  secret_arns = {
    DB_PASSWORD = "arn:aws:secretsmanager:ap-south-1:123456789012:secret:db-password"
  }

  # IAM
  
  task_role_arn = "arn:aws:iam::123456789012:role/sample-task-role"

  execution_role_arn = "arn:aws:iam::123456789012:role/sample-execution-role"

  # Logging
  
  log_retention_days = 365

  kms_key_id = null

  # ECS Features

  enable_execute_command = false

  readonly_root_filesystem = true

  health_check = null

  # Tags

  tags = {
    Environment = "dev"
    ManagedBy   = "Terragrunt"
  }
}