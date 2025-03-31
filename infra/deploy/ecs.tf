# ECS luster for running app on Fargate

resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${local.prefix}-task-exec-role-policy"
  path        = "/"
  description = "Allow ECS to retrieve images and add to logs"
  policy      = file("./templates/ecs/task-execution-role-policy.json")
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${local.prefix}-task-execution-roe"
  assume_role_policy = file("./templates/ecs/task-assume-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}

resource "aws_iam_policy" "task_ssm_policy" {
  name        = "${local.prefix}-task-ssm-role-policy"
  path        = "/"
  description = "Allow ECS to retrieve images and add to logs"
  policy      = file("./templates/ecs/task-ssm-policy.json")
}

resource "aws_iam_role" "app_task" {
  name               = "${local.prefix}-app-task"
  assume_role_policy = file("./templates/ecs/task-assume-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "task_ssm_policy" {
  role       = aws_iam_role.app_task.name
  policy_arn = aws_iam_policy.task_ssm_policy.arn
}

resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${local.prefix}-api"
}

resource "aw_ecs_cluster" "main" {
  name = "${local.prefix}-cluster"
}

resource "aws_ecs_task_definition" "api" {
  family = "${local.prefix}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  execution_role_arn = aws_iam_role.task_execution_role.arn
  task_role_arn = aws_iam_role.app_task.arn

  container_definitions = jsondecode([])

  volume {
    name = "static"
  }

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "x86_64"
  }
}

resource "aws_security_group" "ecs_service" {
  description = "Access rules for the ECS service."
  name = "${local.prefix}-ecs-service"
  vpc_id = aws_vpc.main.id
  
  # Outbound accessto endpoints
  egress {
    from_port = 443
    to_port = 433
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # RDS connectivity
  egress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [
      aws_subnet.private_a.cidr_block,
      aws_subnet.private_b.cidr_block,
    ]
  }
  
  # NFS Port for EFS volumes
  egress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks = [
      aws_subnet.private_a.cidr_block,
      aws_subnet.private_b.cidr_block,
    ]
  }

  # HTTP inbound access
  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    security_groups = [
      aws_security_group.lb.id
    ]
  }

}