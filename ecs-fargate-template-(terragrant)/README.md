# ECS Fargate Terragrunt Template

A reusable Terraform/Terragrunt module for deploying containerized services onto an **existing** AWS ECS Fargate cluster, complete with task definition, service, security group, CloudWatch logging, and a GitHub Actions deployment pipeline.

## Overview

This template provisions everything needed to run a single service on Fargate behind an existing Application Load Balancer (ALB):

- **ECS Task Definition** — Fargate-compatible, configurable CPU/memory/architecture, environment variables, Secrets Manager integration, optional container health check, and `awslogs` logging
- **ECS Service** — attaches to an existing ECS cluster and ALB target group, runs tasks in private subnets, rolling deployments with a deployment circuit breaker (auto-rollback on failure)
- **Security Group** — restricts inbound traffic to the container port from the ALB's security group only, with configurable egress
- **CloudWatch Log Group** — one per service, with configurable retention and optional KMS encryption
- **Terragrunt live configuration** — per-environment inputs (`dev`, `qa`, `stage`, `prod`) with shared remote state and provider generation
- **GitHub Actions workflow** — manual (`workflow_dispatch`) validate → plan → apply pipeline using OpenTofu + Terragrunt and OIDC-based AWS auth

> **Note:** This module assumes the ECS cluster, VPC, subnets, ALB, target group, and IAM roles already exist. It does **not** create them.

## Repository Structure

```
.
├── .github/workflows/
│   └── ecs-fargate-deploy.yml   # CI/CD pipeline (validate/plan/apply)
├── live/
│   ├── root.hcl                 # Shared Terragrunt config: remote state + provider
│   └── dev/ecs/
│       └── terragrunt.hcl       # Environment-specific inputs for "dev"
└── modules/
    └── ecs-fargate/
        ├── main.tf               # Log group, task definition, security group, service
        ├── variables.tf          # Module input variables
        ├── outputs.tf            # Module outputs
        ├── locals.tf             # environment/secret JSON transforms
        ├── versions.tf           # Terraform & AWS provider version constraints
        └── task-definition.json.tpl  # Container definition template
```

Additional environments (`qa`, `stage`, `prod`) are added by creating sibling folders under `live/`, e.g. `live/prod/ecs/terragrunt.hcl`, following the same pattern as `live/dev/ecs`.

## Prerequisites

