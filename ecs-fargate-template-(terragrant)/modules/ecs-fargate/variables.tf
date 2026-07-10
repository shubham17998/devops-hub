# ECS Cluster

variable "cluster_name" {
  description = "Name of the ECS Cluster."

  type = string

  validation {
    condition     = length(trimspace(var.cluster_name)) > 0
    error_message = "cluster_name cannot be empty."
  }
}

# ECS Service

variable "service_name" {
  description = "Name of the ECS Service."

  type = string

  validation {
    condition     = length(trimspace(var.service_name)) > 0
    error_message = "service_name cannot be empty."
  }
}

variable "image_uri" {
  description = "Container image URI."

  type = string

  validation {
    condition     = length(trimspace(var.image_uri)) > 0
    error_message = "image_uri cannot be empty."
  }
}

variable "cpu" {
  description = "CPU units for the ECS Task."

  type = number

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.cpu)
    error_message = "cpu must be one of: 256, 512, 1024, 2048 or 4096."
  }
}

variable "memory" {
  description = "Memory (MiB) allocated to the ECS Task."

  type = number

  validation {
    condition     = var.memory >= 512
    error_message = "memory must be at least 512 MiB."
  }
}

variable "container_port" {
  description = "Container port exposed by the application."

  type = number

  validation {
    condition     = var.container_port > 0 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}

variable "desired_count" {
  description = "Desired number of ECS tasks."

  type    = number
  default = 1

  validation {
    condition     = var.desired_count >= 1
    error_message = "desired_count must be greater than or equal to 1."
  }
}

# Runtime Platform

variable "cpu_architecture" {
  description = "CPU architecture for ECS runtime."

  type    = string
  default = "X86_64"

  validation {
    condition     = contains(["X86_64", "ARM64"], var.cpu_architecture)
    error_message = "cpu_architecture must be either X86_64 or ARM64."
  }
}

# IAM

variable "task_role_arn" {
  description = "IAM Role ARN assumed by the application."

  type = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.*", var.task_role_arn))
    error_message = "task_role_arn must be a valid IAM Role ARN."
  }
}

variable "execution_role_arn" {
  description = "IAM Role ARN used by ECS to pull images and publish logs."

  type = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.*", var.execution_role_arn))
    error_message = "execution_role_arn must be a valid IAM Role ARN."
  }
}

# Networking

variable "allowed_cidrs" {
  description = "Allowed outbound CIDR ranges."

  type = list(string)

  default = []
}

# Environment Variables

variable "environment_variables" {
  description = "Environment variables passed to the container."

  type    = map(string)
  default = {}
}

# Secrets

variable "secret_arns" {
  description = "Map of environment variable names to Secrets Manager ARNs."

  type    = map(string)
  default = {}
}

# Logging

variable "log_retention_days" {
  description = "CloudWatch log retention in days."

  type = number

  default = 365

  validation {
    condition     = var.log_retention_days >= 365
    error_message = "CloudWatch log retention must be at least 365 days."
  }
}

variable "kms_key_id" {
  description = "Optional KMS Key ARN/ID used to encrypt CloudWatch Log Groups."

  type    = string
  default = null
}

# ECS Features

variable "enable_execute_command" {
  description = "Enable ECS Exec."

  type    = bool
  default = false
}

variable "readonly_root_filesystem" {
  description = "Mount the container root filesystem as read-only."

  type    = bool
  default = true
}

variable "health_check" {
  description = "Container health check configuration."

  type = object({
    command     = list(string)
    interval    = number
    timeout     = number
    retries     = number
    startPeriod = number
  })

  default = null
}

# AWS

variable "aws_region" {
  description = "AWS Region."

  type = string
}

# Networking

variable "vpc_id" {
  description = "VPC where ECS will be deployed."

  type = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by ECS."

  type = list(string)
}

variable "alb_security_group_id" {
  description = "Security Group ID of the existing Application Load Balancer."

  type = string
}

variable "target_group_arn" {
  description = "Target Group ARN associated with the ALB."

  type = string
}

# Egress Configuration

variable "egress_protocol" {
  description = "Outbound protocol."

  type = string

  default = "tcp"

  validation {
    condition     = contains(["tcp", "udp"], var.egress_protocol)
    error_message = "egress_protocol must be tcp or udp."
  }
}

variable "egress_from_port" {
  description = "Outbound start port."

  type = number

  default = 443
}

variable "egress_to_port" {
  description = "Outbound end port."

  type = number

  default = 443
}

# Common Tags

variable "tags" {
  description = "Tags applied to all AWS resources."

  type    = map(string)
  default = {}
}