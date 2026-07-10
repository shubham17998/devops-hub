# ECS Cluster

output "ecs_cluster_id" {
  description = "ID of the existing ECS Cluster."

  value = data.aws_ecs_cluster.this.id
}

# ECS Task Definition

output "task_definition_arn" {
  description = "ARN of the ECS Task Definition."

  value = aws_ecs_task_definition.this.arn
}

# ECS Service

output "service_name" {
  description = "Name of the ECS Service."

  value = aws_ecs_service.this.name
}

# CloudWatch Logs

output "cloudwatch_log_group" {
  description = "CloudWatch Log Group name."

  value = aws_cloudwatch_log_group.ecs.name
}