- [OpenTofu](https://opentofu.org/) (or Terraform >= 1.8.0)
- [Terragrunt](https://terragrunt.gruntwork.io/)
- AWS credentials with permissions to manage ECS, CloudWatch Logs, EC2 security groups, and read the S3 state bucket
- An existing:
  - ECS Cluster
  - VPC with private subnets (with routes to reach ECR/Secrets Manager, e.g. via NAT Gateway or VPC endpoints)
  - Application Load Balancer with a target group
  - IAM Task Role and Task Execution Role
- An S3 bucket for Terragrunt remote state, exported as the `TG_STATE_BUCKET` environment variable

## Configuration

### Remote State & Provider (`live/root.hcl`)

All environments inherit this root configuration:

- **Backend:** S3, region `ap-south-1`, state key derived from the relative path (`<env>/<component>/terraform.tfstate`), encryption and native S3 locking (`use_lockfile`) enabled
- **Provider:** AWS provider generated automatically, pinned to the region above

Set the state bucket before running Terragrunt:

```bash
export TG_STATE_BUCKET=my-terragrunt-state-bucket
```

### Environment Inputs (`live/dev/ecs/terragrunt.hcl`)

Points `terraform.source` at `modules/ecs-fargate` and supplies all module inputs (cluster, network, IAM roles, container image, env vars, secrets, tags, etc.) for that environment. Copy this file's structure to `live/<env>/ecs/terragrunt.hcl` for new environments and update the values accordingly.

## Module Inputs (`modules/ecs-fargate`)

| Variable | Type | Default | Description |
|---|---|---|---|
| `cluster_name` | string | — | Name of the existing ECS cluster |
| `service_name` | string | — | Name of the ECS service (also container name & log group suffix) |
| `image_uri` | string | — | Container image URI (e.g. ECR) |
| `cpu` | number | — | Fargate task CPU units; one of `256`, `512`, `1024`, `2048`, `4096` |
| `memory` | number | — | Task memory in MiB (>= 512) |
| `container_port` | number | — | Port exposed by the container (1–65535) |
| `desired_count` | number | `1` | Number of desired tasks |
| `cpu_architecture` | string | `X86_64` | `X86_64` or `ARM64` |
| `task_role_arn` | string | — | IAM role ARN assumed by the application |
| `execution_role_arn` | string | — | IAM role ARN used by ECS to pull images & publish logs |
| `vpc_id` | string | — | VPC ID for the security group |
| `private_subnet_ids` | list(string) | — | Private subnets for task ENIs |
| `alb_security_group_id` | string | — | Security group ID of the existing ALB |
| `target_group_arn` | string | — | ALB target group ARN |
| `allowed_cidrs` | list(string) | `[]` | Outbound CIDR ranges allowed from tasks |
| `egress_protocol` | string | `tcp` | `tcp` or `udp` |
| `egress_from_port` | number | `443` | Outbound start port |
| `egress_to_port` | number | `443` | Outbound end port |
| `environment_variables` | map(string) | `{}` | Plaintext env vars injected into the container |
| `secret_arns` | map(string) | `{}` | Map of env var name → Secrets Manager ARN |
| `log_retention_days` | number | `365` | CloudWatch log retention (minimum 365) |
| `kms_key_id` | string | `null` | Optional KMS key for log encryption |
| `enable_execute_command` | bool | `false` | Enables ECS Exec (`aws ecs execute-command`) |
| `readonly_root_filesystem` | bool | `true` | Mounts container root filesystem read-only |
| `health_check` | object | `null` | Container health check: `command`, `interval`, `timeout`, `retries`, `startPeriod` |
| `aws_region` | string | — | AWS region (used in log configuration) |
| `tags` | map(string) | `{}` | Tags applied to all resources |

## Module Outputs

| Output | Description |
|---|---|
| `ecs_cluster_id` | ID of the existing ECS cluster |
| `task_definition_arn` | ARN of the registered task definition |
| `service_name` | Name of the ECS service |
| `cloudwatch_log_group` | Name of the CloudWatch log group |

## Usage

1. **Configure state bucket and update inputs**

   ```bash
   export TG_STATE_BUCKET=my-terragrunt-state-bucket
   ```

   Edit `live/dev/ecs/terragrunt.hcl` and replace the placeholder values (`vpc-xxxxxxxx`, `subnet-aaaaaaaa`, ARNs, image URI, etc.) with real resource identifiers for your account.

2. **Deploy locally**

   ```bash
   cd live/dev/ecs
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

3. **Deploy via CI/CD**

   Trigger the **ECS Fargate Infrastructure Deployment** workflow manually from the GitHub Actions tab, selecting the target environment (`dev`, `qa`, `stage`, or `prod`). The workflow:

   - Assumes an AWS IAM role via OIDC (`secrets.AWS_ROLE_ARN`) — no long-lived AWS keys required
   - Runs `terragrunt init`, `terragrunt hclfmt`, `tofu fmt -check`, `terragrunt validate`, and `terragrunt plan`
   - On success, runs `terragrunt apply -auto-approve` in a job gated by a GitHub **environment** matching the chosen deployment target (useful for required reviewers/approvals)

   Required repository configuration:
   - Secret `AWS_ROLE_ARN` — IAM role ARN with an OIDC trust policy for GitHub Actions
   - GitHub Environments named `dev`, `qa`, `stage`, `prod` (for approval gates, if desired)
   - `live/<environment>/ecs/terragrunt.hcl` must exist for each selectable environment

## Design Notes

- **Security group:** Inbound traffic is restricted to `container_port` from the ALB's security group only; there is no direct public ingress to tasks.
- **Networking:** Tasks run in private subnets with `assign_public_ip = false`; outbound internet/AWS API access (e.g. to pull images or reach Secrets Manager) must be provided via NAT Gateway or VPC endpoints.
- **Deployments:** `deployment_circuit_breaker` is enabled with automatic rollback, and `task_definition` changes on the service are ignored post-creation so that out-of-band deployments (e.g. `aws ecs update-service`) don't get reverted by Terraform on the next apply.
- **Secrets:** Values in `secret_arns` are injected via the ECS `secrets` block (resolved from Secrets Manager at container start), not passed as plaintext.
- **Logging:** Each service gets a dedicated CloudWatch Log Group at `/ecs/<service_name>` with a minimum 365-day retention enforced by variable validation.

## Cleanup

```bash
cd live/dev/ecs
terragrunt destroy
```

This removes the task definition, service, security group, and log group created by this module. It does **not** affect the shared ECS cluster, VPC, ALB, or IAM roles.