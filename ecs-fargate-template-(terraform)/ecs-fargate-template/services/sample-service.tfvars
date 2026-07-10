#############################################
# ECS Cluster
#############################################

cluster_name = "shared-fargate-cluster-dev"

#############################################
# ECS Service
#############################################

service_name = "sample-service"

# Always use a fixed version/tag.
# Avoid using :latest in production.
image_uri = "xxxxxxxx.dkr.ecr.ap-south-1.amazonaws.com/sample-service:v1.0.0"

cpu            = 256
memory         = 512
container_port = 8080
desired_count  = 1

#############################################
# Runtime Platform
#############################################

cpu_architecture = "X86_64"

#############################################
# Networking
#############################################

# Security Groups allowed to reach the ECS Tasks.
# Populate with the Security Group(s) of your ALB/NLB.
ingress_security_group_ids = [
  "sg-xxxxxxxxxxxxxxxxx"
]

# Restrict outbound traffic as per your network policy.
# Replace with your VPC CIDR or specific endpoint CIDRs.
allowed_cidrs = [
  "10.0.0.0/16"
]

#############################################
# Environment Variables
#############################################

environment_variables = {
  APP_ENV = "dev"
}

#############################################
# Secrets
#############################################

secret_arns = {
  DB_PASSWORD = "arn:aws:secretsmanager:ap-south-1:123456789012:secret:db-password"
  JWT_SECRET  = "arn:aws:secretsmanager:ap-south-1:123456789012:secret:jwt-secret"
}

#############################################
# IAM
#############################################

task_role_arn = "arn:aws:iam::123456789012:role/sample-task-role"

execution_role_arn = "arn:aws:iam::123456789012:role/sample-execution-role"

#############################################
# Logging
#############################################

log_retention_days = 30

# Optional.
# Set to null if CloudWatch log encryption is not required.
kms_key_id = null

#############################################
# ECS Features
#############################################

enable_execute_command = false

readonly_root_filesystem = true

# Optional container health check.
# Set to null if not required.
health_check = {
  command = [
    "CMD-SHELL",
    "curl -f http://localhost:8080/health || exit 1"
  ]

  interval    = 30
  timeout     = 5
  retries     = 3
  startPeriod = 10
}

#############################################
# Tags
#############################################

tags = {
  Environment = "dev"
  Application = "sample-service"
  ManagedBy   = "Dev-team"
}