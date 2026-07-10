#############################################
# CloudWatch Log Group
#############################################

resource "aws_cloudwatch_log_group" "ecs" {

  name = "/ecs/${var.service_name}"

  retention_in_days = var.log_retention_days

  kms_key_id = var.kms_key_id

  tags = var.tags
}

#############################################
# ECS Cluster
#############################################

resource "aws_ecs_cluster" "this" {

  name = var.cluster_name

  tags = var.tags
}

#############################################
# ECS Task Definition
#############################################

resource "aws_ecs_task_definition" "this" {

  family = var.service_name

  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  cpu    = var.cpu
  memory = var.memory

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn

  runtime_platform {

    cpu_architecture        = var.cpu_architecture
    operating_system_family = "LINUX"
  }

  container_definitions = templatefile(
    "${path.module}/task-definition.json.tpl",
    {
      service_name          = var.service_name
      image_uri             = var.image_uri
      container_port        = var.container_port
      environment_variables = local.environment_variables
      secrets               = local.secrets
      log_group_name        = aws_cloudwatch_log_group.ecs.name
      aws_region            = var.aws_region

      health_check             = var.health_check
      readonly_root_filesystem = var.readonly_root_filesystem
    }
  )

  tags = var.tags
}

#############################################
# ECS Security Group
#############################################

resource "aws_security_group" "ecs_tasks" {

  name        = "${var.service_name}-ecs-sg"
  description = "Security Group for ECS Tasks"
  vpc_id      = local.vpc_id

  ingress {

    description = "Allow application traffic"

    from_port = var.container_port
    to_port   = var.container_port

    protocol = "tcp"

    security_groups = var.ingress_security_group_ids
  }

  egress {

    description = "Outbound traffic"

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = var.allowed_cidrs
  }

  tags = var.tags
}

#############################################
# ECS Service
#############################################

resource "aws_ecs_service" "this" {

  name = var.service_name

  cluster = aws_ecs_cluster.this.id

  task_definition = aws_ecs_task_definition.this.arn

  launch_type = "FARGATE"

  desired_count = var.desired_count

  enable_execute_command = var.enable_execute_command

  network_configuration {

    subnets = local.private_subnet_ids

    security_groups = [
      aws_security_group.ecs_tasks.id
    ]

    assign_public_ip = false
  }

  depends_on = [
    aws_ecs_task_definition.this
  ]

  tags = var.tags
}