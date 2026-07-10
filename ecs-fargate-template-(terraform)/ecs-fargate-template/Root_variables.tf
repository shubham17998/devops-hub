#############################################
# Remote State Configuration
#############################################

variable "aws_region" {
  description = "AWS Region where resources will be deployed."
  type        = string
}

variable "state_bucket" {
  description = "S3 bucket containing remote Terraform state files."
  type        = string
}

variable "network_state_key" {
  description = "Terraform state key for the network module."
  type        = string
}

variable "security_state_key" {
  description = "Terraform state key for the security module."
  type        = string
}

variable "nlb_state_key" {
  description = "Terraform state key for the NLB module."
  type        = string
}

#############################################
# ECS Cluster
#############################################

variable "cluster_name" {
  description = "Name of the ECS Cluster."

  type = string

  validation {
    condition     = length(trimspace(var.cluster_name)) > 0
    error_message = "cluster_name cannot be empty."
  }
}

#############################################
# ECS Service
#############################################

variable "service_name" {
  description = "Name of the ECS Service."
  type        = string
}

variable "image_uri" {
  description = "Container image URI."
  type        = string
}

variable "cpu" {
  description = "CPU units for the ECS Task."
  type        = number
}

variable "memory" {
  description = "Memory (MiB) for the ECS Task."
  type        = number
}

variable "container_port" {
  description = "Application container port."
  type        = number
}

variable "desired_count" {
  description = "Desired number of ECS tasks."

  type    = number
  default = 1
}

#############################################
# Runtime Platform
#############################################

variable "cpu_architecture" {
  description = "CPU architecture."

  type    = string
  default = "X86_64"

  validation {
    condition     = contains(["X86_64", "ARM64"], var.cpu_architecture)
    error_message = "cpu_architecture must be either X86_64 or ARM64."
  }
}

#############################################
# Networking
#############################################

variable "ingress_security_group_ids" {
  description = "Security Groups allowed to access the ECS service."

  type    = list(string)
  default = []
}

variable "allowed_cidrs" {
  description = "Allowed outbound CIDR ranges."

  type    = list(string)
  default = []
}

#############################################
# Environment Variables
#############################################

variable "environment_variables" {
  description = "Environment variables passed to the container."

  type    = map(string)
  default = {}
}

#############################################
# Secrets
#############################################

variable "secret_arns" {
  description = "Map of environment variable names to Secrets Manager ARNs."

  type    = map(string)
  default = {}
}

#############################################
# IAM
#############################################

variable "task_role_arn" {
  description = "IAM Role ARN assumed by the ECS Task."

  type = string
}

variable "execution_role_arn" {
  description = "IAM Execution Role ARN used by ECS."

  type = string
}

#############################################
# Logging
#############################################

variable "log_retention_days" {
  description = "CloudWatch log retention period."

  type    = number
  default = 30
}

variable "kms_key_id" {
  description = "Optional KMS Key ARN/ID used to encrypt CloudWatch Log Groups."

  type    = string
  default = null
}

#############################################
# ECS Features
#############################################

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

#############################################
# Common Tags
#############################################

variable "tags" {
  description = "Tags applied to all AWS resources."

  type    = map(string)
  default = {}
}