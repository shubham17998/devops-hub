[
  {
    "name": "${service_name}",
    "image": "${image_uri}",
    "essential": true,

    "readonlyRootFilesystem": ${readonly_root_filesystem},

    "portMappings": [
      {
        "containerPort": ${container_port},
        "protocol": "tcp"
      }
    ],

    "environment": ${environment_variables},

    "secrets": ${secrets},

    %{ if health_check != null ~}
    "healthCheck": {
      "command": ${jsonencode(health_check.command)},
      "interval": ${health_check.interval},
      "timeout": ${health_check.timeout},
      "retries": ${health_check.retries},
      "startPeriod": ${health_check.startPeriod}
    },
    %{ endif ~}

    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group_name}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]